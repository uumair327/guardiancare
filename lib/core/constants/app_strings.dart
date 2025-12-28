/// Core application string constants for the GuardianCare application.
///
/// This class provides a single source of truth for core application-level
/// constants that are non-localized and used throughout the application.
///
/// ## Purpose
/// - Centralizes core app information (name, version, URLs)
/// - Provides storage keys for SharedPreferences
/// - Defines route names for navigation
/// - Contains regex patterns for validation
/// - Stores default values and configuration
///
/// ## Categories
/// - **App Info**: Application name, tagline, version
/// - **Organization Info**: Organization name and abbreviation
/// - **URLs**: Website, support email, privacy policy, terms of service
/// - **Email**: Email configuration constants
/// - **Asset Paths**: Paths to app assets (prefer AppAssets class)
/// - **Regex Patterns**: Validation patterns for email, phone, name
/// - **Default Values**: Default language, country, user role
/// - **Storage Keys**: SharedPreferences key names
/// - **Route Names**: Navigation route identifiers
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // App info
/// Text(AppStrings.appName); // "Guardian Care"
///
/// // URLs
/// launchUrl(Uri.parse(AppStrings.websiteUrl));
///
/// // Storage keys
/// final prefs = await SharedPreferences.getInstance();
/// final locale = prefs.getString(AppStrings.keyLocale);
///
/// // Route names
/// context.goNamed(AppStrings.routeHome);
///
/// // Regex validation
/// final emailRegex = RegExp(AppStrings.emailPattern);
/// if (!emailRegex.hasMatch(email)) {
///   return ValidationStrings.emailInvalid;
/// }
/// ```
///
/// ## Best Practices
/// - Use AppStrings for app-level constants only
/// - For error messages, use [ErrorStrings]
/// - For validation messages, use [ValidationStrings]
/// - For UI text, use [UIStrings]
/// - For feedback messages, use [FeedbackStrings]
/// - For Firebase constants, use [FirebaseStrings]
/// - For API constants, use [ApiStrings]
///
/// ## Note on Localization
/// This class contains non-localized strings only. For user-facing text
/// that needs translation, use `AppLocalizations` (l10n) instead.
///
/// See also:
/// - [ErrorStrings] for error messages
/// - [ValidationStrings] for validation messages
/// - [UIStrings] for UI text
/// - [FeedbackStrings] for feedback messages
/// - [FirebaseStrings] for Firebase constants
/// - [ApiStrings] for API constants
class AppStrings {
  AppStrings._();

  // ==================== App Info ====================
  static const String appName = 'Guardian Care';
  static const String appTagline = 'A Children of India App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ==================== Organization Info ====================
  static const String organizationName = 'Children of India';
  static const String organizationAbbreviation = 'COI';

  // ==================== URLs ====================
  static const String websiteUrl = 'https://childrenofindia.in/';
  static const String websiteDomain = 'childrenofindia.in';
  static const String supportEmail = 'hello@childrenofindia.in';
  static const String privacyPolicyUrl = 'https://childrenofindia.in/privacy';
  static const String termsOfServiceUrl = 'https://childrenofindia.in/terms';

  // ==================== Email ====================
  static const String emailSubject = 'Guardian Care App Inquiry';
  static const String emailScheme = 'mailto';

  // ==================== Legacy Error Messages ====================
  // Note: These are kept for backward compatibility.
  // New code should use ErrorStrings class instead.
  @Deprecated('Use ErrorStrings.emailClientError instead')
  static const String errorEmailClient = 'Could not launch email client';

  // ==================== Asset Paths ====================
  /// Note: Prefer using AppAssets for asset paths
  static const String logoPath = 'assets/logo/logo.png';
  static const String logoSplashPath = 'assets/logo/logo_splash.png';

  // ==================== Regex Patterns ====================
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[0-9]{10,15}$';
  static const String namePattern = r'^[a-zA-Z\s]+$';

  // ==================== Default Values ====================
  static const String defaultLanguageCode = 'en';
  static const String defaultCountryCode = 'IN';
  static const String defaultUserRole = 'child';

  // ==================== Storage Keys ====================
  static const String keyLocale = 'locale';
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyConsentGiven = 'consent_given';
  static const String keyParentalKey = 'parental_key';
  static const String keyUserId = 'user_id';

  // ==================== Route Names ====================
  static const String routeHome = 'home';
  static const String routeLogin = 'login';
  static const String routeSignup = 'signup';
  static const String routeProfile = 'profile';
  static const String routeForum = 'forum';
  static const String routeLearn = 'learn';
  static const String routeQuiz = 'quiz';
  static const String routeEmergency = 'emergency';
  static const String routeSettings = 'settings';
}
