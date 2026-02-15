import '../backend_factory.dart';

/// Backend configuration with feature flags.
///
/// This is the **SINGLE SOURCE OF TRUTH** for backend selection.
///
/// ## Design Pattern
/// Uses "Backend Polymorphism via Flag-Driven Adapter Resolution"
///
/// ## Critical Rule (NON-NEGOTIABLE)
/// **Domain layer MUST NOT access this directly.**
/// This class is ONLY used by:
/// - `BackendFactory` (adapter resolution)
/// - `injection_container.dart` (DI setup)
///
/// ## Configuration Methods
///
/// ### Global Backend Switching
/// Set via compile-time constant:
/// ```bash
/// flutter run --dart-define=BACKEND=supabase
/// ```
///
/// ### Granular Feature Flags
/// Override individual services:
/// ```bash
/// flutter run --dart-define=USE_SUPABASE_AUTH=true
/// ```
///
/// ### CI/CD Deployment
/// ```bash
/// flutter build apk --dart-define=BACKEND=supabase \
///   --dart-define=SUPABASE_URL=$SUPABASE_URL \
///   --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
/// ```
///
/// ## Rollback Strategy
/// If Supabase fails in production, simply rebuild with:
/// ```bash
/// flutter run --dart-define=BACKEND=firebase
/// ```
abstract final class BackendConfig {
  BackendConfig._();

  // ============================================================================
  // Global Backend Provider Selection
  // ============================================================================

  /// Backend provider from environment.
  ///
  /// Defaults to 'firebase' if not specified.
  /// Valid values: 'firebase', 'supabase', 'appwrite', 'custom'
  static const String _backendEnv = String.fromEnvironment(
    'BACKEND',
    defaultValue: 'firebase',
  );

  /// Parsed backend provider.
  ///
  /// This is the primary backend selection mechanism.
  /// Individual service flags can override this for granular control.
  static BackendProvider get provider => switch (_backendEnv.toLowerCase()) {
        'supabase' => BackendProvider.supabase,
        'appwrite' => BackendProvider.appwrite,
        'custom' => BackendProvider.custom,
        _ => BackendProvider.firebase,
      };

  // ============================================================================
  // Granular Feature Flags (Service-Level Overrides)
  // ============================================================================

  /// Override authentication provider.
  ///
  /// When `true`, uses Supabase Auth regardless of global `BACKEND` setting.
  /// ```bash
  /// flutter run --dart-define=USE_SUPABASE_AUTH=true
  /// ```
  static const bool useSupabaseAuth = bool.fromEnvironment(
    'USE_SUPABASE_AUTH',
  );

  /// Override database provider.
  ///
  /// When `true`, uses Supabase PostgreSQL regardless of global `BACKEND` setting.
  /// ```bash
  /// flutter run --dart-define=USE_SUPABASE_DATABASE=true
  /// ```
  static const bool useSupabaseDatabase = bool.fromEnvironment(
    'USE_SUPABASE_DATABASE',
  );

  /// Override storage provider.
  ///
  /// When `true`, uses Supabase Storage regardless of global `BACKEND` setting.
  /// ```bash
  /// flutter run --dart-define=USE_SUPABASE_STORAGE=true
  /// ```
  static const bool useSupabaseStorage = bool.fromEnvironment(
    'USE_SUPABASE_STORAGE',
  );

  /// Override realtime provider.
  ///
  /// When `true`, uses Supabase Realtime regardless of global `BACKEND` setting.
  /// ```bash
  /// flutter run --dart-define=USE_SUPABASE_REALTIME=true
  /// ```
  static const bool useSupabaseRealtime = bool.fromEnvironment(
    'USE_SUPABASE_REALTIME',
  );

  // ============================================================================
  // Authentication Method Feature Flags
  // ============================================================================

  /// Enable/disable Google Sign-In.
  ///
  /// When `false`, the Google Sign-In button is hidden from the login page.
  /// Useful for temporarily disabling Google Sign-In when OAuth is misconfigured.
  /// ```bash
  /// flutter run --dart-define=ENABLE_GOOGLE_SIGN_IN=true
  /// ```
  static const bool enableGoogleSignIn = bool.fromEnvironment(
    'ENABLE_GOOGLE_SIGN_IN',
  );

  /// Enable/disable Email/Password authentication.
  ///
  /// When `true`, email/password sign-in and sign-up are available.
  /// ```bash
  /// flutter run --dart-define=ENABLE_EMAIL_AUTH=true
  /// ```
  static const bool enableEmailAuth = bool.fromEnvironment(
    'ENABLE_EMAIL_AUTH',
    defaultValue: true,
  );

  /// Enable/disable Apple Sign-In.
  ///
  /// When `false`, the Apple Sign-In button is hidden from the login page.
  /// ```bash
  /// flutter run --dart-define=ENABLE_APPLE_SIGN_IN=true
  /// ```
  static const bool enableAppleSignIn = bool.fromEnvironment(
    'ENABLE_APPLE_SIGN_IN',
  );

  // ============================================================================
  // Convenience Getters
  // ============================================================================

  /// Check if using Firebase as global provider.
  static bool get isFirebase => provider == BackendProvider.firebase;

  /// Check if using Supabase as global provider.
  static bool get isSupabase => provider == BackendProvider.supabase;

  /// Check if any Supabase feature is enabled (global or granular).
  static bool get hasSupabaseFeatures =>
      isSupabase ||
      useSupabaseAuth ||
      useSupabaseDatabase ||
      useSupabaseStorage ||
      useSupabaseRealtime;

  /// Check if any Firebase feature is enabled (global or granular).
  static bool get hasFirebaseFeatures =>
      isFirebase ||
      (!useSupabaseAuth && isFirebase) ||
      (!useSupabaseDatabase && isFirebase) ||
      (!useSupabaseStorage && isFirebase) ||
      (!useSupabaseRealtime && isFirebase);

  // ============================================================================
  // Resolved Provider per Service (Internal Use Only)
  // ============================================================================

  /// Resolved auth provider (considers granular override).
  static BackendProvider get authProvider =>
      useSupabaseAuth ? BackendProvider.supabase : provider;

  /// Resolved database provider (considers granular override).
  static BackendProvider get databaseProvider =>
      useSupabaseDatabase ? BackendProvider.supabase : provider;

  /// Resolved storage provider (considers granular override).
  static BackendProvider get storageProvider =>
      useSupabaseStorage ? BackendProvider.supabase : provider;

  /// Resolved realtime provider (considers granular override).
  static BackendProvider get realtimeProvider =>
      useSupabaseRealtime ? BackendProvider.supabase : provider;

  // ============================================================================
  // Debug Information
  // ============================================================================

  /// Debug information for logging.
  ///

  /// Use this to verify backend configuration at startup:
  /// ```dart
  /// Log.d('Backend config: ${BackendConfig.debugInfo}');
  /// ```
  static Map<String, dynamic> get debugInfo => {
        'globalProvider': provider.name,
        'resolvedProviders': {
          'auth': authProvider.name,
          'database': databaseProvider.name,
          'storage': storageProvider.name,
          'realtime': realtimeProvider.name,
        },
        'featureFlags': {
          'useSupabaseAuth': useSupabaseAuth,
          'useSupabaseDatabase': useSupabaseDatabase,
          'useSupabaseStorage': useSupabaseStorage,
          'useSupabaseRealtime': useSupabaseRealtime,
        },
        'authMethods': {
          'enableGoogleSignIn': enableGoogleSignIn,
          'enableEmailAuth': enableEmailAuth,
          'enableAppleSignIn': enableAppleSignIn,
        },
        'hasSupabaseFeatures': hasSupabaseFeatures,
        'hasFirebaseFeatures': hasFirebaseFeatures,
      };
}
