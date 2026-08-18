import 'package:flutter/material.dart';

/// Wraps a screen's content with a soft radial glow near the top,
/// using the app's current accent color. This is the app-wide
/// "signature" background treatment — applied once here, reused
/// on every screen instead of duplicated per-screen.
class AmbientGlowBackground extends StatelessWidget {
  final Widget child;

  const AmbientGlowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // The glow itself — sits behind everything, ignores touches.
        Positioned(
          top: -80,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    accent.withOpacity(0.16),
                    accent.withOpacity(0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.75],
                ),
              ),
            ),
          ),
        ),
        // The actual screen content, on top of the glow.
        child,
      ],
    );
  }
}