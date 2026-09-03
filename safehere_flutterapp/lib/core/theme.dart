import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens ported from the original warm-ivory / elegant-rose design language.
class AppColors {
  static const ivory = Color(0xFFFFFDF9);
  static const rose = Color(0xFFD96C8A);
  static const roseDark = Color(0xFFB84F6D);
  static const lavender = Color(0xFF9B8AFB);
  static const safe = Color(0xFF4CAF7D);
  static const warning = Color(0xFFE0A63A);
  static const emergency = Color(0xFFE24C6D);
  static const ink = Color(0xFF2B2230);
  static const inkSoft = Color(0xFF6E6470);
  static const cardBorder = Color(0xFFF1E6EA);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ivory,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.rose,
        secondary: AppColors.lavender,
        surface: Colors.white,
        error: AppColors.emergency,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ivory,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rose,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rose,
          side: const BorderSide(color: AppColors.rose),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );
  }
}
