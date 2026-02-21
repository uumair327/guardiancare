import 'package:flutter/material.dart';

import 'package:guardiancare/core/responsive/responsive_breakpoints.dart';

/// Responsive utilities — extension on [BuildContext].
///
/// Usage:
/// ```dart
/// context.layout          // → ScreenLayout.desktop
/// context.isDesktop       // → true
/// context.screenWidth     // → 1024.0
/// context.responsiveValue(mobile: 1, tablet: 2, desktop: 3)
/// context.maxContentWidth // constrained to ResponsiveBreakpoints.maxContent
/// ```
extension ResponsiveContext on BuildContext {
  /// The device-independent pixel width of the screen.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The device-independent pixel height of the screen.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// The current [ScreenLayout] derived from [screenWidth].
  ScreenLayout get layout => ResponsiveBreakpoints.of(screenWidth);

  bool get isMobile => layout == ScreenLayout.mobile;
  bool get isTablet => layout == ScreenLayout.tablet;
  bool get isDesktop => layout == ScreenLayout.desktop;
  bool get isWidescreen => layout == ScreenLayout.widescreen;
  bool get isTabletOrLarger =>
      ResponsiveBreakpoints.isTabletOrLarger(screenWidth);
  bool get isDesktopOrLarger =>
      ResponsiveBreakpoints.isDesktopOrLarger(screenWidth);

  /// Returns the value matching the current layout, falling back to the
  /// nearest smaller layout value if no exact match is provided.
  ///
  /// ```dart
  /// final cols = context.responsiveValue(mobile: 1, desktop: 3);
  /// // tablet → 1 (falls back to mobile value)
  /// ```
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? widescreen,
  }) {
    switch (layout) {
      case ScreenLayout.widescreen:
        return widescreen ?? desktop ?? tablet ?? mobile;
      case ScreenLayout.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenLayout.tablet:
        return tablet ?? mobile;
      case ScreenLayout.mobile:
        return mobile;
    }
  }

  /// Horizontal screen padding — increases on larger screens for readability.
  double get responsivePaddingH => responsiveValue(
        mobile: 20,
        tablet: 40,
        desktop: 64,
        widescreen: 80,
      );

  /// The maximum usable content width — caps at [ResponsiveBreakpoints.maxContent].
  double get maxContentWidth => ResponsiveBreakpoints.maxContent;
}
