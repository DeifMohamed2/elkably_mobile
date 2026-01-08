import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'providers/app_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and notifications
  await Firebase.initializeApp();
  await NotificationService.instance.initialize();

  // Set system UI overlay style for dark mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: ElkablyApp()));
}

class ElkablyApp extends ConsumerWidget {
  const ElkablyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    // Update system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDarkMode
                ? AppColors.surfaceBackground
                : AppColors.cardBackgroundLight,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Elkably',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends ConsumerStatefulWidget {
  const AppNavigator({super.key});

  @override
  ConsumerState<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends ConsumerState<AppNavigator> {
  bool _showSplash = true;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    debugPrint('[MAIN] Loading session...');
    await ref.read(authProvider.notifier).loadSession();
    setState(() {
      _isLoadingSession = false;
    });
    debugPrint('[MAIN] Session loading complete');
  }

  void _handleSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  void _handleLogin(String phone, String studentCode) {
    debugPrint('========== MAIN LOGIN HANDLER ==========');
    debugPrint('[MAIN] Login initiated');
    debugPrint('[MAIN] Phone: $phone');
    debugPrint('[MAIN] Student Code: $studentCode');

    () async {
      final success = await ref
          .read(authProvider.notifier)
          .loginParent(phone, studentCode);

      debugPrint('[MAIN] Login completed - Success: $success');

      if (success) {
        debugPrint('[MAIN] ✅ Navigating to Home screen');
        ref.read(currentScreenProvider.notifier).state = AppScreen.home;
      } else {
        debugPrint('[MAIN] ❌ Showing error snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Login failed. Check phone/code and try again.',
            ),
            backgroundColor: AppColors.elkablyRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }();
  }

  void _handleLogout() {
    () async {
      await ref.read(authProvider.notifier).logout();
    }();
  }

  void _handleNavigate(String screen) {
    final appScreen = AppScreen.values.firstWhere(
      (s) => s.name == screen,
      orElse: () => AppScreen.home,
    );

    ref.read(currentScreenProvider.notifier).state = appScreen;
  }

  void _handleBottomNavNavigate(AppScreen screen) {
    ref.read(currentScreenProvider.notifier).state = screen;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentScreen = ref.watch(currentScreenProvider);

    // Show loading while checking session
    if (_isLoadingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show Splash Screen
    if (_showSplash) {
      return SplashScreen(onComplete: _handleSplashComplete);
    }

    // Show Login Screen
    if (!authState.isLoggedIn) {
      return LoginScreen(onLogin: _handleLogin);
    }

    // Show Main App with Bottom Navigation
    return Scaffold(
      body: Stack(
        children: [
          _buildMainScreen(currentScreen),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(
              activeScreen: currentScreen,
              onNavigate: _handleBottomNavNavigate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.home:
        return HomeScreen(onNavigate: _handleNavigate);
      case AppScreen.attendance:
        return const AttendanceScreen();
      case AppScreen.announcements:
        return const AnnouncementsScreen();
      case AppScreen.profile:
        return ProfileScreen(
          onLogout: _handleLogout,
          onNavigate: _handleNavigate,
        );
      default:
        return HomeScreen(onNavigate: _handleNavigate);
    }
  }
}
