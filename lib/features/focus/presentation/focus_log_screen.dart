import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import 'focus_log_tab.dart';

/// Standalone screen for the focus log, opened from the notebook icon on
/// the Focus tab.
class FocusLogScreen extends StatelessWidget {
  const FocusLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus log', style: AppTextStyles.headline(context, size: 18)),
      ),
      body: const AmbientGlowBackground(
        child: FocusLogTab(),
      ),
    );
  }
}