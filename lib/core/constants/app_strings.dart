/// Centralized non-localized string constants
/// Following Clean Architecture principles - Core layer
/// Note: For localized strings, use AppLocalizations (l10n)
class AppStrings {
  AppStrings._();

  // ==================== App Info ====================
  static const String appName = 'Guardian Care';
  static const String appTagline = 'A Children of India App';
  
  // ==================== URLs ====================
  static const String websiteUrl = 'https://childrenofindia.in/';
  static const String supportEmail = 'hello@childrenofindia.in';
  
  // ==================== Email ====================
  static const String emailSubject = 'Guardian Care App Inquiry';
  
  // ==================== Validation Messages ====================
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  
  // ==================== Error Messages ====================
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorEmailClient = 'Could not launch email client';
  static const String errorLoadingCarousel = 'Error loading carousel data';
  
  // ==================== Firebase Collections ====================
  static const String collectionCarouselItems = 'carousel_items';
  static const String collectionUsers = 'users';
  
  // ==================== Asset Paths ====================
  static const String logoPath = 'assets/logo/logo.png';
  static const String logoSplashPath = 'assets/logo/logo_splash.png';
  
  // ==================== Regex Patterns ====================
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}
