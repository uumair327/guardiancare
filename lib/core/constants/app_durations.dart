/// Centralized duration and timing constants
/// Following Clean Architecture principles - Core layer
class AppDurations {
  AppDurations._();

  // ==================== Animation Durations ====================
  
  /// Very short animation - 100ms
  static const Duration animationVeryShort = Duration(milliseconds: 100);
  
  /// Short animation - 200ms
  static const Duration animationShort = Duration(milliseconds: 200);
  
  /// Medium animation - 300ms
  static const Duration animationMedium = Duration(milliseconds: 300);
  
  /// Long animation - 500ms
  static const Duration animationLong = Duration(milliseconds: 500);
  
  /// Very long animation - 800ms
  static const Duration animationVeryLong = Duration(milliseconds: 800);

  // ==================== Snackbar Durations ====================
  
  /// Short snackbar - 2 seconds
  static const Duration snackbarShort = Duration(seconds: 2);
  
  /// Medium snackbar - 3 seconds
  static const Duration snackbarMedium = Duration(seconds: 3);
  
  /// Long snackbar - 5 seconds
  static const Duration snackbarLong = Duration(seconds: 5);

  // ==================== Debounce Durations ====================
  
  /// Search debounce - 300ms
  static const Duration debounceSearch = Duration(milliseconds: 300);
  
  /// Input debounce - 500ms
  static const Duration debounceInput = Duration(milliseconds: 500);

  // ==================== Timeout Durations ====================
  
  /// API timeout - 30 seconds
  static const Duration apiTimeout = Duration(seconds: 30);
  
  /// Short timeout - 10 seconds
  static const Duration timeoutShort = Duration(seconds: 10);
  
  /// Long timeout - 60 seconds
  static const Duration timeoutLong = Duration(seconds: 60);

  // ==================== Splash & Delay ====================
  
  /// Splash screen duration - 2 seconds
  static const Duration splash = Duration(seconds: 2);
  
  /// Short delay - 500ms
  static const Duration delayShort = Duration(milliseconds: 500);
  
  /// Medium delay - 1 second
  static const Duration delayMedium = Duration(seconds: 1);
  
  /// Navigation delay - 2 seconds
  static const Duration navigationDelay = Duration(seconds: 2);
  
  // ==================== Animation Aliases ====================
  
  /// Animation slow (alias for animationVeryLong) - 800ms
  static const Duration animationSlow = animationVeryLong;
  
  /// Animation fast (alias for animationShort) - 200ms
  static const Duration animationFast = animationShort;

  // ==================== Carousel ====================
  
  /// Carousel auto play interval - 5 seconds
  static const Duration carouselAutoPlay = Duration(seconds: 5);
  
  /// Carousel animation duration - 800ms
  static const Duration carouselAnimation = Duration(milliseconds: 800);
}
