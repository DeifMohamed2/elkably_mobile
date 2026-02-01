import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;
  final void Function(String screen) onNavigate;

  const ProfileScreen({
    super.key,
    required this.onLogout,
    required this.onNavigate,
  });

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.elkablyRed,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'This action cannot be undone. All your data will be permanently deleted, including:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 12),
              _DeleteWarningItem(text: 'Your profile information'),
              _DeleteWarningItem(text: 'Linked student data'),
              _DeleteWarningItem(text: 'Payment history'),
              _DeleteWarningItem(text: 'All notifications'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.elkablyRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type "DELETE" to confirm account deletion:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type DELETE',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.elkablyRed),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (confirmController.text.toUpperCase() == 'DELETE') {
                  Navigator.of(context).pop();
                  _performAccountDeletion(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please type DELETE to confirm'),
                      backgroundColor: AppColors.elkablyRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.elkablyRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm Delete'),
            ),
          ],
        );
      },
    );
  }

  void _performAccountDeletion(BuildContext context) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: AppColors.cardBackground,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.elkablyRed),
              ),
              SizedBox(height: 16),
              Text(
                'Deleting your account...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );

    // Simulate API call for account deletion
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your account has been deleted successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Logout and navigate to login
      onLogout();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppColors.surfaceBackground
              : AppColors.surfaceBackgroundLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Parent Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: isDarkMode ? 0.1 : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? AppColors.elkablyRed
                                        : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 32,
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : AppColors.elkablyRed,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parent',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Linked Students Section
                  Text(
                    'Linked Students',
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Display all students
                  ...students
                      .map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
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
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode
                                            ? null
                                            : AppColors.iconBackgroundLight,
                                    gradient:
                                        isDarkMode
                                            ? const LinearGradient(
                                              colors: [
                                                Color(0xFF3B82F6),
                                                Color(0xFFA855F7),
                                              ],
                                            )
                                            : null,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      student.name[0],
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : AppColors.elkablyRed,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : AppColors.textPrimaryLight,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${student.grade} • ${student.studentClass}',
                                        style: TextStyle(
                                          color:
                                              isDarkMode
                                                  ? AppColors.textSecondary
                                                  : AppColors
                                                      .textSecondaryLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 24),

                  // Settings Section
                  Text(
                    'Settings',
                    style: TextStyle(
                      color:
                          isDarkMode
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
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
                        _ThemeToggleItem(ref: ref),
                        Divider(
                          height: 1,
                          color:
                              isDarkMode
                                  ? AppColors.borderLight
                                  : AppColors.borderLightTheme,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.language_outlined,
                                color:
                                    isDarkMode
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Language',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : AppColors.textPrimaryLight,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                'English',
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
                        ),
                        Divider(
                          height: 1,
                          color:
                              isDarkMode
                                  ? AppColors.borderLight
                                  : AppColors.borderLightTheme,
                        ),
                        _SettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Policy',
                          onTap: () async {
                            final Uri url = Uri.parse(
                              'https://mobile-privacy-policiy-elkably.onrender.com',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  GestureDetector(
                    onTap: onLogout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.elkablyRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.elkablyRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: AppColors.elkablyRed,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: AppColors.elkablyRed,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delete Account Button
                  GestureDetector(
                    onTap: () => _showDeleteAccountDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDarkMode
                                  ? AppColors.textMuted
                                  : AppColors.textMutedLight)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_forever_outlined,
                            color:
                                isDarkMode
                                    ? AppColors.textMuted
                                    : AppColors.textMutedLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? AppColors.textMuted
                                      : AppColors.textMutedLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Version
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Elkably Platform v1.0.0',
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? AppColors.textMuted
                                    : AppColors.textMutedLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© 2025 All rights reserved',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteWarningItem extends StatelessWidget {
  final String text;

  const _DeleteWarningItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.remove, color: AppColors.elkablyRed, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleItem extends ConsumerWidget {
  final WidgetRef ref;

  const _ThemeToggleItem({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color:
                isDarkMode
                    ? AppColors.textSecondary
                    : AppColors.textSecondaryLight,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              ref.read(isDarkModeProvider.notifier).toggleTheme(value);
            },
            activeColor: AppColors.elkablyRed,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isDarkMode
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color:
                  isDarkMode
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
