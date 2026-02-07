import 'config/backend_config.dart';
import 'models/backend_result.dart';
import 'ports/auth_service_port.dart';
import 'ports/data_store_port.dart';
import 'ports/storage_service_port.dart';
import 'ports/analytics_service_port.dart';
import 'ports/realtime_service_port.dart';

// Firebase adapters
import 'adapters/firebase/firebase_auth_adapter.dart';
import 'adapters/firebase/firebase_data_store_adapter.dart';
import 'adapters/firebase/firebase_storage_adapter.dart';
import 'adapters/firebase/firebase_analytics_adapter.dart';
import 'adapters/firebase/firebase_realtime_adapter.dart';

// Supabase adapters (fully implemented)
import 'adapters/supabase/supabase_auth_adapter.dart';
import 'adapters/supabase/supabase_data_store_adapter.dart';
import 'adapters/supabase/supabase_storage_adapter.dart';
import 'adapters/supabase/supabase_realtime_adapter.dart';

/// Backend provider types.
///
/// Add new providers here as they become available.
enum BackendProvider {
  /// Firebase (Firestore, Auth, Storage, Analytics)
  firebase,

  /// Supabase (PostgreSQL, Auth, Storage, Realtime)
  supabase,

  /// Appwrite (future implementation)
  appwrite,

  /// Custom backend (REST API, GraphQL, etc.)
  custom,
}

/// Enhanced backend service factory with **flag-driven adapter resolution**.
///
/// This factory implements the "Backend Polymorphism via Flag-Driven Adapter
/// Resolution" pattern, supporting:
///
/// 1. **Global Backend Switching** - One flag changes all services
/// 2. **Granular Feature Flags** - Mix backends per service
/// 3. **Zero Code Changes** - Domain/application layers remain untouched
///
/// ## Usage
///
/// ### Default (Uses BackendConfig)
/// ```dart
/// // Recommended: Factory reads from BackendConfig automatically
/// final factory = BackendFactory();
/// ```
///
/// ### Explicit Provider Override
/// ```dart
/// // For testing or specific use cases
/// final factory = BackendFactory(BackendProvider.supabase);
/// ```
///
/// ### In Dependency Injection
/// ```dart
/// void _initBackendServices() {
///   final factory = BackendFactory();
///
///   sl.registerLazySingleton<IAuthService>(() => factory.createAuthService());
///   sl.registerLazySingleton<IDataStore>(() => factory.createDataStore());
///   sl.registerLazySingleton<IStorageService>(() => factory.createStorageService());
///   sl.registerLazySingleton<IAnalyticsService>(() => factory.createAnalyticsService());
///   sl.registerLazySingleton<IRealtimeService>(() => factory.createRealtimeService());
/// }
/// ```
///
/// ## Switching Providers
///
/// ### Global Switch (affects all services)
/// ```bash
/// flutter run --dart-define=BACKEND=supabase
/// ```
///
/// ### Granular Override (mix Firebase + Supabase)
/// ```bash
/// flutter run --dart-define=USE_SUPABASE_AUTH=true
/// ```
class BackendFactory {
  /// Creates a backend factory.
  ///
  /// If [provider] is null, uses [BackendConfig.provider] (recommended).
  /// Pass an explicit provider for testing or specific override scenarios.
  const BackendFactory([BackendProvider? provider])
      : _explicitProvider = provider;

  /// Explicit provider override (null = use BackendConfig)
  final BackendProvider? _explicitProvider;

  /// Resolved global provider.
  ///
  /// Returns explicit override if set, otherwise reads from [BackendConfig].
  BackendProvider get provider => _explicitProvider ?? BackendConfig.provider;

  // ============================================================================
  // Service Creation Methods
  // ============================================================================

  /// Create an authentication service.
  ///
  /// Respects granular `USE_SUPABASE_AUTH` flag if set.
  IAuthService createAuthService() {
    // Granular override takes precedence
    final resolvedProvider = _explicitProvider ?? BackendConfig.authProvider;

    return switch (resolvedProvider) {
      BackendProvider.firebase => FirebaseAuthAdapter(),
      BackendProvider.supabase => SupabaseAuthAdapter(),
      BackendProvider.appwrite => _throwNotImplemented('Appwrite auth'),
      BackendProvider.custom => _throwNotImplemented('Custom auth'),
    };
  }

  /// Create a data store service.
  ///
  /// Respects granular `USE_SUPABASE_DATABASE` flag if set.
  IDataStore createDataStore() {
    final resolvedProvider =
        _explicitProvider ?? BackendConfig.databaseProvider;

    return switch (resolvedProvider) {
      BackendProvider.firebase => FirebaseDataStoreAdapter(),
      BackendProvider.supabase => SupabaseDataStoreAdapter(),
      BackendProvider.appwrite => _throwNotImplemented('Appwrite data store'),
      BackendProvider.custom => _throwNotImplemented('Custom data store'),
    };
  }

  /// Create a storage service.
  ///
  /// Respects granular `USE_SUPABASE_STORAGE` flag if set.
  IStorageService createStorageService() {
    final resolvedProvider = _explicitProvider ?? BackendConfig.storageProvider;

    return switch (resolvedProvider) {
      BackendProvider.firebase => FirebaseStorageAdapter(),
      BackendProvider.supabase => SupabaseStorageAdapter(),
      BackendProvider.appwrite => _throwNotImplemented('Appwrite storage'),
      BackendProvider.custom => _throwNotImplemented('Custom storage'),
    };
  }

  /// Create an analytics service.
  ///
  /// Analytics uses global provider only (no granular override).
  /// Falls back to [NoOpAnalyticsAdapter] for non-Firebase backends.
  IAnalyticsService createAnalyticsService() {
    return switch (provider) {
      BackendProvider.firebase => FirebaseAnalyticsAdapter(),
      // Other backends use NoOp analytics (can be replaced with custom impl)
      BackendProvider.supabase => const NoOpAnalyticsAdapter(),
      BackendProvider.appwrite => const NoOpAnalyticsAdapter(),
      BackendProvider.custom => const NoOpAnalyticsAdapter(),
    };
  }

  /// Create a realtime service.
  ///
  /// Respects granular `USE_SUPABASE_REALTIME` flag if set.
  IRealtimeService createRealtimeService() {
    final resolvedProvider =
        _explicitProvider ?? BackendConfig.realtimeProvider;

    return switch (resolvedProvider) {
      BackendProvider.firebase => FirebaseRealtimeAdapter(),
      BackendProvider.supabase => SupabaseRealtimeAdapter(),
      BackendProvider.appwrite => _throwNotImplemented('Appwrite realtime'),
      BackendProvider.custom => _throwNotImplemented('Custom realtime'),
    };
  }

  /// Create all services at once.
  ///
  /// Useful for testing or when you need all services together.
  BackendServices createAll() {
    return BackendServices(
      auth: createAuthService(),
      dataStore: createDataStore(),
      storage: createStorageService(),
      analytics: createAnalyticsService(),
      realtime: createRealtimeService(),
    );
  }

  // ============================================================================
  // Helpers
  // ============================================================================

  /// Throws unimplemented error with helpful message.
  Never _throwNotImplemented(String service) {
    throw UnimplementedError(
      '$service adapter not yet implemented. '
      'To add support, create the adapter in lib/core/backend/adapters/ '
      'and update this factory.',
    );
  }
}

/// Container for all backend services.
///
/// Provides a convenient way to access all services at once.
class BackendServices {
  const BackendServices({
    required this.auth,
    required this.dataStore,
    required this.storage,
    required this.analytics,
    required this.realtime,
  });

  /// Authentication service
  final IAuthService auth;

  /// Data store service (database)
  final IDataStore dataStore;

  /// File storage service
  final IStorageService storage;

  /// Analytics service
  final IAnalyticsService analytics;

  /// Realtime service
  final IRealtimeService realtime;
}

/// No-op analytics adapter for testing or when analytics is disabled.
///
/// Use this when:
/// - Running tests
/// - Using a backend without built-in analytics
/// - Temporarily disabling analytics
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
