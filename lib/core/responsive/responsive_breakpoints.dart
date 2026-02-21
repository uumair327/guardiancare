/// Screen layout classification.
/// Add a new value here if you need a new breakpoint (e.g. ultraWide).
enum ScreenLayout {
  /// < 600 dp — phones in portrait
  mobile,

  /// 600–899 dp — phones in landscape, small tablets
  tablet,

  /// 900–1199 dp — large tablets, small desktops
  desktop,

  /// ≥ 1200 dp — wide-screen desktops
  widescreen,
}

/// Breakpoint values (aligned with [AppDimensions]).
abstract final class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 900;
  static const double widescreen = 1200;

  /// Maximum readable content width (centres content on very wide screens).
  static const double maxContent = 1200;
  static const double maxContentNarrow = 720;

  /// Classify a given [width] into a [ScreenLayout].
  static ScreenLayout of(double width) {
    if (width >= widescreen) return ScreenLayout.widescreen;
    if (width >= desktop) return ScreenLayout.desktop;
    if (width >= tablet) return ScreenLayout.tablet;
    return ScreenLayout.mobile;
  }

  /// Returns true if [width] is larger than mobile.
  static bool isTabletOrLarger(double width) => width >= tablet;

  /// Returns true if [width] is desktop or wider.
  static bool isDesktopOrLarger(double width) => width >= desktop;
}
