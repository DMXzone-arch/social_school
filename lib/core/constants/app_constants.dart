import 'package:flutter/material.dart';

/// Brand identity for Social School.
///
/// Theme-aware palette: the fixed brand colours ([primary], [teal], [gold],
/// [error], [success], [white]) are identical in both themes, while the
/// semantic colours ([background], [surface], [textPrimary], [textSecondary],
/// [border] and the avatar placeholders) resolve against the active theme.
///
/// [AppColors.setDarkMode] must be called by the app root (see
/// `ThemeController`) before rebuilding the tree whenever the theme flips.
///
/// FUTURE BACKEND INTEGRATION POINT: none — palette stays client-side.
class AppColors {
  AppColors._();

  static bool _dark = false;

  /// Flips the semantic colours between the light and dark palettes.
  static void setDarkMode(bool dark) => _dark = dark;

  /// True when the dark palette is active.
  static bool get isDark => _dark;

  // Fixed brand colours (theme-independent) ------------------------------
  static const Color primary = Color(0xFF1769AA);
  static const Color teal = Color(0xFF16A085);
  static const Color gold = Color(0xFFF4B942);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF15803D);

  /// Always-true white, for content drawn ON brand/coloured surfaces.
  /// Cards and other theme surfaces use [surface] instead.
  static const Color white = Color(0xFFFFFFFF);

  // Semantic colours (flip with the theme) -------------------------------
  static Color get background =>
      _dark ? const Color(0xFF18191A) : const Color(0xFFF3F6FA);
  static Color get surface =>
      _dark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
  static Color get textPrimary =>
      _dark ? const Color(0xFFE4E6EB) : const Color(0xFF1F2937);
  static Color get textSecondary =>
      _dark ? const Color(0xFFB0B3B8) : const Color(0xFF64748B);
  static Color get border =>
      _dark ? const Color(0xFF3A3B3C) : const Color(0xFFE2E8F0);

  /// Facebook-style default avatar: light grey circle with a darker grey
  /// person silhouette, used whenever a user has no profile photo and no
  /// chosen avatar colour.
  static Color get avatarPlaceholderBackground =>
      _dark ? const Color(0xFF3A3B3C) : const Color(0xFFD8DDE3);
  static Color get avatarPlaceholderForeground =>
      _dark ? const Color(0xFF8A8D91) : const Color(0xFF9AA4AF);

  /// Palette used to derive deterministic avatar colours.
  static const List<Color> avatarPalette = [
    primary,
    teal,
    Color(0xFFB45309),
    Color(0xFF6D28D9),
    Color(0xFFBE185D),
    Color(0xFF0369A1),
    Color(0xFF15803D),
    Color(0xFF7C3AED),
  ];
}

/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Social School';
  static const String tagline = 'Learn together. Connect. Grow.';
  static const String description =
      'Social School is a learning community where members connect, '
      'get school updates, download study resources and discover '
      'scholarships and opportunities.';

  /// Shown across the prototype so demo behaviour is never mistaken for
  /// real server operations.
  static const String demoNotice =
      'Prototype build — every account, post, file and action is simulated '
      'demo data. Nothing is saved to a server.';

  static const String demoStudentEmail = 'student@demo.com';

  /// All districts and cities of Malawi, grouped by region in the labels used
  /// by the location picker.
  static const List<String> malawiDistricts = [
    // Northern Region
    'Chitipa',
    'Karonga',
    'Likoma',
    'Mzimba',
    'Nkhata Bay',
    'Rumphi',
    'Mzuzu City',
    // Central Region
    'Dedza',
    'Dowa',
    'Kasungu',
    'Lilongwe',
    'Mchinji',
    'Nkhotakota',
    'Ntcheu',
    'Ntchisi',
    'Salima',
    'Lilongwe City',
    // Southern Region
    'Balaka',
    'Blantyre',
    'Chikwawa',
    'Chiradzulu',
    'Machinga',
    'Mangochi',
    'Mwanza',
    'Neno',
    'Nsanje',
    'Phalombe',
    'Thyolo',
    'Zomba',
    'Blantyre City',
    'Zomba City',
  ];

  // Layout breakpoints (px).
  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
  static const double contentMaxWidth = 900;
}
