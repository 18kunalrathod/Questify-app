import 'package:flutter/material.dart';

/// Temporary stand-in for the real Dashboard screen, which we haven't
/// built yet. Exists only so the Splash Screen has somewhere to go.
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Dashboard (coming soon)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}