import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fixed design tokens — canvas, card, and text colors that stay the
/// same regardless of which accent color the user picks.
class AppColors {
  // ---------- DARK MODE ----------
  static const Color darkCanvas = Color(0xFF12110D);
  static const Color darkCard = Color(0xFF1B1913);
  static const Color darkTextPrimary = Color(0xFFF3F1EA);
  static const Color darkTextMuted = Color(0xFF8A8578);

  // ---------- LIGHT MODE ----------
  static const Color lightCanvas = Color(0xFFFBF8F2);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFEDE6D6);
  static const Color lightTextPrimary = Color(0xFF2B2620);
  static const Color lightTextMuted = Color(0xFFA39A85);
}

/// User-selectable accent color. Each has a dark-mode and light-mode
/// variant so the same accent choice looks correct in both themes.
enum AccentColor {
  gold(darkValue: Color(0xFFE8B84B), lightValue: Color(0xFFC8912E), label: 'Gold');

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
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
      ),
    );
  }
}