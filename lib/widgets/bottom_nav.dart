import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class BottomNav extends ConsumerWidget {
  final AppScreen activeScreen;
  final void Function(AppScreen screen) onNavigate;

  const BottomNav({
    super.key,
    required this.activeScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    final navItems = [
      _NavItem(id: AppScreen.home, label: 'Home', iconPath: 'assets/icons/home.png'),
      _NavItem(
        id: AppScreen.attendance,
        label: 'Attendance',
        iconPath: 'assets/icons/attendence.png',
      ),
      _NavItem(
        id: AppScreen.announcements,
        label: 'Notifications',
        iconPath: 'assets/icons/notification.png',
      ),
      _NavItem(id: AppScreen.profile,
      label: 'Profile',
        iconPath: 'assets/icons/profile.png'),
    ];

    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? AppColors.surfaceBackground
                : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                navItems.map((item) {
                  final isActive = activeScreen == item.id;
                  return GestureDetector(
                    onTap: () => onNavigate(item.id),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? AppColors.elkablyRed.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: item.iconPath != null
                              ? Image.asset(
                                  item.iconPath!,
                                  width: 20,
                                  height: 20,
                                  color: isActive
                                      ? AppColors.elkablyRed
                                      : (isDarkMode
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight),
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color:
                                isActive
                                    ? AppColors.elkablyRed
                                    : (isDarkMode
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight),
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final AppScreen id;
  final String label;
  final String? iconPath;

  _NavItem({
    required this.id,
    required this.label,
    this.iconPath,
  });
}
