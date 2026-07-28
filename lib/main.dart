import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';

/// Holds the currently selected accent color. Later this will load/save
/// from shared_preferences so the choice persists between app launches.
final accentColorProvider = StateProvider<AccentColor>((ref) => AccentColor.gold);

/// Holds the current theme mode (system/light/dark).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

void main() {
  runApp(const ProviderScope(child: QuestifyApp()));
}

class QuestifyApp extends ConsumerWidget {
  const QuestifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Questify',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme(accent),
      darkTheme: AppTheme.darkTheme(accent),
      home: const _TempHomePlaceholder(),
    );
  }
}

/// Temporary placeholder screen — will be replaced by the real
/// Splash Screen in the next step.
class _TempHomePlaceholder extends StatelessWidget {
  const _TempHomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Questify',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}