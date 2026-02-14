import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/authentication/data/models/user_model.dart';

/// Abstract class defining authentication remote data source operations
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String role,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  Future<void> updateUserProfile({String? displayName, String? photoURL});
}

/// Implementation of AuthRemoteDataSource using IAuthService and IDataStore.
///(firebase)
/// This adapter class bridges the legacy AuthRemoteDataSource interface
/// with the new Backend Abstraction Layer.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  AuthRemoteDataSourceImpl({
    required IAuthService authService,
    required IDataStore dataStore,
  })  : _authService = authService,
        _dataStore = dataStore;
  final IAuthService _authService;
  final IDataStore _dataStore;

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // Check if result is success to handle the user
      if (result.isSuccess && result.dataOrNull != null) {
        final user = result.dataOrNull!;
        // Check if email is verified
        if (!user.emailVerified) {
          // Do not sign out here, so we can send verification email if needed
          throw const AuthException(
            ErrorStrings.emailNotVerified,
            code: 'email-not-verified',
          );
        }

        // Get user role from Data Store
        final userDocResult = await _dataStore.get('users', user.id);

        String? role;
        if (userDocResult.isSuccess && userDocResult.dataOrNull != null) {
          role = userDocResult.dataOrNull!['role'] as String?;

          // Update email verified status in data store
          await _dataStore.update('users', user.id, {'emailVerified': true});
        }

        return UserModel.fromBackendUser(user, role: role);
      } else {
        throw _mapToAuthException(result.errorOrNull!);
      }
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
          ErrorStrings.withDetails(ErrorStrings.signInFailed, e.toString()));
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String role,
  ) async {
    try {
      final result = await _authService.createUserWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      return await result.when(
        success: (user) async {
          // Send email verification
          await _authService.sendEmailVerification();

          // Store user data in Data Store
          await _dataStore.set('users', user.id, {
            'uid': user.id,
            'email': email,
            'displayName': displayName,
            'role': role,
            'createdAt': DateTime.now().toIso8601String(),
            'photoURL': null,
            'emailVerified': false,
          });

          return UserModel.fromBackendUser(user, role: role);
        },
        failure: (error) {
          throw _mapToAuthException(error);
        },
      );
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
          ErrorStrings.withDetails(ErrorStrings.signUpFailed, e.toString()));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final result = await _authService.signInWithGoogle();

      return await result.when(
        success: (user) async {
          // Check if user exists in Data Store
          final docResult = await _dataStore.get('users', user.id);

          String? role;
          if (docResult.isSuccess && docResult.dataOrNull != null) {
            role = docResult.dataOrNull!['role'] as String?;
          } else {
            // New user
            role = 'parent';
            await _dataStore.set('users', user.id, {
              'uid': user.id,
              'email': user.email,
              'displayName': user.displayName,
              'photoURL': user.photoUrl,
              'role': role,
              'createdAt': DateTime.now().toIso8601String(),
            });
          }

          return UserModel.fromBackendUser(user, role: role);
        },
        failure: (error) {
          // Handle Google specific failure messages if needed
          if (error.message.contains('SHA-1')) {
            throw const AuthException(
                'Google Sign-In failed. Please ensure SHA-1 certificate is configured.',
                code: 'sign_in_failed');
          }
          throw _mapToAuthException(error);
        },
      );
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(ErrorStrings.withDetails(
          ErrorStrings.googleSignInFailed, e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on Object catch (e) {
      throw AuthException(
          ErrorStrings.withDetails(ErrorStrings.signOutFailed, e.toString()));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      // Enforce email verification for persistent sessions
      if (!user.emailVerified) {
        // Do not sign out, but return null to treat as unauthenticated in UI
        return null;
      }

      final docResult = await _dataStore.get('users', user.id);
      String? role;
      if (docResult.isSuccess && docResult.dataOrNull != null) {
        role = docResult.dataOrNull!['role'] as String?;
      }

      return UserModel.fromBackendUser(user, role: role);
    } on Object catch (e) {
      throw AuthException(ErrorStrings.withDetails(
          ErrorStrings.getCurrentUserError, e.toString()));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final result = await _authService.sendPasswordResetEmail(email: email);
      if (result.isFailure) {
        throw _mapToAuthException(result.errorOrNull!);
      }
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(ErrorStrings.withDetails(
          ErrorStrings.sendPasswordResetError, e.toString()));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final result = await _authService.sendEmailVerification();
      if (result.isFailure) {
        throw _mapToAuthException(result.errorOrNull!);
      }
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      // Using generic error or existing one
      throw AuthException(ErrorStrings.withDetails(
          'Failed to send verification email', e.toString()));
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final result = await _authService.reload();
      if (result.isFailure) {
        throw _mapToAuthException(result.errorOrNull!);
      }
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
          ErrorStrings.withDetails('Failed to reload user', e.toString()));
    }
  }

  @override
  Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw const AuthException(ErrorStrings.noUserSignedIn);
      }

      // Update Auth Profile
      if (displayName != null || photoURL != null) {
        final result = await _authService.updateProfile(
          displayName: displayName,
          photoUrl: photoURL,
        );
        if (result.isFailure) throw _mapToAuthException(result.errorOrNull!);
      }

      // Update Data Store
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;

      if (updates.isNotEmpty) {
        await _dataStore.update('users', user.id, updates);
      }
    } on Object catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(ErrorStrings.withDetails(
          ErrorStrings.updateProfileError, e.toString()));
    }
  }

  AuthException _mapToAuthException(BackendError error) {
    // Map BackendErrorCode back to legacy string codes or friendly messages
    String code = 'auth-error';
    switch (error.code) {
      case BackendErrorCode.userNotFound:
        code = 'user-not-found';
        break;
      case BackendErrorCode.emailAlreadyInUse:
        code = 'email-already-in-use';
        break;
      case BackendErrorCode.weakPassword:
        code = 'weak-password';
        break;
      case BackendErrorCode.invalidCredentials:
        code = 'wrong-password';
        break;
      case BackendErrorCode.networkError:
        code = 'network-request-failed';
        break;
      default:
        code = error.code.name;
    }

    // We can use the message from BackendError directly as it usually contains the mapped error message from the adapter
    return AuthException(error.message, code: code);
  }
}
