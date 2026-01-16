import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color voidBlack = Color(0xFF000000);
  static const Color glassWhite = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.1)
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color signalGreen = Color(0xFF22C55E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x66FFFFFF); // text-white/40
  static const Color mutedGray = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.voidBlack,
      primaryColor: AppColors.signalGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.signalGreen,
        surface: AppColors.voidBlack,
      ),
      textTheme: TextTheme(
        bodyMedium: AppTextStyles.body,
        titleLarge: AppTextStyles.header,
        bodySmall: AppTextStyles.caption,
      ),
    );
  }
}

class AppTextStyles {
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get header => GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 10,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );
}
