import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AmbientGlowBackground extends StatelessWidget {
  final Widget child;
  final bool strong;

  const AmbientGlowBackground({
    super.key,
    required this.child,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Positioned(
          top: -90,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: strong ? 280 : 220,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    AppColors.glowCore.withOpacity(strong ? 0.38 : 0.16),
                    accent.withOpacity(strong ? 0.15 : 0.06),
                    accent.withOpacity(0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.65, 0.8],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}