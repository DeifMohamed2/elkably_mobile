import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class LoginScreen extends StatefulWidget {
  final void Function(UserRole role, String phone, String password) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.parent;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String get _roleTitle =>
      _selectedRole == UserRole.parent ? 'Parent' : 'Student';

  void _toggleRole(UserRole role) {
    if (_selectedRole != role) {
      setState(() {
        _selectedRole = role;
        _errorMessage = null;
      });
      _animationController.forward(from: 0.0);
    }
  }

  void _handleLogin() {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty) {
      setState(() {
        _errorMessage =
            _selectedRole == UserRole.parent
                ? 'Please enter your phone number'
                : 'Please enter your email or phone';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage =
            _selectedRole == UserRole.parent
                ? 'Please enter your student code'
                : 'Please enter your password';
      });
      return;
    }

    // Show loading
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onLogin(_selectedRole, phone, password);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.cardBackground : AppColors.cardBackgroundLight;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? Colors.white.withOpacity(0.9) : AppColors.textSecondaryLight;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[500];
    final inputBgColor = isDark ? AppColors.cardBackground : Colors.grey[100];
    final inputBorderColor = isDark ? AppColors.borderLight : Colors.grey[300];

    return Scaffold(
      body: Stack(
        children: [
          // Top Red Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
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
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Container(
                          width: 70,
                          height: 70,
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/images/logo-white-.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // School Name
                        const Text(
                          'Elkably',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom White Card Section
                Expanded(
                  flex: 7,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role Slider Switch
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: inputBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        inputBorderColor ?? Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _RoleToggleButton(
                                      label: 'Parent',
                                      icon: Icons.people_outline,
                                      isSelected:
                                          _selectedRole == UserRole.parent,
                                      onTap: () => _toggleRole(UserRole.parent),
                                    ),
                                    const SizedBox(width: 4),
                                    _RoleToggleButton(
                                      label: 'Student',
                                      icon: Icons.school_outlined,
                                      isSelected:
                                          _selectedRole == UserRole.student,
                                      onTap:
                                          () => _toggleRole(UserRole.student),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Welcome Text
                            Text(
                              'Welcome',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _selectedRole == UserRole.parent
                                  ? 'Track your child\'s progress'
                                  : 'View your academic progress',
                              style: TextStyle(color: hintColor, fontSize: 14),
                            ),
                            const SizedBox(height: 12),

                            // Error Message
                            if (_errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.elkablyRed.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.elkablyRed.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppColors.elkablyRed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: AppColors.elkablyRed,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // First Field Label (Phone Number for Parent, Email/Phone for Student)
                            Text(
                              _selectedRole == UserRole.parent
                                  ? 'Phone Number'
                                  : 'Email or Phone',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // First Field Input
                            TextFormField(
                              controller: _phoneController,
                              keyboardType:
                                  _selectedRole == UserRole.parent
                                      ? TextInputType.phone
                                      : TextInputType.emailAddress,
                              textDirection: TextDirection.ltr,
                              onChanged: (_) {
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText:
                                    _selectedRole == UserRole.parent
                                        ? '01xxxxxxxxx'
                                        : 'student@example.com or 01xxxxxxxxx',
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  _selectedRole == UserRole.parent
                                      ? Icons.phone_outlined
                                      : Icons.alternate_email,
                                  color: hintColor,
                                ),
                                filled: true,
                                fillColor: inputBgColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color:
                                        inputBorderColor ?? Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color:
                                        inputBorderColor ?? Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.elkablyRed,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.elkablyRed,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _selectedRole == UserRole.parent
                                      ? 'Please enter your phone number'
                                      : 'Please enter your email or phone';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Second Field Label (Student Code for Parent, Password for Student)
                            Text(
                              _selectedRole == UserRole.parent
                                  ? 'Student Code'
                                  : 'Password',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Second Field Input
                            TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.text,
                              textCapitalization:
                                  _selectedRole == UserRole.parent
                                      ? TextCapitalization.characters
                                      : TextCapitalization.none,
                              obscureText: _selectedRole == UserRole.student,
                              textDirection: TextDirection.ltr,
                              onChanged: (_) {
                                if (_errorMessage != null) {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                }
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: InputDecoration(
                                hintText:
                                    _selectedRole == UserRole.parent
                                        ? 'K1234'
                                        : '••••••••',
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 16,
                                ),
                                prefixIcon: Icon(
                                  _selectedRole == UserRole.parent
                                      ? Icons.badge_outlined
                                      : Icons.lock_outline,
                                  color: hintColor,
                                ),
                                filled: true,
                                fillColor: inputBgColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color:
                                        inputBorderColor ?? Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color:
                                        inputBorderColor ?? Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.elkablyRed,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.elkablyRed,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _selectedRole == UserRole.parent
                                      ? 'Please enter your student code'
                                      : 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.elkablyRed,
                                  disabledBackgroundColor: AppColors.elkablyRed
                                      .withValues(alpha: 0.6),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : const Text(
                                          'Login',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                              ),
                            ),
                          ],
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
    );
  }
}

// Role Toggle Button Widget
class _RoleToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.elkablyRed : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey[600]),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.grey[600]),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
