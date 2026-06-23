import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceGlass;
  final Color border;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color codePanel;
  final Color textPrimary;
  final Color textSecondary;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceGlass,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.codePanel,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const AppColors dark = AppColors(
    background: Color(0xFF0C0C0C), // True matt black
    surface: Color(0xFF141414),    // Slightly lifted surface
    surfaceGlass: Color(0x12FFFFFF), // Subtle glass
    border: Color(0x18FFFFFF),     // Very subtle border
    primary: Color(0xFF7C6EFF),    // Muted violet - less harsh
    secondary: Color(0xFF00C8F0),  // Cool cyan
    success: Color(0xFF22C55E),    // Green
    warning: Color(0xFFF59E0B),    // Amber
    error: Color(0xFFEF4444),      // Red
    codePanel: Color(0xFF111111),  // Code block background
    textPrimary: Color(0xFFDDDAEA),
    textSecondary: Color(0xFF7A7888),
  );

  static const AppColors light = AppColors(
    background: Color(0xFFF0F2F8),   // Soft blue-grey bg
    surface: Color(0xFFFFFFFF),       // Pure white cards
    surfaceGlass: Color(0xCCFFFFFF), // Strong glass
    border: Color(0x22000000),        // Visible border
    primary: Color(0xFF5B4EFF),       // Deep violet
    secondary: Color(0xFF0099CC),     // Deep cyan
    success: Color(0xFF16A34A),       // Darker green
    warning: Color(0xFFD97706),       // Darker amber
    error: Color(0xFFDC2626),         // Darker red
    codePanel: Color(0xFFEEF0F7),    // Light code bg
    textPrimary: Color(0xFF0F0E20),  // Near-black text
    textSecondary: Color(0xFF52506B), // Medium grey-purple
  );

  @override
  ThemeExtension<AppColors> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceGlass,
    Color? border,
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? codePanel,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      codePanel: codePanel ?? this.codePanel,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      codePanel: Color.lerp(codePanel, other.codePanel, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
