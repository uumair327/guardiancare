import 'package:flutter/foundation.dart';

/// Application configuration constants.
///
/// This class follows the Single Responsibility Principle (SRP) by providing
/// a centralized location for all application configuration values.
///
/// ## Environment Support
/// Supports multiple environments (development, staging, production) through
/// flavor configuration.
///
/// ## Usage
/// ```dart
/// final baseUrl = AppConfig.apiBaseUrl;
/// final timeout = AppConfig.connectionTimeout;
/// ```
abstract final class AppConfig {
  AppConfig._();

  // ==================== Environment ====================
  /// Current environment (dev, staging, prod)
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  /// Whether the app is running in debug mode
  static bool get isDebug => kDebugMode;

  /// Whether the app is running in release mode
  static bool get isRelease => kReleaseMode;

  /// Whether the app is running in profile mode
  static bool get isProfile => kProfileMode;

  // ==================== App Info ====================
  /// Application name
  static const String appName = 'GuardianCare';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Application build number
  static const String buildNumber = '1';

  /// Application bundle identifier
  static const String bundleId = 'app.guardiancare.guardiancare';

  // ==================== Firebase Project ====================
  /// Firebase project ID
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'guardiancare-prod',
  );

  /// Firebase storage bucket
  static const String storageBucket = String.fromEnvironment(
    'STORAGE_BUCKET',
    defaultValue: 'guardiancare-prod.appspot.com',
  );

  // ==================== Timeouts ====================
  /// Default connection timeout in seconds
  static const int connectionTimeout = 30;

  /// Default receive timeout in seconds
  static const int receiveTimeout = 30;

  /// Default send timeout in seconds
  static const int sendTimeout = 30;

  /// Cache expiration in minutes
  static const int cacheExpiration = 60;

  // ==================== Pagination ====================
  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  /// Maximum page size
  static const int maxPageSize = 100;

  // ==================== Retry Configuration ====================
  /// Maximum retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  /// Initial retry delay in milliseconds
  static const int retryDelayMs = 1000;

  /// Retry delay multiplier for exponential backoff
  static const double retryDelayMultiplier = 2;

  // ==================== Cache Configuration ====================
  /// Maximum cache entries
  static const int maxCacheEntries = 100;

  /// Cache max age in hours
  static const int cacheMaxAgeHours = 24;

  // ==================== Feature Flags ====================
  /// Whether analytics is enabled
  static const bool analyticsEnabled = true;

  /// Whether crash reporting is enabled
  static const bool crashReportingEnabled = true;

  /// Whether performance monitoring is enabled
  static const bool performanceMonitoringEnabled = true;

  // ==================== Security ====================
  /// Minimum password length
  static const int minPasswordLength = 8;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Session timeout in minutes
  static const int sessionTimeoutMinutes = 30;

  /// Parental key validation pattern
  static const String parentalKeyPattern = r'^[a-zA-Z0-9]{4,20}$';

  // ==================== Rate Limiting ====================
  /// Maximum requests per minute
  static const int maxRequestsPerMinute = 60;

  /// Forum post cooldown in seconds
  static const int forumPostCooldownSeconds = 30;

  /// Comment cooldown in seconds
  static const int commentCooldownSeconds = 10;
}
