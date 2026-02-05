import 'models/backend_result.dart';
import 'ports/auth_service_port.dart';
import 'ports/data_store_port.dart';
import 'ports/storage_service_port.dart';
import 'ports/analytics_service_port.dart';

import 'adapters/firebase/firebase_auth_adapter.dart';
import 'adapters/firebase/firebase_data_store_adapter.dart';
import 'adapters/firebase/firebase_storage_adapter.dart';
import 'adapters/firebase/firebase_analytics_adapter.dart';

/// Backend provider types.
///
/// Add new providers here as they become available.
enum BackendProvider {
  firebase,
  supabase, // Future implementation
  appwrite, // Future implementation
  custom, // Custom backend
}

/// Backend service factory.
///
/// This factory creates backend service instances based on the selected provider.
/// It follows the Factory pattern to decouple service creation from usage.
///
/// ## Usage
/// ```dart
/// // In dependency injection setup
/// final factory = BackendFactory(BackendProvider.firebase);
///
/// sl.registerLazySingleton<IAuthService>(() => factory.createAuthService());
/// sl.registerLazySingleton<IDataStore>(() => factory.createDataStore());
/// sl.registerLazySingleton<IStorageService>(() => factory.createStorageService());
/// sl.registerLazySingleton<IAnalyticsService>(() => factory.createAnalyticsService());
/// ```
///
/// ## Switching Providers
/// To switch to a different backend:
/// ```dart
/// // Before
/// final factory = BackendFactory(BackendProvider.firebase);
///
/// // After (when Supabase is implemented)
/// final factory = BackendFactory(BackendProvider.supabase);
/// ```
class BackendFactory {
  const BackendFactory(this.provider);

  /// The backend provider to use
  final BackendProvider provider;

  /// Create an authentication service
  IAuthService createAuthService() {
    return switch (provider) {
      BackendProvider.firebase => FirebaseAuthAdapter(),
      BackendProvider.supabase => throw UnimplementedError(
          'Supabase auth not yet implemented',
        ),
      BackendProvider.appwrite => throw UnimplementedError(
          'Appwrite auth not yet implemented',
        ),
      BackendProvider.custom => throw UnimplementedError(
          'Custom auth not yet implemented',
        ),
    };
  }

  /// Create a data store service
  IDataStore createDataStore() {
    return switch (provider) {
      BackendProvider.firebase => FirebaseDataStoreAdapter(),
      BackendProvider.supabase => throw UnimplementedError(
          'Supabase data store not yet implemented',
        ),
      BackendProvider.appwrite => throw UnimplementedError(
          'Appwrite data store not yet implemented',
        ),
      BackendProvider.custom => throw UnimplementedError(
          'Custom data store not yet implemented',
        ),
    };
  }

  /// Create a storage service
  IStorageService createStorageService() {
    return switch (provider) {
      BackendProvider.firebase => FirebaseStorageAdapter(),
      BackendProvider.supabase => throw UnimplementedError(
          'Supabase storage not yet implemented',
        ),
      BackendProvider.appwrite => throw UnimplementedError(
          'Appwrite storage not yet implemented',
        ),
      BackendProvider.custom => throw UnimplementedError(
          'Custom storage not yet implemented',
        ),
    };
  }

  /// Create an analytics service
  IAnalyticsService createAnalyticsService() {
    return switch (provider) {
      BackendProvider.firebase => FirebaseAnalyticsAdapter(),
      BackendProvider.supabase => throw UnimplementedError(
          'Supabase analytics not yet implemented',
        ),
      BackendProvider.appwrite => throw UnimplementedError(
          'Appwrite analytics not yet implemented',
        ),
      BackendProvider.custom => throw UnimplementedError(
          'Custom analytics not yet implemented',
        ),
    };
  }

  /// Create all services at once
  BackendServices createAll() {
    return BackendServices(
      auth: createAuthService(),
      dataStore: createDataStore(),
      storage: createStorageService(),
      analytics: createAnalyticsService(),
    );
  }
}

/// Container for all backend services.
class BackendServices {
  const BackendServices({
    required this.auth,
    required this.dataStore,
    required this.storage,
    required this.analytics,
  });

  final IAuthService auth;
  final IDataStore dataStore;
  final IStorageService storage;
  final IAnalyticsService analytics;
}

/// No-op analytics adapter for testing or when analytics is disabled.
class NoOpAnalyticsAdapter implements IAnalyticsService {
  const NoOpAnalyticsAdapter();

  @override
  Future<BackendResult<void>> initialize() async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> setAnalyticsCollectionEnabled(
          bool enabled) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> setUserId(String? userId) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> setUserProperty({
    required String name,
    required String? value,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> setUserProperties(
    Map<String, String?> properties,
  ) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> clearUserData() async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logScreenView({
    required String screenName,
    String? screenClass,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logLogin({required String method}) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logSignUp({required String method}) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logSearch({required String searchTerm}) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logSelectContent({
    required String contentType,
    required String itemId,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logAppOpen() async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logTutorialBegin() async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logTutorialComplete() async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logViewItem({
    required String itemId,
    required String itemName,
    String? itemCategory,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logViewItemList({
    required String itemListId,
    required String itemListName,
  }) async =>
      const BackendResult.success(null);

  @override
  Future<BackendResult<void>> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async =>
      const BackendResult.success(null);
}
