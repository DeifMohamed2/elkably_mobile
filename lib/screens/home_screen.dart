import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(String screen) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final attendance = ref.watch(attendanceProvider);
    final totalAbsences = ref.watch(totalAbsencesProvider);
    final pendingAssignments = ref.watch(pendingAssignmentsProvider);
    final newNotificationsCount = ref.watch(newNotificationsCountProvider);
    final notifications = ref.watch(notificationsProvider);

    final todayAttendance = attendance.isNotEmpty ? attendance[0] : null;
    final recentNotifications = notifications.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: AppGradients.headerGradient,
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Row(
                  children: [
                    // Student Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.elkablyRed.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          student.name[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Student Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${student.grade} • ${student.studentClass}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Badge
                    GestureDetector(
                      onTap: () => onNavigate('announcements'),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (newNotificationsCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.elkablyRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$newNotificationsCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Today's Status Card
                    _buildCard(
                      title: "Today's Status",
                      child: Row(
                        children: [
                          // Attendance Status
                          Expanded(
                            child: _StatusItem(
                              icon: todayAttendance?.status == AttendanceStatus.present
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              iconColor: todayAttendance?.status == AttendanceStatus.present
                                  ? AppColors.success
                                  : AppColors.elkablyRed,
                              label: 'Attendance',
                              value: todayAttendance?.status == AttendanceStatus.present
                                  ? 'Present'
                                  : 'Absent',
                              valueColor: todayAttendance?.status == AttendanceStatus.present
                                  ? AppColors.success
                                  : AppColors.elkablyRed,
                            ),
                          ),

                          // Homework Status
                          Expanded(
                            child: _StatusItem(
                              icon: todayAttendance?.homeworkStatus == HomeworkStatus.done
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              iconColor: todayAttendance?.homeworkStatus == HomeworkStatus.done
                                  ? AppColors.success
                                  : AppColors.warning,
                              label: 'Homework',
                              value: todayAttendance?.homeworkStatus == HomeworkStatus.done
                                  ? 'Done'
                                  : 'Pending',
                              valueColor: todayAttendance?.homeworkStatus == HomeworkStatus.done
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats Card
                    _buildCard(
                      title: 'Quick Stats',
                      child: Column(
                        children: [
                          _StatRow(
                            icon: Icons.calendar_today,
                            iconBgColor: AppColors.elkablyRed.withValues(alpha: 0.2),
                            iconColor: AppColors.elkablyRed,
                            label: 'Total Absences',
                            value: '$totalAbsences',
                          ),
                          const SizedBox(height: 16),
                          _StatRow(
                            icon: Icons.book,
                            iconBgColor: AppColors.warning.withValues(alpha: 0.2),
                            iconColor: AppColors.warning,
                            label: 'Pending Assignments',
                            value: '$pendingAssignments',
                          ),
                          const SizedBox(height: 16),
                          _StatRow(
                            icon: Icons.emoji_events,
                            iconBgColor: AppColors.info.withValues(alpha: 0.2),
                            iconColor: AppColors.info,
                            label: 'Upcoming Exams',
                            value: '3',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recent Notifications Card
                    _buildCard(
                      title: 'Recent Notifications',
                      trailing: GestureDetector(
                        onTap: () => onNavigate('announcements'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.elkablyRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      child: Column(
                        children: recentNotifications.map((notification) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _NotificationItem(notification: notification),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _StatusItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.isNew)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: const BoxDecoration(
                color: AppColors.elkablyRed,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(notification.date),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM d, HH:mm').format(date);
  }
}

