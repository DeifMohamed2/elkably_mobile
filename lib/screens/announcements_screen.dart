import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import 'announcement_details_screen.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen loads
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).fetchNotifications();
    });
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.attendance:
        return Icons.calendar_today_outlined;
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
        return const Color(0xFFA855F7); // Purple
      case NotificationType.block:
        return const Color(0xFFEF4444); // Red
      case NotificationType.unblock:
        return const Color(0xFF10B981); // Green
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationsProvider);
    final notifications = notifState.notifications;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final learningMode = ref.watch(learningModeProvider);
    final unreadCount = notifications.where((n) => n.isNew).length;

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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  children: [
                    // Title with Logout button (for online mode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (learningMode == 'online')
                          const SizedBox(width: 40),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (learningMode == 'online')
                          IconButton(
                            onPressed: () async {
                              // Logout
                              await ref.read(authProvider.notifier).logout();
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Logout',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notification count and Mark all as read
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 12,
                      ),
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withValues(alpha: 0.2),
                      //   borderRadius: BorderRadius.circular(16),
                      // ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$unreadCount new notification(s)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              // Mark all notifications as read
                              await ref
                                  .read(notificationsProvider.notifier)
                                  .markAllAsRead();

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'All notifications marked as read',
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.done_all,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Mark all as read',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child:
                notifState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifState.error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.elkablyRed,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            notifState.error!,
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .refresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.elkablyRed,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : notifications.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off,
                            size: 48,
                            color:
                                isDarkMode
                                    ? AppColors.textMuted
                                    : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No notifications',
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
                    )
                    : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(notificationsProvider.notifier)
                            .refresh();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _NotificationCard(
                              notification: notification,
                              icon: _getNotificationIcon(notification.type),
                              iconColor: _getNotificationColor(
                                notification.type,
                              ),
                              isDarkMode: isDarkMode,
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final AppNotification notification;
  final IconData icon;
  final Color iconColor;
  final bool isDarkMode;

  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.iconColor,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(notification.date);

    return GestureDetector(
      onTap: () {
        // Mark as read if it's new
        if (notification.isNew) {
          ref.read(notificationsProvider.notifier).markAsRead(notification.id);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    AnnouncementDetailsScreen(notification: notification),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? iconColor.withValues(alpha: 0.2)
                        : AppColors.iconBackgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (notification.isNew)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.description,
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (notification.studentName != null)
                        Text(
                          '${notification.studentName} (${notification.studentCode})',
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.textMuted
                                    : AppColors.textMutedLight,
                            fontSize: 12,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d, HH:mm').format(date),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
