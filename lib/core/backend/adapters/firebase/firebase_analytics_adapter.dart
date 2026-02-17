import 'package:firebase_analytics/firebase_analytics.dart' as fa;

import '../../models/backend_result.dart';
import '../../ports/analytics_service_port.dart';

/// Firebase Analytics adapter.
///
/// This is the ADAPTER in Hexagonal Architecture - it implements the
/// [IAnalyticsService] port using Firebase Analytics.
class FirebaseAnalyticsAdapter implements IAnalyticsService {
  FirebaseAnalyticsAdapter({
    fa.FirebaseAnalytics? analytics,
  }) : _analytics = analytics ?? fa.FirebaseAnalytics.instance;

  final fa.FirebaseAnalytics _analytics;

  // ==================== Initialization ====================
  @override
  Future<BackendResult<void>> initialize() async {
    // Firebase Analytics is initialized automatically
    return const BackendResult.success(null);
  }

  @override
  Future<BackendResult<void>> setAnalyticsCollectionEnabled(
      {required bool enabled}) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== User Properties ====================
  @override
  Future<BackendResult<void>> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> setUserProperties(
    Map<String, String?> properties,
  ) async {
    try {
      for (final entry in properties.entries) {
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value,
        );
      }
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> clearUserData() async {
    try {
      await _analytics.setUserId();
      await _analytics.resetAnalyticsData();
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Event Logging ====================
  @override
  Future<BackendResult<void>> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: _sanitizeParameters(parameters),
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logSearch({required String searchTerm}) async {
    try {
      await _analytics.logSearch(searchTerm: searchTerm);
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    try {
      await _analytics.logShare(
        contentType: contentType,
        itemId: itemId,
        method: method ?? 'unknown',
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await _analytics.logSelectContent(
        contentType: contentType,
        itemId: itemId,
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== App Lifecycle Events ====================
  @override
  Future<BackendResult<void>> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logTutorialBegin() async {
    try {
      await _analytics.logTutorialBegin();
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logTutorialComplete() async {
    try {
      await _analytics.logTutorialComplete();
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Engagement Events ====================
  @override
  Future<BackendResult<void>> logViewItem({
    required String itemId,
    required String itemName,
    String? itemCategory,
  }) async {
    try {
      await _analytics.logViewItem(
        items: [
          fa.AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
          ),
        ],
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> logViewItemList({
    required String itemListId,
    required String itemListName,
  }) async {
    try {
      await _analytics.logViewItemList(
        itemListId: itemListId,
        itemListName: itemListName,
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Error Tracking ====================
  @override
  Future<BackendResult<void>> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage.length > 100
              ? errorMessage.substring(0, 100)
              : errorMessage,
          if (stackTrace != null)
            'stack_trace': stackTrace.length > 100
                ? stackTrace.substring(0, 100)
                : stackTrace,
        },
      );
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Private Helpers ====================
  Map<String, Object>? _sanitizeParameters(Map<String, dynamic>? parameters) {
    if (parameters == null) return null;

    return parameters.map((key, value) {
      // Firebase Analytics only accepts String, int, double
      if (value is String || value is int || value is double) {
        return MapEntry(key, value);
      } else if (value is bool) {
        return MapEntry(key, value ? 1 : 0);
      } else {
        return MapEntry(key, value.toString());
      }
    });
  }
}
