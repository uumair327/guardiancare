/// Centralized asset path constants
/// Following Clean Architecture principles - Core layer
class AppAssets {
  AppAssets._();

  // ==================== Logo ====================
  static const String logo = 'assets/logo/logo.png';
  static const String logoSplash = 'assets/logo/logo_splash.png';
  
  // ==================== Base Paths ====================
  static const String _logoBase = 'assets/logo/';
  
  // ==================== Helper Methods ====================
  
  /// Get logo asset path
  static String getLogoPath(String fileName) => '$_logoBase$fileName';
}
