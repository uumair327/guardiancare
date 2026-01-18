import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme-aware color extension for BuildContext
/// Follows SOLID principles:
/// - Single Responsibility: Provides theme-aware color access
/// - Open/Closed: Easy to extend without modifying existing code
/// - Dependency Inversion: Pages depend on theme abstraction, not hardcoded values
///
/// Usage:
/// ```dart
/// // Instead of: AppColors.textPrimary (hardcoded)
/// // Use: context.colors.textPrimary (theme-aware)
///
/// Text('Hello', style: TextStyle(color: context.colors.textPrimary))
/// Container(color: context.colors.background)
/// ```
extension ThemeColors on BuildContext {
  /// Get theme-aware colors based on current brightness
  ThemeColorScheme get colors => ThemeColorScheme(this);

  /// Quick access to check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// Theme color scheme that provides context-aware colors
class ThemeColorScheme {
  final BuildContext _context;

  const ThemeColorScheme(this._context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;
  ColorScheme get _colorScheme => Theme.of(_context).colorScheme;

  // ==================== Text Colors ====================

  /// Primary text color - adapts to theme
  Color get textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  /// Secondary text color - adapts to theme
  Color get textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

  /// Tertiary/hint text color - adapts to theme
  Color get textTertiary =>
      _isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

  /// Disabled text color
  Color get textDisabled => AppColors.textDisabled;

  // ==================== Background Colors ====================

  /// Main background color - adapts to theme
  Color get background =>
      _isDark ? AppColors.darkBackground : AppColors.background;

  /// Surface color (cards, dialogs) - adapts to theme
  Color get surface => _isDark ? AppColors.darkSurface : AppColors.surface;

  /// Surface variant - adapts to theme
  Color get surfaceVariant =>
      _isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

  /// Card background - adapts to theme
  Color get cardBackground =>
      _isDark ? AppColors.darkSurface : AppColors.cardBackground;

  // ==================== Icon Colors ====================

  /// Primary icon color - adapts to theme
  Color get iconPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.iconPrimary;

  /// Secondary icon color - adapts to theme
  Color get iconSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.iconSecondary;

  // ==================== Border & Divider Colors ====================

  /// Border color - adapts to theme
  Color get border => _isDark ? AppColors.gray700 : AppColors.border;

  /// Divider color - adapts to theme
  Color get divider => _isDark ? AppColors.gray700 : AppColors.divider;

  // ==================== Input Colors ====================

  /// Input background - adapts to theme
  Color get inputBackground =>
      _isDark ? AppColors.darkSurfaceVariant : AppColors.inputBackground;

  /// Input border - adapts to theme
  Color get inputBorder => _isDark ? AppColors.gray600 : AppColors.inputBorder;

  // ==================== Shimmer Colors ====================

  /// Shimmer base color - adapts to theme
  Color get shimmerBase =>
      _isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase;

  /// Shimmer highlight color - adapts to theme
  Color get shimmerHighlight =>
      _isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight;

  // ==================== Direct Theme Access ====================

  /// Direct access to colorScheme for Material colors
  ColorScheme get scheme => _colorScheme;

  /// Primary color (brand color)
  Color get primary => AppColors.primary;

  /// Primary dark color
  Color get primaryDark => AppColors.primaryDark;

  /// Error color
  Color get error => AppColors.error;

  /// Success color
  Color get success => AppColors.success;

  /// Warning color
  Color get warning => AppColors.warning;

  /// Info color
  Color get info => AppColors.info;
}
