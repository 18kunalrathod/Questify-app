import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'shared/widgets/app_shell.dart';

/// Holds the currently selected accent color.
/// Defaults to gold — our one locked accent for now.
final accentColorProvider = StateProvider<AccentColor>((ref) => AccentColor.gold);

/// Holds the current theme mode (light/dark/system).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Global navigator key so the deep-link listener can push a screen from
/// anywhere in the app, not just from whatever widget happens to be on
/// screen when the link arrives.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lhahpoiiygszzqjsljlu.supabase.co',
    publishableKey: 'sb_publishable_6FgOUPg4AGKMUpPdVp0vBA_sX3G39Ms',
  );
  runApp(const ProviderScope(child: QuestifyApp()));
}

class QuestifyApp extends ConsumerStatefulWidget {
  const QuestifyApp({super.key});

  @override
  ConsumerState<QuestifyApp> createState() => _QuestifyAppState();
}

class _QuestifyAppState extends ConsumerState<QuestifyApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    // Handle the case where the app was launched cold, directly from tapping
    // the reset-password link (not already running in the background).
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingLink(initialUri);
      }
    } catch (_) {
      // No initial link, or platform doesn't support it — safe to ignore.
    }

    // Handle links arriving while the app is already running.
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    });
  }

  void _handleIncomingLink(Uri uri) {
    if (uri.host == 'reset-password') {
      _handlePasswordRecovery(uri);
    }
  }

  Future<void> _handlePasswordRecovery(Uri uri) async {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      if (!mounted) return;
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
      );
    } catch (e) {
      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That reset link is invalid or expired.')),
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Questify',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme(accent),
      darkTheme: AppTheme.darkTheme(accent),
      localizationsDelegates: quill.FlutterQuillLocalizations.localizationsDelegates,
      supportedLocales: quill.FlutterQuillLocalizations.supportedLocales,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final hasSession = Supabase.instance.client.auth.currentSession != null;
          return hasSession ? const AppShell() : const SplashScreen();
        },
      ),
    );
  }
}