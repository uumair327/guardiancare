import '../models/backend_result.dart';
import '../models/backend_user.dart';

/// Authentication service port (interface).
///
/// This is the PORT in Hexagonal Architecture - it defines what the application
/// needs from an authentication service WITHOUT specifying how it's implemented.
///
/// ## Implementations
/// - `FirebaseAuthAdapter` - Firebase Authentication
/// - `SupabaseAuthAdapter` - Supabase Auth (future)
/// - `MockAuthAdapter` - For testing
///
/// ## Usage
/// ```dart
/// class AuthBloc {
///   final IAuthService authService;
///
///   AuthBloc(this.authService);
///
///   Future<void> signIn(String email, String password) async {
///     final result = await authService.signInWithEmail(
///       email: email,
///       password: password,
///     );
///     result.when(
///       success: (user) => emit(Authenticated(user)),
///       failure: (error) => emit(AuthError(error.message)),
///     );
///   }
/// }
/// ```
abstract interface class IAuthService {
  // ==================== Current User ====================
  /// Get the currently authenticated user, or null if not authenticated
  BackendUser? get currentUser;

  /// Stream of authentication state changes
  Stream<BackendUser?> get authStateChanges;

  /// Stream of user changes (including profile updates)
  Stream<BackendUser?> get userChanges;

  /// Check if a user is currently signed in
  bool get isSignedIn;

  // ==================== Email/Password Auth ====================
  /// Sign in with email and password
  Future<BackendResult<BackendUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Create a new account with email and password
  Future<BackendResult<BackendUser>> createUserWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Send password reset email
  Future<BackendResult<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Confirm password reset with code and new password
  Future<BackendResult<void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  // ==================== OAuth Providers ====================
  /// Sign in with Google
  Future<BackendResult<BackendUser>> signInWithGoogle();

  /// Sign in with Apple
  Future<BackendResult<BackendUser>> signInWithApple();

  /// Sign in with any OAuth provider
  Future<BackendResult<BackendUser>> signInWithOAuth(OAuthProvider provider);

  // ==================== Anonymous Auth ====================
  /// Sign in anonymously
  Future<BackendResult<BackendUser>> signInAnonymously();

  /// Link anonymous account to email/password
  Future<BackendResult<BackendUser>> linkWithEmail({
    required String email,
    required String password,
  });

  /// Link anonymous account to OAuth provider
  Future<BackendResult<BackendUser>> linkWithOAuth(OAuthProvider provider);

  // ==================== Profile Management ====================
  /// Update user profile
  Future<BackendResult<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Update user email
  Future<BackendResult<void>> updateEmail({
    required String newEmail,
    required String currentPassword,
  });

  /// Update user password
  Future<BackendResult<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Send email verification
  Future<BackendResult<void>> sendEmailVerification();

  /// Verify email with code
  Future<BackendResult<void>> verifyEmail({required String code});

  // ==================== Session Management ====================
  /// Sign out the current user
  Future<BackendResult<void>> signOut();

  /// Delete the current user's account
  Future<BackendResult<void>> deleteAccount({String? password});

  /// Refresh the current user's authentication token
  Future<BackendResult<String>> refreshToken();

  /// Get the current authentication token
  Future<String?> getIdToken({bool forceRefresh = false});

  // ==================== Re-authentication ====================
  /// Re-authenticate user (for sensitive operations)
  Future<BackendResult<void>> reauthenticate({
    required String email,
    required String password,
  });

  /// Reload user data (e.g. email verification status)
  Future<BackendResult<void>> reload();

  /// Re-authenticate with OAuth
  Future<BackendResult<void>> reauthenticateWithOAuth(OAuthProvider provider);
}

// OAuthProvider is exported from backend_user.dart
