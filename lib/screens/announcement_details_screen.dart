import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class AnnouncementDetailsScreen extends ConsumerWidget {
  final AppNotification notification;

  const AnnouncementDetailsScreen({super.key, required this.notification});

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.attendance:
        return Icons.cancel_outlined;
      case NotificationType.assignment:
      case NotificationType.homework:
        return Icons.book_outlined;
      case NotificationType.fee:
      case NotificationType.payment:
        return Icons.credit_card_outlined;
      case NotificationType.grade:
        return Icons.emoji_events_outlined;
      case NotificationType.message:
      case NotificationType.custom:
        return Icons.message_outlined;
      case NotificationType.block:
      case NotificationType.unblock:
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.attendance:
        return AppColors.elkablyRed;
      case NotificationType.assignment:
      case NotificationType.homework:
        return AppColors.info;
      case NotificationType.fee:
      case NotificationType.payment:
        return AppColors.warning;
      case NotificationType.grade:
        return AppColors.success;
      case NotificationType.message:
      case NotificationType.custom:
        return const Color(0xFFA855F7);
      case NotificationType.block:
        return const Color(0xFFEF4444);
      case NotificationType.unblock:
        return const Color(0xFF10B981);
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  String _getNotificationTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.attendance:
        return 'Absent';
      case NotificationType.assignment:
        return 'Assignment';
      case NotificationType.homework:
        return 'Homework';
      case NotificationType.fee:
        return 'Fee';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.grade:
        return 'Grade';
      case NotificationType.message:
        return 'Message';
      case NotificationType.custom:
        return 'Custom';
      case NotificationType.block:
        return 'Blocked';
      case NotificationType.unblock:
        return 'Unblocked';
      case NotificationType.general:
        return 'General';
    }
  }

  // Determine attendance status from description
  Map<String, dynamic> _getAttendanceInfo() {
    final desc = notification.description.toLowerCase();

    if (notification.type == NotificationType.attendance) {
      // Check for "present" or "late" in description
      if (desc.contains('present')) {
        return {
          'icon': Icons.check_circle_outlined,
          'color': AppColors.success,
          'label': 'Present',
        };
      } else if (desc.contains('late')) {
        return {
          'icon': Icons.access_time_outlined,
          'color': AppColors.warning,
          'label': 'Late',
        };
      }
      // Default to absent
      return {
        'icon': Icons.cancel_outlined,
        'color': AppColors.elkablyRed,
        'label': 'Absent',
      };
    }

    // For non-attendance notifications, use default
    return {
      'icon': _getNotificationIcon(notification.type),
      'color': _getNotificationColor(notification.type),
      'label': _getNotificationTypeLabel(notification.type),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final date = DateTime.parse(notification.date);

    // Get attendance-aware icon, color, and label
    final attendanceInfo = _getAttendanceInfo();
    final iconColor = attendanceInfo['color'] as Color;
    final icon = attendanceInfo['icon'] as IconData;
    final typeLabel = attendanceInfo['label'] as String;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppColors.surfaceBackground
              : AppColors.surfaceBackgroundLight,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.elkablyRed,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Notification Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                children: [
                  // Icon and Type Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.cardBackground : Colors.white,
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
                      children: [
                        // Large Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? iconColor.withValues(alpha: 0.2)
                                    : iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 64, color: iconColor),
                        ),
                        const SizedBox(height: 20),

                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? iconColor.withValues(alpha: 0.2)
                                    : iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          notification.title,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.cardBackground : Colors.white,
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
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Details',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          notification.description,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondaryLight,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timing Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.cardBackground : Colors.white,
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
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Timing',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sent Date:',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'EEEE, d MMMM yyyy - h:mm a',
                              ).format(date),
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? AppColors.cardBackground : Colors.white,
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            color: AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.isNew ? 'Unread' : 'Read',
                              style: TextStyle(
                                color:
                                    notification.isNew
                                        ? AppColors.warning
                                        : AppColors.success,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
