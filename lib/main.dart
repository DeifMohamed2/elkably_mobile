import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'providers/app_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/fees_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for dark mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surfaceBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: ElkablyApp(),
    ),
  );
}

class ElkablyApp extends StatelessWidget {
  const ElkablyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elkably',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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
  bool _showRoleSelection = false;

  void _handleSplashComplete() {
    setState(() {
      _showSplash = false;
      _showRoleSelection = true;
    });
  }

  void _handleRoleSelect(UserRole role) {
    ref.read(authProvider.notifier).selectRole(role);
    setState(() {
      _showRoleSelection = false;
    });
  }

  // Valid credentials
  static const String _validPhone = '01146101514';
  static const String _validPassword = '1qaz2wsx';

  void _handleLogin(String phone, String password) {
    // Validate credentials
    if (phone == _validPhone && password == _validPassword) {
      ref.read(authProvider.notifier).login();
      ref.read(currentScreenProvider.notifier).state = AppScreen.home;
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid phone number or password'),
          backgroundColor: AppColors.elkablyRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    setState(() {
      _showRoleSelection = true;
    });
  }

  void _handleNavigate(String screen) {
    final appScreen = AppScreen.values.firstWhere(
      (s) => s.name == screen,
      orElse: () => AppScreen.home,
    );
    
    // Use Navigator.push for detail screens
    if (appScreen == AppScreen.assignments ||
        appScreen == AppScreen.fees ||
        appScreen == AppScreen.grades) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _buildDetailScreen(appScreen),
        ),
      );
    } else {
      ref.read(currentScreenProvider.notifier).state = appScreen;
    }
  }

  void _handleBottomNavNavigate(AppScreen screen) {
    ref.read(currentScreenProvider.notifier).state = screen;
  }

  Widget _buildDetailScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.assignments:
        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.cardBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const AssignmentsScreen(),
        );
      case AppScreen.fees:
        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.cardBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const FeesScreen(),
        );
      case AppScreen.grades:
        return Scaffold(
          backgroundColor: AppColors.surfaceBackground,
          appBar: AppBar(
            backgroundColor: AppColors.cardBackground,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const GradesScreen(),
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentScreen = ref.watch(currentScreenProvider);

    // Show Splash Screen
    if (_showSplash) {
      return SplashScreen(onComplete: _handleSplashComplete);
    }

    // Show Role Selection Screen
    if (_showRoleSelection) {
      return RoleSelectionScreen(onSelectRole: _handleRoleSelect);
    }

    // Show Login Screen
    if (!authState.isLoggedIn) {
      return LoginScreen(
        onLogin: _handleLogin,
        role: authState.selectedRole ?? UserRole.parent,
      );
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
      case AppScreen.assignments:
        return const AssignmentsScreen();
      case AppScreen.fees:
        return const FeesScreen();
      case AppScreen.grades:
        return const GradesScreen();
      default:
        return HomeScreen(onNavigate: _handleNavigate);
    }
  }
}
