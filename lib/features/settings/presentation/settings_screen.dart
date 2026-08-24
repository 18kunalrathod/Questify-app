import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart' show themeModeProvider;
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: AppTextStyles.headline(context, size: 18))),
      body: AmbientGlowBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionLabel('APPEARANCE', mutedColor),
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _SwitchRow(
                      label: 'Dark mode',
                      value: isDarkMode,
                      onChanged: (value) => ref.read(themeModeProvider.notifier).state = value ? ThemeMode.dark : ThemeMode.light,
                      showDivider: true,
                    ),
                    _NavRow(label: 'Accent color', trailing: 'Gold', onTap: () {}, showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _SectionLabel('NOTIFICATIONS', mutedColor),
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _SwitchRow(label: 'Daily quest reminders', value: true, onChanged: (_) {}, showDivider: true),
                    _SwitchRow(label: 'Streak warnings', value: true, onChanged: (_) {}, showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _SectionLabel('DATA', mutedColor),
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _NavRow(label: 'Export my data', onTap: () {}, showDivider: true),
                    _NavRow(label: 'Sync now', onTap: () {}, showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _SectionLabel('ACCOUNT', mutedColor),
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _NavRow(label: 'Change password', onTap: () {}, showDivider: true),
                    _NavRow(label: 'Sign out', onTap: () {}, isDestructive: true, showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(child: Text('Questify v1.0.0', style: TextStyle(color: mutedColor, fontSize: 11))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: TextStyle(fontSize: 10, letterSpacing: 1, color: color)),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _SwitchRow({required this.label, required this.value, required this.onChanged, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))) : null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Switch(value: value, onChanged: onChanged, activeColor: accent),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isDestructive;

  const _NavRow({required this.label, this.trailing, required this.onTap, required this.showDivider, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))) : null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: isDestructive ? Colors.redAccent : null)),
            Row(
              children: [
                if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 12, color: mutedColor)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: mutedColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}