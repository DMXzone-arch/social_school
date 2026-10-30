import 'package:flutter/material.dart';

/// App-wide theme state: light / dark / follow-system.
///
/// Also observes OS brightness changes so `ThemeMode.system` stays live.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase): persist the member's
/// preference in their profile row (`theme_mode` text) and merge it on
/// sign-in; until then the choice lives in memory for the session.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  ThemeController._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// True when the dark palette should be active for the given platform
  /// brightness — resolved by the app root before every rebuild so
  /// [AppColors] stays in sync with `MaterialApp.themeMode`.
  bool isDarkFor(Brightness platformBrightness) =>
      _mode == ThemeMode.dark ||
      (_mode == ThemeMode.system && platformBrightness == Brightness.dark);

  /// Current platform brightness (used by the app root).
  static Brightness get platformBrightness =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Convenience used by the settings toggle.
  void setDark(bool dark) => setMode(dark ? ThemeMode.dark : ThemeMode.light);

  bool get isDark => _mode == ThemeMode.dark;

  @override
  void didChangePlatformBrightness() => notifyListeners();
}
