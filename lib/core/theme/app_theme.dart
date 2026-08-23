import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ---------- DARK MODE ----------
  static const Color darkCanvas = Color(0xFF000000);
  static const Color darkCard = Color(0xFF0D0C0A);
  static const Color darkTextPrimary = Color(0xFFF3F1EA);
  static const Color darkTextMuted = Color(0xFF8A8578);
  static const Color glowCore = Color(0xFFFFA640);

  // ---------- LIGHT MODE ----------
  static const Color lightCanvas = Color(0xFFFBF8F2);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFEDE6D6);
  static const Color lightTextPrimary = Color(0xFF2B2620);
  static const Color lightTextMuted = Color(0xFFA39A85);
}

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
          borderRadius: BorderRadius.all(Radius.circular(16)),
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
      ),
    );
  }
}

class AppTextStyles {
  static TextStyle headline(BuildContext context, {double size = 20, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: -0.3,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  static TextStyle stat(BuildContext context, {double size = 22, FontWeight weight = FontWeight.w600, Color? color}) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }
}

BoxDecoration specularCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardTheme.color,
    borderRadius: BorderRadius.circular(16),
    border: Border(
      top: BorderSide(color: Colors.white.withOpacity(0.14)),
      left: BorderSide(color: Colors.white.withOpacity(0.08)),
      right: BorderSide(color: Colors.white.withOpacity(0.02)),
      bottom: BorderSide(color: Colors.white.withOpacity(0.02)),
    ),
  );
}