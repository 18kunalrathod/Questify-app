import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../onboarding/screen.dart';
import '../../../shared/widgets/fade_through_route.dart';
import '../../../shared/widgets/ambient_glow_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeThroughRoute(page: const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: AmbientGlowBackground(
        strong: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 72,
                color: accent,
              )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1, 1),
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              Text(
                'Questify',
                style: AppTextStyles.headline(context, size: 28),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),

              const SizedBox(height: 8),

              Text(
                'LEVEL UP YOUR LIFE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 2,
                      color: AppColors.darkTextMuted,
                    ),
              ).animate(delay: 900.ms).fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}