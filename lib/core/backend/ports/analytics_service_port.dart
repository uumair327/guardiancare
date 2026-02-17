import '../models/backend_result.dart';

/// Analytics service port (interface).
///
/// This is the PORT in Hexagonal Architecture - it defines what the application
/// needs from analytics WITHOUT specifying how it's implemented.
///
/// ## Implementations
/// - `FirebaseAnalyticsAdapter` - Firebase Analytics
/// - `MixpanelAnalyticsAdapter` - Mixpanel (future)
/// - `AmplitudeAnalyticsAdapter` - Amplitude (future)
/// - `NoOpAnalyticsAdapter` - Disabled analytics
///
/// ## Usage
/// ```dart
/// class AnalyticsService {
///   final IAnalyticsService analytics;
///
///   AnalyticsService(this.analytics);
///
///   void trackSignUp(String method) {
///     analytics.logEvent(
///       name: 'sign_up',
///       parameters: {'method': method},
///     );
///   }
/// }
/// ```
abstract interface class IAnalyticsService {
  // ==================== Initialization ====================
  /// Initialize analytics
  Future<BackendResult<void>> initialize();

  /// Set analytics collection enabled/disabled
  Future<BackendResult<void>> setAnalyticsCollectionEnabled(
      {required bool enabled});

  // ==================== User Properties ====================
  /// Set user ID for analytics
  Future<BackendResult<void>> setUserId(String? userId);

  /// Set user property
  Future<BackendResult<void>> setUserProperty({
    required String name,
    required String? value,
  });

  /// Set multiple user properties
  Future<BackendResult<void>> setUserProperties(
      Map<String, String?> properties);

  /// Clear user data (for GDPR compliance)
  Future<BackendResult<void>> clearUserData();

  // ==================== Event Logging ====================
  /// Log a custom event
  Future<BackendResult<void>> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  /// Log screen view
  Future<BackendResult<void>> logScreenView({
    required String screenName,
    String? screenClass,
  });

  /// Log login event
  Future<BackendResult<void>> logLogin({required String method});

  /// Log sign up event
  Future<BackendResult<void>> logSignUp({required String method});

  /// Log search event
  Future<BackendResult<void>> logSearch({required String searchTerm});

  /// Log share event
  Future<BackendResult<void>> logShare({
    required String contentType,
    required String itemId,
    String? method,
  });

  /// Log content selection
  Future<BackendResult<void>> logSelectContent({
    required String contentType,
    required String itemId,
  });

  // ==================== App Lifecycle Events ====================
  /// Log app open
  Future<BackendResult<void>> logAppOpen();

  /// Log tutorial begin
  Future<BackendResult<void>> logTutorialBegin();

  /// Log tutorial complete
  Future<BackendResult<void>> logTutorialComplete();

  // ==================== Engagement Events ====================
  /// Log content view
  Future<BackendResult<void>> logViewItem({
    required String itemId,
    required String itemName,
    String? itemCategory,
  });

  /// Log list view
  Future<BackendResult<void>> logViewItemList({
    required String itemListId,
    required String itemListName,
  });

  // ==================== Error Tracking ====================
  /// Log error event
  Future<BackendResult<void>> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  });
}
