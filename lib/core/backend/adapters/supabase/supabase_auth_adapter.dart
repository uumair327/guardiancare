import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/backend_result.dart';
import '../../models/backend_user.dart' hide OAuthProvider;
import '../../models/backend_user.dart' as backend show OAuthProvider;
import '../../ports/auth_service_port.dart';
import 'supabase_initializer.dart';

/// Supabase implementation of [IAuthService].
///
/// This adapter implements authentication using Supabase Auth.
///
/// ## Setup Required
///
/// 1. Add dependency to `pubspec.yaml`:
///    ```yaml
///    dependencies:
///      supabase_flutter: ^2.8.0
///    ```
///
/// 2. Initialize Supabase in `main.dart`:
///    ```dart
///    await Supabase.initialize(
///      url: BackendSecrets.supabaseUrl,
///      anonKey: BackendSecrets.supabaseAnonKey,
///    );
///    ```
///
/// 3. Configure OAuth providers in Supabase Dashboard:
///    - Settings → Authentication → Providers
///
/// ## Architecture Compliance
/// - Implements `IAuthService` port (Hexagonal Architecture)
/// - Returns `BackendResult` for type-safe error handling
/// - Uses `BackendUser` model (vendor-agnostic)
class SupabaseAuthAdapter implements IAuthService {
  SupabaseAuthAdapter() : _client = SupabaseInitializer.client {
    debugPrint('SupabaseAuthAdapter: Initialized with Supabase');
  }

  final SupabaseClient _client;
  GoTrueClient get _auth => _client.auth;

  // ============================================================================
  // Current User
  // ============================================================================

  @override
  BackendUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Stream<BackendUser?> get authStateChanges {
    return _auth.onAuthStateChange.map((state) {
      return state.session?.user != null ? _mapUser(state.session!.user) : null;
    });
  }

  @override
  Stream<BackendUser?> get userChanges => authStateChanges;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  // ============================================================================
  // Email/Password Auth
  // ============================================================================

  @override
  Future<BackendResult<BackendUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Sign in failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(response.user!));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<BackendUser>> createUserWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      if (response.user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Sign up failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(response.user!));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.resetPasswordForEmail(email);
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      // Supabase handles this via magic link + updateUser
      await _auth.updateUser(UserAttributes(password: newPassword));
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // OAuth Providers
  // ============================================================================

  @override
  Future<BackendResult<BackendUser>> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.guardiancare://login-callback/',
      );
      // OAuth redirects, so we wait for auth state
      await Future.delayed(const Duration(milliseconds: 500));
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Google sign in cancelled or failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<BackendUser>> signInWithApple() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.guardiancare://login-callback/',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Apple sign in cancelled or failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<BackendUser>> signInWithOAuth(
      backend.OAuthProvider provider) async {
    try {
      final supabaseProvider = _mapOAuthProvider(provider);
      await _auth.signInWithOAuth(
        supabaseProvider,
        redirectTo: 'io.supabase.guardiancare://login-callback/',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'OAuth sign in cancelled or failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Anonymous Auth
  // ============================================================================

  @override
  Future<BackendResult<BackendUser>> signInAnonymously() async {
    // Supabase now supports anonymous sign-in (as of v2)
    try {
      final response = await _auth.signInAnonymously();
      if (response.user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Anonymous sign in failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(response.user!));
    } on AuthException catch (e) {
      // If anonymous auth is not enabled in Supabase project
      if (e.message.contains('not allowed')) {
        return const BackendResult.failure(
          BackendError(
            message: 'Anonymous auth not enabled in Supabase project',
            code: BackendErrorCode.operationNotAllowed,
          ),
        );
      }
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<BackendUser>> linkWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Link anonymous account with email
      await _auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Link with email failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<BackendUser>> linkWithOAuth(
      backend.OAuthProvider provider) async {
    try {
      // Supabase handles OAuth linking via identity linking
      final supabaseProvider = _mapOAuthProvider(provider);
      await _auth.linkIdentity(supabaseProvider);
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'Link with OAuth failed',
            code: BackendErrorCode.authError,
          ),
        );
      }
      return BackendResult.success(_mapUser(user));
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Profile Management
  // ============================================================================

  @override
  Future<BackendResult<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _auth.updateUser(UserAttributes(
        data: {
          if (displayName != null) 'display_name': displayName,
          if (photoUrl != null) 'avatar_url': photoUrl,
        },
      ));
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      // Re-authenticate first
      final currentEmail = _auth.currentUser?.email;
      if (currentEmail == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'No current user email',
            code: BackendErrorCode.unauthorized,
          ),
        );
      }

      // Verify password by signing in
      await _auth.signInWithPassword(
        email: currentEmail,
        password: currentPassword,
      );

      // Update email
      await _auth.updateUser(UserAttributes(email: newEmail));
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Re-authenticate first
      final currentEmail = _auth.currentUser?.email;
      if (currentEmail == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'No current user email',
            code: BackendErrorCode.unauthorized,
          ),
        );
      }

      // Verify password by signing in
      await _auth.signInWithPassword(
        email: currentEmail,
        password: currentPassword,
      );

      // Update password
      await _auth.updateUser(UserAttributes(password: newPassword));
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> sendEmailVerification() async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'No email to verify',
            code: BackendErrorCode.invalidData,
          ),
        );
      }
      await _auth.resend(type: OtpType.signup, email: email);
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> verifyEmail({required String code}) async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'No email to verify',
            code: BackendErrorCode.invalidData,
          ),
        );
      }
      await _auth.verifyOTP(type: OtpType.signup, token: code, email: email);
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Session Management
  // ============================================================================

  @override
  Future<BackendResult<void>> signOut() async {
    try {
      await _auth.signOut();
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> deleteAccount({String? password}) async {
    try {
      // Supabase requires admin API to delete users
      // For client-side, we can disable the account via RPC
      // This requires a Supabase Edge Function or custom RPC
      return const BackendResult.failure(
        BackendError(
          message: 'Account deletion requires server-side implementation',
          code: BackendErrorCode.operationNotAllowed,
        ),
      );
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<String>> refreshToken() async {
    try {
      final response = await _auth.refreshSession();
      final token = response.session?.accessToken;
      if (token == null) {
        return const BackendResult.failure(
          BackendError(
            message: 'No session to refresh',
            code: BackendErrorCode.tokenExpired,
          ),
        );
      }
      return BackendResult.success(token);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await _auth.refreshSession();
    }
    return _auth.currentSession?.accessToken;
  }

  // ============================================================================
  // Re-authentication
  // ============================================================================

  @override
  Future<BackendResult<void>> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  @override
  Future<BackendResult<void>> reauthenticateWithOAuth(
      backend.OAuthProvider provider) async {
    try {
      final supabaseProvider = _mapOAuthProvider(provider);
      await _auth.signInWithOAuth(
        supabaseProvider,
        redirectTo: 'io.supabase.guardiancare://login-callback/',
      );
      return const BackendResult.success(null);
    } on AuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } catch (e) {
      return BackendResult.failure(
        BackendError(message: e.toString(), code: BackendErrorCode.unknown),
      );
    }
  }

  // ============================================================================
  // Helpers
  // ============================================================================

  BackendUser _mapUser(User user) {
    return BackendUser(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String? ??
          user.userMetadata?['full_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
      isAnonymous: user.isAnonymous,
      createdAt: DateTime.tryParse(user.createdAt),
      metadata: user.userMetadata ?? {},
    );
  }

  BackendError _mapAuthError(AuthException e) {
    final code = switch (e.statusCode) {
      '400' => BackendErrorCode.invalidEmail,
      '401' => BackendErrorCode.unauthorized,
      '404' => BackendErrorCode.userNotFound,
      '422' => BackendErrorCode.weakPassword,
      '429' => BackendErrorCode.rateLimited,
      _ => BackendErrorCode.authError,
    };
    return BackendError(message: e.message, code: code);
  }

  OAuthProvider _mapOAuthProvider(backend.OAuthProvider provider) {
    // Map from our backend OAuthProvider to Supabase's OAuthProvider
    return switch (provider) {
      backend.OAuthProvider.google => OAuthProvider.google,
      backend.OAuthProvider.facebook => OAuthProvider.facebook,
      backend.OAuthProvider.apple => OAuthProvider.apple,
      backend.OAuthProvider.github => OAuthProvider.github,
      backend.OAuthProvider.twitter => OAuthProvider.twitter,
      backend.OAuthProvider.microsoft =>
        OAuthProvider.azure, // Microsoft -> Azure in Supabase
    };
  }
}
