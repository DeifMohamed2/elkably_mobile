import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final bool isDarkMode;

  const NotificationItem({
    super.key,
    required this.notification,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? AppColors.surfaceBackground
                : AppColors.iconBackgroundLight,
        borderRadius: BorderRadius.circular(16),
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
                  style: TextStyle(
                    color:
                        isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(notification.date),
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
