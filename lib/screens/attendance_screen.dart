import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  String selectedFilter = 'All'; // All, Present, Absent, Late
  DateTime? startDate;
  DateTime? endDate;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _studentSelectorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Fetch attendance on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceNotifierProvider.notifier).fetchAttendance();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _animationController.forward();
      _showOverlay();
    } else {
      _animationController.reverse();
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox =
        _studentSelectorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleMenu,
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder:
                        (context, child) => Opacity(
                          opacity: _fadeAnimation.value * 0.2,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 2.0 * _fadeAnimation.value,
                              sigmaY: 2.0 * _fadeAnimation.value,
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                left: offset.dx + 24,
                right:
                    MediaQuery.of(context).size.width -
                    offset.dx -
                    size.width +
                    24,
                top: offset.dy + size.height + 16,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder:
                      (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, -20 * (1 - _fadeAnimation.value)),
                            child: _buildDropdownMenu(),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildDropdownMenu() {
    final students = ref.read(studentsProvider);
    final selectedStudentIndex = ref.read(selectedStudentIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              students.length,
              (index) => _buildDropdownItem(
                index,
                students[index],
                index == selectedStudentIndex,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(int index, Student student, bool isSelected) {
    final delay = index * 100;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder:
          (context, value, child) => Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Opacity(opacity: value, child: child),
          ),
      child: GestureDetector(
        onTap: () {
          ref.read(selectedStudentIndexProvider.notifier).state = index;
          _toggleMenu();
          // Fetch attendance for the newly selected student
          ref.read(attendanceNotifierProvider.notifier).fetchAttendance();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: index < ref.read(studentsProvider).length - 1 ? 1 : 0,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student.grade} • ${student.studentClass}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOut,
                  builder:
                      (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                  child: const Icon(Icons.check, color: Colors.white, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final attendance = attendanceState.attendance;
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Apply filters
    var filteredAttendance =
        attendance.where((record) {
          // Status filter
          if (selectedFilter == 'Present' &&
              record.status != AttendanceStatus.present) {
            return false;
          }
          if (selectedFilter == 'Absent' &&
              record.status != AttendanceStatus.absent) {
            return false;
          }
          if (selectedFilter == 'Late' &&
              record.status != AttendanceStatus.late) {
            return false;
          }

          // Period filter (Date Range)
          if (startDate != null || endDate != null) {
            final recordDate = DateTime.parse(record.date);

            if (startDate != null && recordDate.isBefore(startDate!)) {
              return false;
            }

            if (endDate != null && recordDate.isAfter(endDate!)) {
              return false;
            }
          }

          return true;
        }).toList();

    final presentCount =
        filteredAttendance
            .where((a) => a.status == AttendanceStatus.present)
            .length;
    final absentCount =
        filteredAttendance
            .where((a) => a.status == AttendanceStatus.absent)
            .length;
    final lateCount =
        filteredAttendance
            .where((a) => a.status == AttendanceStatus.late)
            .length;
    final attendanceRate =
        filteredAttendance.isNotEmpty
            ? ((presentCount / filteredAttendance.length) * 100).round()
            : 0;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppColors.surfaceBackground
              : AppColors.surfaceBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(attendanceNotifierProvider.notifier).fetchAttendance();
        },
        color: AppColors.elkablyRed,
        child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Student Selector
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE53935), // red-600
                    Color(0xFFEF5350), // red-500
                    Color(0xFFD32F2F), // red-700
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Attendance Title
                      const Center(
                        child: Text(
                          'Attendance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Student Dropdown Button
                      GestureDetector(
                        key: _studentSelectorKey,
                        onTap: _toggleMenu,
                        child: AnimatedScale(
                          scale: _isMenuOpen ? 0.99 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar Circle
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          ref
                                              .watch(studentProvider)
                                              .name[0]
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    // Student Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ref.watch(studentProvider).name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              height: 1.2,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${ref.watch(studentProvider).grade} • ${ref.watch(studentProvider).studentClass}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              height: 1.2,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Chevron Icon
                                    AnimatedRotation(
                                      turns: _rotationAnimation.value,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Calendar and Records
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Loading State
                  if (attendanceState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: AppColors.elkablyRed,
                        ),
                      ),
                    ),

                  // Error State
                  if (attendanceState.error != null &&
                      !attendanceState.isLoading)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.elkablyRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.elkablyRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.elkablyRed,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            attendanceState.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(attendanceNotifierProvider.notifier)
                                  .refresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.elkablyRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),

                  // Show content only when not loading and no error
                  if (!attendanceState.isLoading &&
                      attendanceState.error == null) ...[
                    // Calendar Card
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? AppColors.cardBackground
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDarkMode ? 0.2 : 0.06,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.month,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColors.elkablyRed.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.elkablyRed,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                          ),
                          weekendTextStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white70
                                    : AppColors.textSecondaryLight,
                          ),
                          outsideTextStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.textMuted
                                    : AppColors.textMutedLight,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          weekendStyle: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        eventLoader: (day) {
                          // Mark days with attendance records
                          final dayStr = DateFormat('yyyy-MM-dd').format(day);
                          final hasRecord = attendance.any(
                            (record) => record.date == dayStr,
                          );
                          return hasRecord ? [dayStr] : [];
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;

                            // Find the attendance record for this day
                            final dayStr = DateFormat(
                              'yyyy-MM-dd',
                            ).format(date);
                            final record = attendance.firstWhere(
                              (r) => r.date == dayStr,
                              orElse:
                                  () => AttendanceRecord(
                                    date: dayStr,
                                    status: AttendanceStatus.present,
                                    homeworkStatus: HomeworkStatus.notDone,
                                  ),
                            );

                            Color markerColor;
                            switch (record.status) {
                              case AttendanceStatus.present:
                              case AttendanceStatus.presentFromOtherGroup:
                                markerColor = AppColors.success;
                                break;
                              case AttendanceStatus.late:
                                markerColor = AppColors.warning;
                                break;
                              case AttendanceStatus.absent:
                                markerColor = AppColors.elkablyRed;
                                break;
                            }

                            return Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: markerColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? AppColors.cardBackground
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDarkMode ? 0.2 : 0.06,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Summary',
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Present',
                                  value: '$presentCount',
                                  valueColor: AppColors.success,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Late',
                                  value: '$lateCount',
                                  valueColor: AppColors.warning,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Absent',
                                  value: '$absentCount',
                                  valueColor: AppColors.elkablyRed,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              Expanded(
                                child: _SummaryItem(
                                  label: 'Rate',
                                  value: '$attendanceRate%',
                                  valueColor:
                                      isDarkMode
                                          ? Colors.white
                                          : AppColors.textPrimaryLight,
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filters
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? AppColors.cardBackground
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? AppColors.borderLight.withValues(
                                              alpha: 0.3,
                                            )
                                            : AppColors.borderLight,
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedFilter,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor:
                                      isDarkMode
                                          ? AppColors.cardBackground
                                          : Colors.white,
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : AppColors.textPrimaryLight,
                                    fontSize: 14,
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : AppColors.textSecondaryLight,
                                  ),
                                  items:
                                      ['All', 'Present', 'Absent', 'Late']
                                          .map(
                                            (status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => selectedFilter = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date Range',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: AppColors.elkablyRed,
                                            onPrimary: Colors.white,
                                            surface:
                                                isDarkMode
                                                    ? AppColors.cardBackground
                                                    : Colors.white,
                                            onSurface:
                                                isDarkMode
                                                    ? Colors.white
                                                    : AppColors
                                                        .textPrimaryLight,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startDate = picked.start;
                                      endDate = picked.end;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? AppColors.cardBackground
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isDarkMode
                                              ? AppColors.borderLight
                                                  .withValues(alpha: 0.3)
                                              : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          startDate != null && endDate != null
                                              ? '${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}'
                                              : 'Select Range',
                                          style: TextStyle(
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : AppColors
                                                        .textPrimaryLight,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (startDate != null || endDate != null)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              startDate = null;
                                              endDate = null;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color:
                                                isDarkMode
                                                    ? Colors.white70
                                                    : AppColors
                                                        .textSecondaryLight,
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color:
                                              isDarkMode
                                                  ? Colors.white70
                                                  : AppColors
                                                      .textSecondaryLight,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    ...filteredAttendance.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AttendanceRecordCard(
                          record: record,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                  ], // End of conditional content
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  final AttendanceRecord record;
  final bool isDarkMode;

  const _AttendanceRecordCard({required this.record, this.isDarkMode = true});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(record.date);
    final dayName = DateFormat('EEE').format(date);
    final dayNumber = date.day;
    final monthName = DateFormat('MMM').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Info
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? AppColors.surfaceBackground
                      : AppColors.iconBackgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    color:
                        isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  monthName,
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Status Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attendance Status
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            record.status == AttendanceStatus.present ||
                                    record.status ==
                                        AttendanceStatus.presentFromOtherGroup
                                ? AppColors.success.withValues(alpha: 0.2)
                                : record.status == AttendanceStatus.late
                                ? AppColors.warning.withValues(alpha: 0.2)
                                : AppColors.elkablyRed.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        record.status == AttendanceStatus.present ||
                                record.status ==
                                    AttendanceStatus.presentFromOtherGroup
                            ? Icons.check_circle_outline
                            : record.status == AttendanceStatus.late
                            ? Icons.schedule
                            : Icons.cancel_outlined,
                        size: 16,
                        color:
                            record.status == AttendanceStatus.present ||
                                    record.status ==
                                        AttendanceStatus.presentFromOtherGroup
                                ? AppColors.success
                                : record.status == AttendanceStatus.late
                                ? AppColors.warning
                                : AppColors.elkablyRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.status == AttendanceStatus.present
                            ? 'Present'
                            : record.status == AttendanceStatus.late
                            ? 'Late'
                            : record.status ==
                                AttendanceStatus.presentFromOtherGroup
                            ? 'Present (Other Group)'
                            : 'Absent',
                        style: TextStyle(
                          color:
                              record.status == AttendanceStatus.present ||
                                      record.status ==
                                          AttendanceStatus.presentFromOtherGroup
                                  ? AppColors.success
                                  : record.status == AttendanceStatus.late
                                  ? AppColors.warning
                                  : AppColors.elkablyRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (record.time != null && record.time != 'N/A') ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${record.time}',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppColors.textMuted
                                  : AppColors.textMutedLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Homework Status (only show if not absent)
                if (record.status != AttendanceStatus.absent)
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              record.homeworkStatus == HomeworkStatus.done ||
                                      record.homeworkStatus ==
                                          HomeworkStatus.doneWithoutSteps
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : record.homeworkStatus ==
                                      HomeworkStatus.notAvailable
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : AppColors.warning.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          record.homeworkStatus == HomeworkStatus.done ||
                                  record.homeworkStatus ==
                                      HomeworkStatus.doneWithoutSteps
                              ? Icons.check_circle_outline
                              : record.homeworkStatus ==
                                  HomeworkStatus.notAvailable
                              ? Icons.remove_circle_outline
                              : Icons.cancel_outlined,
                          size: 16,
                          color:
                              record.homeworkStatus == HomeworkStatus.done ||
                                      record.homeworkStatus ==
                                          HomeworkStatus.doneWithoutSteps
                                  ? AppColors.success
                                  : record.homeworkStatus ==
                                      HomeworkStatus.notAvailable
                                  ? Colors.grey
                                  : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record.homeworkStatus == HomeworkStatus.done
                            ? 'HW Done (with steps)'
                            : record.homeworkStatus ==
                                HomeworkStatus.doneWithoutSteps
                            ? 'HW Done (no steps)'
                            : record.homeworkStatus == HomeworkStatus.notAvailable
                            ? 'N/A'
                            : 'No Homework',
                        style: TextStyle(
                          color:
                              record.homeworkStatus == HomeworkStatus.done ||
                                      record.homeworkStatus ==
                                          HomeworkStatus.doneWithoutSteps
                                  ? (isDarkMode
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight)
                                  : record.homeworkStatus ==
                                      HomeworkStatus.notAvailable
                                  ? Colors.grey
                                  : AppColors.warning,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                if (record.status != AttendanceStatus.absent)
                  const SizedBox(height: 8),

                // Payment Status (only show if not absent)
                if (record.status != AttendanceStatus.absent)
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record.amountPaid != null
                            ? 'EGP ${record.amountPaid!.toStringAsFixed(2)} Paid'
                            : 'No payment info',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isDarkMode;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.valueColor,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color:
                isDarkMode
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
