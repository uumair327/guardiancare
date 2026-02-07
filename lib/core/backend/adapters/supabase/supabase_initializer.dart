import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/backend_config.dart';
import '../../config/backend_secrets.dart';
import '../../backend_factory.dart';

/// Conditional Supabase initializer.
///
/// Initializes Supabase only when Supabase features are enabled via
/// feature flags. This prevents unnecessary initialization and dependencies
/// when using Firebase-only configuration.
///
/// ## Usage
///
/// ```dart
/// // In main.dart, before DI initialization
/// await SupabaseInitializer.initializeIfNeeded();
/// ```
///
/// ## Prerequisites
///
/// 1. Add `supabase_flutter: ^2.0.0` to pubspec.yaml
/// 2. Set environment variables:
///    - SUPABASE_URL
///    - SUPABASE_ANON_KEY
///
/// ## Configuration
///
/// Supabase is initialized when any of these conditions are true:
/// - `BACKEND=supabase` (global switch)
/// - `USE_SUPABASE_AUTH=true`
/// - `USE_SUPABASE_DATABASE=true`
/// - `USE_SUPABASE_STORAGE=true`
/// - `USE_SUPABASE_REALTIME=true`
class SupabaseInitializer {
  SupabaseInitializer._();

  static bool _initialized = false;

  /// Whether Supabase has been initialized
  static bool get isInitialized => _initialized;

  /// Initialize Supabase if any Supabase features are enabled.
  ///
  /// This method is idempotent - calling it multiple times is safe.
  ///
  /// Returns `true` if Supabase was initialized, `false` if skipped.
  static Future<bool> initializeIfNeeded() async {
    if (_initialized) {
      debugPrint('SupabaseInitializer: Already initialized');
      return true;
    }

    final needsSupabase = BackendConfig.provider == BackendProvider.supabase ||
        BackendConfig.hasSupabaseFeatures;

    if (!needsSupabase) {
      debugPrint('SupabaseInitializer: Skipped (no Supabase features enabled)');
      return false;
    }

    // Validate secrets before initialization
    if (BackendSecrets.supabaseUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL environment variable is required when Supabase is enabled. '
        'Set it via --dart-define=SUPABASE_URL=your-url',
      );
    }

    if (BackendSecrets.supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY environment variable is required when Supabase is enabled. '
        'Set it via --dart-define=SUPABASE_ANON_KEY=your-key',
      );
    }

    await Supabase.initialize(
      url: BackendSecrets.supabaseUrl,
      anonKey: BackendSecrets.supabaseAnonKey,
      debug: kDebugMode,
    );

    debugPrint('SupabaseInitializer: Initialized successfully');
    debugPrint('  URL: ${BackendSecrets.supabaseUrl}');
    debugPrint('  Provider: ${BackendConfig.provider.name}');

    _initialized = true;
    return true;
  }

  /// Force re-initialization (useful for testing).
  ///
  /// **Warning**: This should only be used in tests.
  @visibleForTesting
  static Future<void> reset() async {
    _initialized = false;
  }

  /// Get the Supabase client.
  ///
  /// Throws [StateError] if Supabase is not initialized.
  ///
  /// **Note**: This is commented out until supabase_flutter is added.
  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase is not initialized. Call SupabaseInitializer.initializeIfNeeded() first.',
      );
    }
    return Supabase.instance.client;
  }
}

/// Extension for checking Supabase availability
extension SupabaseAvailability on BackendConfig {
  /// Whether Supabase is available and initialized
  static bool get isAvailable => SupabaseInitializer.isInitialized;
}
