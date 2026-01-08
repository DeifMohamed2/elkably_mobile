import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class RoleSelectionScreen extends StatelessWidget {
  final void Function(UserRole role) onSelectRole;

  const RoleSelectionScreen({super.key, required this.onSelectRole});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardBackground : AppColors.cardBackgroundLight;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Scaffold(
      body: Stack(
        children: [
          // Top Red Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE53935), // red-600
                  Color(0xFFEF5350), // red-500
                  Color(0xFFD32F2F), // red-700
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Section with Logo
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/images/logo-white-.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        //const SizedBox(height: 16),
                        // School Name
                        const Text(
                          'Elkably',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
                // Bottom White Card Section
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          // Parent Button
                          _RoleCard(
                            title: 'Parent',
                            subtitle: 'Track your child\'s progress',
                            icon: Icons.people_outline,
                            onTap: () => onSelectRole(UserRole.parent),
                            textColor: textColor,
                          ),
                          const SizedBox(height: 20),
                          // Student Button
                          _RoleCard(
                            title: 'Student',
                            subtitle: 'View your academic progress',
                            icon: Icons.school_outlined,
                            onTap: () => onSelectRole(UserRole.student),
                            textColor: textColor,
                          ),
                          const Spacer(),
                          // Footer
                          Center(
                            child: Text(
                              '© 2024 Elkably. All rights reserved',
                              style: TextStyle(
                                color: isDark ? AppColors.textMuted : Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color textColor;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.cardBackground : Colors.grey[100];
    final borderColor = isDark ? AppColors.borderLight : Colors.grey[300];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: borderColor!,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.elkablyRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.elkablyRed,
                ),
              ),
              const SizedBox(width: 20),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondary
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: AppColors.elkablyRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

