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
/// 2. Use `--dart-define` for local development
/// 3. Use CI/CD secrets for production builds
///
/// ## Usage
///
/// ### Local Development
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxx
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

  // ============================================================================
  // Firebase Secrets
  // ============================================================================

  /// Firebase project ID.
  ///
  /// Note: Typically loaded from `firebase_options.dart`, not environment.
  /// This exists for advanced use cases where env-based config is needed.
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  /// Firebase API key (for REST API usage).
  ///
  /// Note: Standard Firebase SDK uses `firebase_options.dart`.
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  // ============================================================================
  // Supabase Secrets
  // ============================================================================

  /// Supabase project URL.
  ///
  /// Example: `https://xyzcompany.supabase.co`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous (public) key.
  ///
  /// This key is safe to use in client-side code.
  /// It has limited permissions based on Row Level Security (RLS) policies.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Supabase service role key (for admin operations).
  ///
  /// ⚠️ **SECURITY WARNING**
  /// This key bypasses Row Level Security.
  /// NEVER use in client-side code or expose to users.
  /// Only use in secure backend/edge functions.
  static const String supabaseServiceKey = String.fromEnvironment(
    'SUPABASE_SERVICE_KEY',
    defaultValue: '',
  );

  // ============================================================================
  // Appwrite Secrets (Future)
  // ============================================================================

  /// Appwrite endpoint URL.
  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: '',
  );

  /// Appwrite project ID.
  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: '',
  );

  // ============================================================================
  // Validation
  // ============================================================================

  /// Validate that required secrets are present for the active backend.
  ///
  /// Call this during app initialization:
  /// ```dart
  /// void main() async {
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
              ? '${supabaseUrl.substring(0, 20)}...'
              : 'not set',
          'anonKey': supabaseAnonKey.isNotEmpty ? '***set***' : 'not set',
          'serviceKey': supabaseServiceKey.isNotEmpty ? '***set***' : 'not set',
        },
        'appwrite': {
          'endpoint': appwriteEndpoint.isNotEmpty ? '***set***' : 'not set',
          'projectId': appwriteProjectId.isNotEmpty ? '***set***' : 'not set',
        },
      };
}
