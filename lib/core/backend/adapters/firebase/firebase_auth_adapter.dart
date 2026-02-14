import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/backend_result.dart';
import '../../models/backend_user.dart';
import '../../ports/auth_service_port.dart';

/// Firebase Authentication adapter.
///
/// This is the ADAPTER in Hexagonal Architecture - it implements the
/// [IAuthService] port using Firebase Authentication.
///
/// ## Switching to Another Provider
/// To switch to Supabase, create a `SupabaseAuthAdapter` that implements
/// [IAuthService] and register it in the dependency injection container:
///
/// ```dart
/// // Before (Firebase)
/// sl.registerLazySingleton<IAuthService>(() => FirebaseAuthAdapter());
///
/// // After (Supabase)
/// sl.registerLazySingleton<IAuthService>(() => SupabaseAuthAdapter());
/// ```
class FirebaseAuthAdapter implements IAuthService {
  FirebaseAuthAdapter({
    fb.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
              serverClientId:
                  '480855529488-809q7ih0n0vhoqrj47pgk986u4kobt1h.apps.googleusercontent.com',
            );

  final fb.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ==================== Current User ====================
  @override
  BackendUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Stream<BackendUser?> get authStateChanges =>
      _auth.authStateChanges().map(_mapFirebaseUser);

  @override
  Stream<BackendUser?> get userChanges =>
      _auth.userChanges().map(_mapFirebaseUser);

  @override
  bool get isSignedIn => _auth.currentUser != null;

  // ==================== Email/Password Auth ====================
  @override
  Future<BackendResult<BackendUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return BackendResult.success(_mapFirebaseUser(credential.user)!);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<BackendUser>> createUserWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      return BackendResult.success(_mapFirebaseUser(credential.user)!);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== OAuth Providers ====================
  @override
  Future<BackendResult<BackendUser>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'Google sign-in was cancelled',
        ));
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return BackendResult.success(_mapFirebaseUser(userCredential.user)!);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<BackendUser>> signInWithApple() async {
    try {
      final appleProvider = fb.AppleAuthProvider();
      final credential = await _auth.signInWithProvider(appleProvider);
      return BackendResult.success(_mapFirebaseUser(credential.user)!);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<BackendUser>> signInWithOAuth(
    OAuthProvider provider,
  ) async {
    return switch (provider) {
      OAuthProvider.google => signInWithGoogle(),
      OAuthProvider.apple => signInWithApple(),
      _ => BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'OAuth provider ${provider.name} not supported',
        )),
    };
  }

  // ==================== Anonymous Auth ====================
  @override
  Future<BackendResult<BackendUser>> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return BackendResult.success(_mapFirebaseUser(credential.user)!);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<BackendUser>> linkWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      final credential = fb.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final result = await user.linkWithCredential(credential);
      return BackendResult.success(_mapFirebaseUser(result.user)!);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<BackendUser>> linkWithOAuth(
    OAuthProvider provider,
  ) async {
    // Implementation depends on provider
    return const BackendResult.failure(BackendError(
      code: BackendErrorCode.authError,
      message: 'Not implemented',
    ));
  }

  // ==================== Profile Management ====================
  @override
  Future<BackendResult<void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      // Re-authenticate first
      final credential = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);

      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      final credential = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      await user.sendEmailVerification();
      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> verifyEmail({required String code}) async {
    try {
      await _auth.applyActionCode(code);
      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  // ==================== Session Management ====================
  @override
  Future<BackendResult<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return const BackendResult.success(null);
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> deleteAccount({String? password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      // Re-authenticate if password is provided
      if (password != null && user.email != null) {
        final credential = fb.EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        // Try re-authenticating if Google provider
        final isGoogle =
            user.providerData.any((p) => p.providerId == 'google.com');
        if (isGoogle) {
          try {
            final googleUser = await _googleSignIn.signInSilently() ??
                await _googleSignIn.signIn();
            if (googleUser != null) {
              final googleAuth = await googleUser.authentication;
              final credential = fb.GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );
              await user.reauthenticateWithCredential(credential);
            }
          } on Object catch (_) {
            // Ignore google re-auth errors, proceed to try delete
          }
        }
      }

      await user.delete();

      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<String>> refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      final token = await user.getIdToken(true);
      return BackendResult.success(token ?? '');
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return _auth.currentUser?.getIdToken(forceRefresh);
  }

  // ==================== Re-authentication ====================
  @override
  Future<BackendResult<void>> reauthenticate({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      final credential = fb.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> reload() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const BackendResult.failure(BackendError(
          code: BackendErrorCode.authError,
          message: 'No user signed in',
        ));
      }

      await user.reload();
      return const BackendResult.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return BackendResult.failure(_mapAuthError(e));
    } on Exception catch (e, st) {
      return BackendResult.failure(BackendError.fromException(e, st));
    }
  }

  @override
  Future<BackendResult<void>> reauthenticateWithOAuth(
    OAuthProvider provider,
  ) async {
    return const BackendResult.failure(BackendError(
      code: BackendErrorCode.authError,
      message: 'Not implemented',
    ));
  }

  // ==================== Private Helpers ====================
  BackendUser? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;

    return BackendUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
      metadata: {
        'providerId': user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'unknown',
        'tenantId': user.tenantId ?? '',
      },
    );
  }

  BackendError _mapAuthError(fb.FirebaseAuthException e) {
    final code = switch (e.code) {
      'user-not-found' => BackendErrorCode.userNotFound,
      'wrong-password' => BackendErrorCode.invalidCredentials,
      'invalid-credential' => BackendErrorCode.invalidCredentials,
      'email-already-in-use' => BackendErrorCode.emailAlreadyInUse,
      'weak-password' => BackendErrorCode.weakPassword,
      'expired-action-code' => BackendErrorCode.tokenExpired,
      'invalid-action-code' => BackendErrorCode.invalidCredentials,
      'network-request-failed' => BackendErrorCode.networkError,
      _ => BackendErrorCode.authError,
    };

    return BackendError(
      code: code,
      message: e.message ?? e.code,
      details: {'firebaseCode': e.code},
    );
  }
}
