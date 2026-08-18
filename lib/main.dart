import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// Holds the currently selected accent color.
/// Defaults to gold — our one locked accent for now.
final accentColorProvider = StateProvider<AccentColor>((ref) => AccentColor.gold);

/// Holds the current theme mode (light/dark/system).
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
  localizationsDelegates: quill.FlutterQuillLocalizations.localizationsDelegates,
  supportedLocales: quill.FlutterQuillLocalizations.supportedLocales,
  home: const SplashScreen(),
);
  }
}

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