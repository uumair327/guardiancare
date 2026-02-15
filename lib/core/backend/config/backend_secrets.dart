import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../backend_factory.dart';
import 'backend_config.dart';

/// Backend secrets loader for multi-provider configuration.
///
/// This class manages environment-based secrets for all backend providers.
///
/// ## Design Principle
/// - Secrets are **backend-specific** but access is **backend-agnostic**
/// - Unused backend keys may exist safely in environment
/// - Only the active backend initializes its clients
///
/// ## Security Rules
/// 1. NEVER commit secrets to version control
/// 2. Use `.env` file for local development (via flutter_dotenv)
/// 3. Use `--dart-define` for CI/CD or production builds if preferred
///
/// ## Usage
///
/// ### Local Development
/// Create a `.env` file in the root directory:
/// ```
/// BACKEND=supabase
/// SUPABASE_URL=https://...
/// SUPABASE_ANON_KEY=...
/// ```
///
/// ### CI/CD (GitHub Actions)
/// ```yaml
/// - run: flutter build apk
///     --dart-define=BACKEND=supabase
///     --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }}
///     --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
/// ```
abstract final class BackendSecrets {
  BackendSecrets._();

  /// Helper to retrieve a secret from multiple sources.
  /// Priority:
  /// 1. flutter_dotenv (.env file)
  /// 2. --dart-define (compile-time constant)
  static String _getSecret(String key, {String defaultValue = ''}) {
    // 1. Check .env (runtime)
    if (dotenv.isInitialized && dotenv.env.containsKey(key)) {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    // 2. Check --dart-define (compile-time constant fallback if possible, but
    // since we can't key into String.fromEnvironment dynamically in a const way to check existence,
    // we have to rely on the caller providing the const lookup if we want true const behavior.
    // However, since we are now runtime, we can try platform environment or just rely on specific getters below.)

    return defaultValue;
  }

  // ============================================================================
  // Firebase Secrets
  // ============================================================================

  /// Firebase project ID.
  ///
  /// Note: Typically loaded from `firebase_options.dart`, not environment.
  /// This exists for advanced use cases where env-based config is needed.
  static String get firebaseProjectId => _getSecret(
        'FIREBASE_PROJECT_ID',
        defaultValue: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      );

  /// Firebase API key (for REST API usage).
  ///
  /// Note: Standard Firebase SDK uses `firebase_options.dart`.
  static String get firebaseApiKey => _getSecret(
        'FIREBASE_API_KEY',
        defaultValue: const String.fromEnvironment('FIREBASE_API_KEY'),
      );

  // ============================================================================
  // Supabase Secrets
  // ============================================================================

  /// Supabase project URL.
  ///
  /// Example: `https://xyzcompany.supabase.co`
  static String get supabaseUrl => _getSecret(
        'SUPABASE_URL',
        defaultValue: const String.fromEnvironment('SUPABASE_URL'),
      );

  /// Supabase anonymous (public) key.
  ///
  /// This key is safe to use in client-side code.
  /// It has limited permissions based on Row Level Security (RLS) policies.
  static String get supabaseAnonKey => _getSecret(
        'SUPABASE_ANON_KEY',
        defaultValue: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );

  /// Supabase service role key (for admin operations).
  ///
  /// ⚠️ **SECURITY WARNING**
  /// This key bypasses Row Level Security.
  /// NEVER use in client-side code or expose to users.
  /// Only use in secure backend/edge functions.
  static String get supabaseServiceKey => _getSecret(
        'SUPABASE_SERVICE_KEY',
        defaultValue: const String.fromEnvironment('SUPABASE_SERVICE_KEY'),
      );

  // ============================================================================
  // Appwrite Secrets (Future)
  // ============================================================================

  /// Appwrite endpoint URL.
  static String get appwriteEndpoint => _getSecret(
        'APPWRITE_ENDPOINT',
        defaultValue: const String.fromEnvironment('APPWRITE_ENDPOINT'),
      );

  /// Appwrite project ID.
  static String get appwriteProjectId => _getSecret(
        'APPWRITE_PROJECT_ID',
        defaultValue: const String.fromEnvironment('APPWRITE_PROJECT_ID'),
      );

  // ============================================================================
  // Validation
  // ============================================================================

  /// Validate that required secrets are present for the active backend.
  ///
  /// Call this during app initialization:
  /// ```dart
  /// void main() async {
  ///   await dotenv.load(); // Load .env
  ///   BackendSecrets.validate(); // Throws if secrets missing
  ///   await di.init();
  /// }
  /// ```
  ///
  /// Throws [StateError] if required secrets are missing.
  static void validate() {
    final errors = <String>[];

    // Validate based on which providers are active
    if (BackendConfig.authProvider == BackendProvider.supabase ||
        BackendConfig.databaseProvider == BackendProvider.supabase ||
        BackendConfig.storageProvider == BackendProvider.supabase ||
        BackendConfig.realtimeProvider == BackendProvider.supabase) {
      _validateSupabaseSecrets(errors);
    }

    if (BackendConfig.provider == BackendProvider.appwrite) {
      _validateAppwriteSecrets(errors);
    }

    // Firebase validation is handled by firebase_options.dart
    // No additional validation needed here

    if (errors.isNotEmpty) {
      throw StateError(
        'Backend secrets validation failed:\n${errors.map((e) => '  • $e').join('\n')}',
      );
    }
  }

  static void _validateSupabaseSecrets(List<String> errors) {
    if (supabaseUrl.isEmpty) {
      errors.add('SUPABASE_URL is required but not set');
    }
    if (supabaseAnonKey.isEmpty) {
      errors.add('SUPABASE_ANON_KEY is required but not set');
    }
    // supabaseServiceKey is optional (only for admin operations)
  }

  static void _validateAppwriteSecrets(List<String> errors) {
    if (appwriteEndpoint.isEmpty) {
      errors.add('APPWRITE_ENDPOINT is required but not set');
    }
    if (appwriteProjectId.isEmpty) {
      errors.add('APPWRITE_PROJECT_ID is required but not set');
    }
  }

  // ============================================================================
  // Debug Information (Sanitized)
  // ============================================================================

  /// Get sanitized debug info (secrets are masked).
  ///
  /// Safe to log for debugging:
  /// ```dart
  /// debugPrint('Secrets config: ${BackendSecrets.debugInfo}');
  /// ```
  static Map<String, dynamic> get debugInfo => {
        'firebase': {
          'projectId': firebaseProjectId.isNotEmpty ? '***set***' : 'not set',
          'apiKey': firebaseApiKey.isNotEmpty ? '***set***' : 'not set',
        },
        'supabase': {
          'url': supabaseUrl.isNotEmpty
              ? '${supabaseUrl.substring(0, min(20, supabaseUrl.length))}...'
              : 'not set',
          'anonKey': supabaseAnonKey.isNotEmpty ? '***set***' : 'not set',
          'serviceKey': supabaseServiceKey.isNotEmpty ? '***set***' : 'not set',
        },
        'appwrite': {
          'endpoint': appwriteEndpoint.isNotEmpty ? '***set***' : 'not set',
          'projectId': appwriteProjectId.isNotEmpty ? '***set***' : 'not set',
        },
      };

  static int min(int a, int b) => a < b ? a : b;
}
