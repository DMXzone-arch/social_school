import 'package:flutter/material.dart';

/// Brand identity for Social School.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1769AA);
  static const Color teal = Color(0xFF16A085);
  static const Color gold = Color(0xFFF4B942);
  static const Color background = Color(0xFFF3F6FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF15803D);

  /// Facebook-style default avatar: light grey circle with a darker grey
  /// person silhouette, used whenever a user has no profile photo and no
  /// chosen avatar colour.
  static const Color avatarPlaceholderBackground = Color(0xFFD8DDE3);
  static const Color avatarPlaceholderForeground = Color(0xFF9AA4AF);

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
      'Social School is a learning community where students connect, '
      'get school updates, download study resources and discover '
      'scholarships and opportunities.';

  /// Shown across the prototype so demo behaviour is never mistaken for
  /// real server operations.
  static const String demoNotice =
      'Prototype build — every account, post, file and action is simulated '
      'demo data. Nothing is saved to a server.';

  static const String demoStudentEmail = 'student@demo.com';
  static const String demoAdminEmail = 'admin@demo.com';

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
