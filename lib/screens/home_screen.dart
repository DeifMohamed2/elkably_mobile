import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/stat_row.dart';
import '../widgets/home/notification_item.dart';
import '../widgets/home/card_container.dart';
import '../widgets/home/balance_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(String screen) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final students = ref.watch(studentsProvider);
    final selectedStudentIndex = ref.watch(selectedStudentIndexProvider);
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final totalAbsences = ref.watch(totalAbsencesProvider);
    final pendingAssignments = ref.watch(pendingAssignmentsProvider);
    final newNotificationsCount = ref.watch(newNotificationsCountProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final totalUnpaid = ref.watch(totalUnpaidFeesProvider);

    // Use dashboard data if available, otherwise fallback
    final dashboardData = dashboardState.data;
    final lastSession = dashboardData?.lastSession;
    final recentNotifications = dashboardData?.recentNotifications ?? [];
    final totals = dashboardData?.totals;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppColors.surfaceBackground
              : AppColors.surfaceBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardNotifierProvider.notifier).fetchDashboard();
        },
        color: AppColors.elkablyRed,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            HomeHeader(
              student: student,
              students: students,
              selectedStudentIndex: selectedStudentIndex,
              newNotificationsCount: newNotificationsCount,
              onNotificationTap: () => widget.onNavigate('announcements'),
              isDarkMode: isDarkMode,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Balance Card
                  BalanceCard(
                    remainingAmount: totalUnpaid,
                    isDarkMode: isDarkMode,
                   
                  ),
                  const SizedBox(height: 20),

                  // Loading State
                  if (dashboardState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: AppColors.elkablyRed,
                        ),
                      ),
                    ),

                  // Error State
                  if (dashboardState.error != null && !dashboardState.isLoading)
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
                            dashboardState.error!,
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
                                  .read(dashboardNotifierProvider.notifier)
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
                  if (!dashboardState.isLoading &&
                      dashboardState.error == null) ...[
                    // Last Session Status Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Session Status",
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Status Card - Combined
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? AppColors.cardBackground
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                isDarkMode
                                    ? null
                                    : Border.all(
                                      color: AppColors.borderLight,
                                      width: 1,
                                    ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDarkMode ? 0.2 : 0.06,
                                ),
                                blurRadius: isDarkMode ? 8 : 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              lastSession != null
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Date and Time Header
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('EEE, MMM d').format(
                                              DateTime.parse(lastSession.date),
                                            ),
                                            style: TextStyle(
                                              color:
                                                  isDarkMode
                                                      ? Colors.white
                                                      : AppColors.textPrimaryLight,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (lastSession.time != null &&
                                              lastSession.time != 'N/A')
                                            Text(
                                              () {
                                                try {
                                                  final timeParts = lastSession.time!.split(' ');
                                                  final timeComponents = timeParts[0].split(':');
                                                  final period = timeParts.length > 1 ? timeParts[1] : '';
                                                  if (timeComponents.length >= 2) {
                                                    return '${timeComponents[0]}:${timeComponents[1]} $period';
                                                  }
                                                  return lastSession.time!;
                                                } catch (e) {
                                                  return lastSession.time!;
                                                }
                                              }(),
                                              style: TextStyle(
                                                color:
                                                    isDarkMode
                                                        ? AppColors.textMuted
                                                        : AppColors.textMutedLight,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Attendance Status
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: (lastSession.status ==
                                                              AttendanceStatus.present ||
                                                          lastSession.status ==
                                                              AttendanceStatus.presentFromOtherGroup
                                                      ? AppColors.success
                                                      : lastSession.status ==
                                                          AttendanceStatus.late
                                                      ? AppColors.warning
                                                      : AppColors.elkablyRed)
                                                  .withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              lastSession.status ==
                                                          AttendanceStatus.present ||
                                                      lastSession.status ==
                                                          AttendanceStatus.presentFromOtherGroup
                                                  ? Icons.check_circle_outline
                                                  : lastSession.status ==
                                                      AttendanceStatus.late
                                                  ? Icons.schedule
                                                  : Icons.cancel_outlined,
                                              color:
                                                  lastSession.status ==
                                                              AttendanceStatus.present ||
                                                          lastSession.status ==
                                                              AttendanceStatus.presentFromOtherGroup
                                                      ? AppColors.success
                                                      : lastSession.status ==
                                                          AttendanceStatus.late
                                                      ? AppColors.warning
                                                      : AppColors.elkablyRed,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            lastSession.status ==
                                                    AttendanceStatus.present
                                                ? 'Present'
                                                : lastSession.status ==
                                                    AttendanceStatus.late
                                                ? 'Late'
                                                : lastSession.status ==
                                                    AttendanceStatus.presentFromOtherGroup
                                                ? 'Present (Other Group)'
                                                : 'Absent',
                                            style: TextStyle(
                                              color:
                                                  lastSession.status ==
                                                              AttendanceStatus.present ||
                                                          lastSession.status ==
                                                              AttendanceStatus.presentFromOtherGroup
                                                      ? AppColors.success
                                                      : lastSession.status ==
                                                          AttendanceStatus.late
                                                      ? AppColors.warning
                                                      : AppColors.elkablyRed,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Homework Status (only if not absent)
                                      if (lastSession.status != AttendanceStatus.absent) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: (lastSession.homeworkStatus.contains('Submitted') ||
                                                            lastSession.homeworkStatus.contains('with steps')
                                                        ? AppColors.success
                                                        : lastSession.homeworkStatus == 'N/A'
                                                        ? Colors.grey
                                                        : AppColors.warning)
                                                    .withValues(alpha: 0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                lastSession.homeworkStatus.contains('Submitted') ||
                                                        lastSession.homeworkStatus.contains('with steps')
                                                    ? Icons.check_circle_outline
                                                    : lastSession.homeworkStatus == 'N/A'
                                                    ? Icons.remove_circle_outline
                                                    : Icons.cancel_outlined,
                                                color:
                                                    lastSession.homeworkStatus.contains('Submitted') ||
                                                            lastSession.homeworkStatus.contains('with steps')
                                                        ? AppColors.success
                                                        : lastSession.homeworkStatus == 'N/A'
                                                        ? Colors.grey
                                                        : AppColors.warning,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              lastSession.homeworkStatus,
                                              style: TextStyle(
                                                color:
                                                    lastSession.homeworkStatus.contains('Submitted') ||
                                                            lastSession.homeworkStatus.contains('with steps')
                                                        ? (isDarkMode
                                                            ? AppColors.textSecondary
                                                            : AppColors.textSecondaryLight)
                                                        : lastSession.homeworkStatus == 'N/A'
                                                        ? Colors.grey
                                                        : AppColors.warning,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      
                                      // Group Info (only if not absent)
                                      if (lastSession.group != null && lastSession.status != AttendanceStatus.absent) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: AppColors.elkablyRed.withValues(alpha: 0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.group_outlined,
                                                size: 16,
                                                color: AppColors.elkablyRed,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${lastSession.group!.grade} ${lastSession.group!.gradeType} ${lastSession.group!.groupTime} ${lastSession.group!.displayText}',
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
                                      
                                      // Payment Info (only if not absent)
                                      if (lastSession.status != AttendanceStatus.absent && lastSession.amountPaid != null) ...[
                                        const SizedBox(height: 8),
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
                                              'EGP ${lastSession.amountPaid!.toStringAsFixed(2)} Paid',
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
                                    ],
                                  )
                                  : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        'No session data available',
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? AppColors.textSecondary
                                                  : AppColors
                                                      .textSecondaryLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats Card
                    CardContainer(
                      isDarkMode: isDarkMode,
                      title: 'Quick Stats',
                      child:
                          totals != null
                              ? Column(
                                children: [
                                  StatRow(
                                    icon: Icons.check_circle_outline,
                                    iconBgColor: AppColors.success.withValues(
                                      alpha: 0.2,
                                    ),
                                    iconColor: AppColors.success,
                                    label: 'Present',
                                    value: '${totals.present}',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 16),
                                  StatRow(
                                    icon: Icons.schedule,
                                    iconBgColor: AppColors.warning.withValues(
                                      alpha: 0.2,
                                    ),
                                    iconColor: AppColors.warning,
                                    label: 'Late',
                                    value: '${totals.late}',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 16),
                                  StatRow(
                                    icon: Icons.cancel_outlined,
                                    iconBgColor: AppColors.elkablyRed
                                        .withValues(alpha: 0.2),
                                    iconColor: AppColors.elkablyRed,
                                    label: 'Absent',
                                    value: '${totals.absent}',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 16),
                                  StatRow(
                                    icon: Icons.calendar_today_outlined,
                                    iconBgColor: AppColors.info.withValues(
                                      alpha: 0.2,
                                    ),
                                    iconColor: AppColors.info,
                                    label: 'Total Sessions',
                                    value: '${totals.total}',
                                    isDarkMode: isDarkMode,
                                  ),
                                ],
                              )
                              : Column(
                                children: [
                                  StatRow(
                                    icon: Icons.calendar_today_outlined,
                                    iconBgColor: AppColors.elkablyRed
                                        .withValues(alpha: 0.2),
                                    iconColor: AppColors.elkablyRed,
                                    label: 'Total Absences',
                                    value: '$totalAbsences',
                                    isDarkMode: isDarkMode,
                                  ),
                                  const SizedBox(height: 16),
                                  StatRow(
                                    icon: Icons.assignment_outlined,
                                    iconBgColor: AppColors.warning.withValues(
                                      alpha: 0.2,
                                    ),
                                    iconColor: AppColors.warning,
                                    label: 'Pending Assignments',
                                    value: '$pendingAssignments',
                                    isDarkMode: isDarkMode,
                                  ),
                                ],
                              ),
                    ),
                    const SizedBox(height: 20),

                    // Recent Notifications Card
                    if (recentNotifications.isNotEmpty)
                      CardContainer(
                        isDarkMode: isDarkMode,
                        title: 'Recent Notifications',
                        trailing: GestureDetector(
                          onTap: () => widget.onNavigate('announcements'),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.elkablyRed,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        child: Column(
                          children:
                              recentNotifications.take(3).map((notification) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: NotificationItem(
                                    notification: notification,
                                    isDarkMode: isDarkMode,
                                  ),
                                );
                              }).toList(),
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
