import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class BottomNav extends StatelessWidget {
  final AppScreen activeScreen;
  final void Function(AppScreen screen) onNavigate;

  const BottomNav({
    super.key,
    required this.activeScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(id: AppScreen.home, label: 'Home', icon: Icons.home),
      _NavItem(id: AppScreen.attendance, label: 'Attendance', icon: Icons.calendar_today),
      _NavItem(id: AppScreen.announcements, label: 'Announcements', icon: Icons.campaign),
      _NavItem(id: AppScreen.profile, label: 'Profile', icon: Icons.person),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = activeScreen == item.id;
              return GestureDetector(
                onTap: () => onNavigate(item.id),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 24,
                      color: isActive ? AppColors.elkablyRed : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? AppColors.elkablyRed : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
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
  final IconData icon;

  _NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

