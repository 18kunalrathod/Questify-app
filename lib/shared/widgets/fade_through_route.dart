import 'package:flutter/material.dart';

/// A shared page transition used across the whole app for consistency.
/// Combines a gentle fade with a slight upward slide — feels calmer
/// than the platform-default hard horizontal slide.
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeThroughRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}