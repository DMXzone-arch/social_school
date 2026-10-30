import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

export '../constants/app_constants.dart' show AppColors, AppConstants;

/// Material theme built from the Social School brand palette.
///
/// Both themes pin their colours explicitly (rather than reading the
/// adaptive [AppColors] getters) so each one is guaranteed internally
/// consistent regardless of which palette the global flag currently serves.
class AppTheme {
  AppTheme._();

  // Light palette -----------------------------------------------------------
  static const Color _lightBackground = Color(0xFFF3F6FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1F2937);
  static const Color _lightBorder = Color(0xFFE2E8F0);

  // Dark palette (Facebook-style charcoal) -----------------------------------
  static const Color _darkBackground = Color(0xFF18191A);
  static const Color _darkSurface = Color(0xFF242526);
  static const Color _darkTextPrimary = Color(0xFFE4E6EB);
  static const Color _darkBorder = Color(0xFF3A3B3C);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.teal,
      error: AppColors.error,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      outline: _lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      fontFamily: 'Roboto',
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _lightTextPrimary,
        contentTextStyle: TextStyle(color: _lightSurface),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.teal,
      error: AppColors.error,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      outline: _darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      fontFamily: 'Roboto',
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkTextPrimary,
        contentTextStyle: TextStyle(color: _darkBackground),
      ),
    );
  }
}
