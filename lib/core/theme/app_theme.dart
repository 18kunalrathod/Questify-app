import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All fixed design tokens (backgrounds, text, cards) that never change
/// regardless of which accent color the user picks.
class AppColors {
  // ---------- DARK MODE ----------
  static const Color darkCanvas = Color(0xFF0A0B0F);
  static const Color darkCard = Color(0xFF15171C);
  static const Color darkTextPrimary = Color(0xFFF4F5F7);
  static const Color darkTextMuted = Color(0xFF6E7280);

  // ---------- LIGHT MODE ----------
  static const Color lightCanvas = Color(0xFFF8F9FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
}

/// User-selectable accent colors. Each has a dark-mode and light-mode
/// variant so the accent still looks right regardless of theme.
enum AccentColor {
  gold(darkValue: Color(0xFFFFD400), lightValue: Color(0xFFFFAB00), label: 'Gold'),
  lime(darkValue: Color(0xFF00FF66), lightValue: Color(0xFF00C853), label: 'Lime'),
  cyan(darkValue: Color(0xFF00E5FF), lightValue: Color(0xFF00B0FF), label: 'Cyan'),
  violet(darkValue: Color(0xFF8A2BE2), lightValue: Color(0xFF7C4DFF), label: 'Violet');

  final Color darkValue;
  final Color lightValue;
  final String label;

  const AccentColor({
    required this.darkValue,
    required this.lightValue,
    required this.label,
  });
}

class AppTheme {
  static ThemeData darkTheme(AccentColor accent) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkCanvas,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.darkCard,
        primary: accent.darkValue,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData lightTheme(AccentColor accent) {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightCanvas,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.lightCard,
        primary: accent.lightValue,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}