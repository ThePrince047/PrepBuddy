import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.background,
      primaryColor: AppColors.dark.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.primary,
        secondary: AppColors.dark.secondary,
        surface: AppColors.dark.surface,
        error: AppColors.dark.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.dark.textPrimary,
        onError: Colors.white,
        background: AppColors.dark.background,
        onBackground: AppColors.dark.textPrimary,
      ),
      extensions: const [AppColors.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.background,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.dark.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.dark.textPrimary,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.dark.textPrimary),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.dark.textPrimary),
        displayMedium: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.dark.textPrimary),
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.dark.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 18, color: AppColors.dark.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 16, color: AppColors.dark.textPrimary),
        bodySmall: GoogleFonts.inter(fontSize: 14, color: AppColors.dark.textSecondary),
        labelSmall: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.dark.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.surfaceGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.dark.border, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.background,
      primaryColor: AppColors.light.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.light.primary,
        secondary: AppColors.light.secondary,
        surface: AppColors.light.surface,
        error: AppColors.light.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.light.textPrimary,
        onError: Colors.white,
        background: AppColors.light.background,
        onBackground: AppColors.light.textPrimary,
      ),
      extensions: const [AppColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light.background,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.light.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.light.textPrimary,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.light.textPrimary),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.light.textPrimary),
        displayMedium: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: AppColors.light.textPrimary),
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.light.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 18, color: AppColors.light.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 16, color: AppColors.light.textPrimary),
        bodySmall: GoogleFonts.inter(fontSize: 14, color: AppColors.light.textSecondary),
        labelSmall: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.light.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.light.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.2);
            }
            return null;
          }),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.surface,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: AppColors.light.border, width: 1),
        ),
      ),
    );
  }
}
