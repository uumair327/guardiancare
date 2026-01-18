import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app theme persistence
/// Follows Clean Architecture - Infrastructure layer service
/// Single Responsibility: Only handles theme storage operations
class ThemeService {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  /// Get saved theme mode from storage
  /// Returns null if no theme has been saved (uses system default)
  ThemeMode? getSavedThemeMode() {
    final themeValue = _prefs.getString(_themeKey);
    if (themeValue == null) return null;

    switch (themeValue) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  /// Save theme mode to storage
  Future<bool> saveThemeMode(ThemeMode mode) async {
    final themeValue = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return await _prefs.setString(_themeKey, themeValue);
  }

  /// Clear saved theme (will use system default)
  Future<bool> clearThemeMode() async {
    return await _prefs.remove(_themeKey);
  }

  /// Check if the current theme is dark
  /// Considers both explicit dark mode and system preference
  static bool isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }
}
