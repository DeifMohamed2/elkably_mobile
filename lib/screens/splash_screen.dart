import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _letterController;
  late AnimationController _dotsController;
  late AnimationController _themeButtonController;

  late Animation<double> _backgroundScale;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowScale;
  late Animation<double> _glowOpacity;
  late Animation<double> _themeButtonOpacity;

  final List<Animation<double>> _letterAnimations = [];
  final List<Animation<double>> _dotAnimations = [];

  @override
  void initState() {
    super.initState();

    // Background pulsing animation (infinite)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: false);

    _backgroundScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _backgroundOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.3), weight: 1),
    ]).animate(_backgroundController);

    // Logo animation (scale, rotation, opacity)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Cubic(0.34, 1.56, 0.64, 1), // Elastic ease-out
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoRotation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Logo floating animation (infinite, after initial animation)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _floatAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Glow animation (infinite)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: false);

    _glowScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(_glowController);

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.5), weight: 1),
    ]).animate(_glowController);

    // Letter animations (staggered)
    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    const letters = 7; // E L K A B L Y
    for (int i = 0; i < letters; i++) {
      final delay = 0.8 + (i * 0.1);
      final start = delay / 2.0;
      final end = (delay + 0.5) / 2.0;

      _letterAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _letterController,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: const Cubic(0.34, 1.56, 0.64, 1),
            ),
          ),
        ),
      );
    }

    // Loading dots animations (infinite, staggered)
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: false);

    for (int i = 0; i < 3; i++) {
      _dotAnimations.add(
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _dotsController,
            curve: Interval(
              (i * 0.2).clamp(0.0, 1.0),
              ((i * 0.2) + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeInOut,
            ),
          ),
        ),
      );
    }

    // Theme toggle button fade-in
    _themeButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _themeButtonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _themeButtonController, curve: Curves.easeOut),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _logoController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _letterController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _floatController.repeat(reverse: false);
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _dotsController.repeat(reverse: false);
      }
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _themeButtonController.forward();
      }
    });

    // Navigate after delay (can be adjusted)
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _floatController.dispose();
    _glowController.dispose();
    _letterController.dispose();
    _dotsController.dispose();
    _themeButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDarkMode
                    ? [
                      const Color(0xFF111827), // gray-900
                      const Color(0xFF1F2937), // gray-800
                      const Color(0xFF000000), // black
                    ]
                    : [
                      const Color(0xFFFEF2F2), // red-50
                      const Color(0xFFFFFFFF), // white
                      const Color(0xFFFEE2E2), // red-100
                    ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circle (only in dark mode)
            if (isDarkMode)
              Center(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _backgroundScale.value,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.elkablyRed
                                  .withOpacity(0.1)
                                  .withOpacity(_backgroundOpacity.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animations
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _floatController,
                      _glowController,
                    ]),
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect (only in dark mode)
                          if (isDarkMode)
                            Transform.scale(
                              scale: _glowScale.value,
                              child: Container(
                                width: 192,
                                height: 192,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.elkablyRed
                                          .withOpacity(0.2)
                                          .withOpacity(_glowOpacity.value),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Logo
                          Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Transform.rotate(
                              angle: _logoRotation.value * 3.14159,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 192,
                                    height: 192,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to icon if image not found
                                      return Container(
                                        width: 192,
                                        height: 192,
                                        decoration: BoxDecoration(
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : AppColors.elkablyRed,
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.school,
                                          size: 96,
                                          color:
                                              isDarkMode
                                                  ? AppColors.elkablyRed
                                                  : Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Brand Name with letter animations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(7, (index) {
                        const letters = ['E', 'L', 'K', 'A', 'B', 'L', 'Y'];
                        return AnimatedBuilder(
                          animation: _letterController,
                          builder: (context, child) {
                            final animation = _letterAnimations[index];
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - animation.value)),
                              child: Opacity(
                                opacity: animation.value.clamp(0.0, 1.0),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 700),
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : AppColors.elkablyRed,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                  child: Text(letters[index]),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading indicator with dots
                  FadeTransition(
                    opacity: _themeButtonOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _dotsController,
                          builder: (context, child) {
                            final animation = _dotAnimations[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Transform.scale(
                                scale: animation.value,
                                child: Opacity(
                                  opacity: (0.5 +
                                          (0.5 * (animation.value - 1.0).abs()))
                                      .clamp(0.0, 1.0),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.elkablyRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
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
