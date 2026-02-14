import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guardiancare/core/services/theme_service.dart';

/// Abstract interface for theme management
/// Follows Single Responsibility Principle - only manages app theme
abstract class ThemeManager {
  /// Current application theme mode
  ThemeMode get currentThemeMode;

  /// Stream of theme changes for reactive updates
  Stream<ThemeMode> get themeChanges;

  /// Change the application theme mode
  void changeTheme(ThemeMode newMode);

  /// Toggle between light and dark themes
  /// If currently using system theme, switches to light
  void toggleTheme();

  /// Load saved theme from storage
  Future<void> loadSavedTheme();

  /// Dispose resources
  void dispose();
}

/// Implementation of ThemeManager
/// Manages application theme and delegates persistence to ThemeService
class ThemeManagerImpl implements ThemeManager {

  ThemeManagerImpl({
    required ThemeService themeService,
    ThemeMode defaultThemeMode = ThemeMode.system,
  })  : _themeService = themeService,
        _currentThemeMode = defaultThemeMode {
    debugPrint(
        'ThemeManager initialized with default theme: $_currentThemeMode');
  }
  final ThemeService _themeService;
  final StreamController<ThemeMode> _themeController =
      StreamController<ThemeMode>.broadcast();

  ThemeMode _currentThemeMode;

  @override
  ThemeMode get currentThemeMode => _currentThemeMode;

  @override
  Stream<ThemeMode> get themeChanges => _themeController.stream;

  @override
  void changeTheme(ThemeMode newMode) {
    debugPrint('ThemeManager: Changing theme to $newMode');

    // Update current theme
    _currentThemeMode = newMode;

    // Notify listeners
    _themeController.add(newMode);

    // Persist to storage
    _themeService.saveThemeMode(newMode);

    debugPrint('ThemeManager: Theme changed to $_currentThemeMode');
  }

  @override
  void toggleTheme() {
    final newMode = switch (_currentThemeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system =>
        ThemeMode.light, // Default to light when toggling from system
    };
    changeTheme(newMode);
  }

  @override
  Future<void> loadSavedTheme() async {
    final savedTheme = _themeService.getSavedThemeMode();
    debugPrint(
        'ThemeManager: Loading saved theme: ${savedTheme?.name ?? "none (using default)"}');

    if (savedTheme != null) {
      _currentThemeMode = savedTheme;
      _themeController.add(savedTheme);
      debugPrint('ThemeManager: Loaded theme: $_currentThemeMode');
    }
  }

  @override
  void dispose() {
    _themeController.close();
    debugPrint('ThemeManager disposed');
  }
}
