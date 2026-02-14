import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });

  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Check if user is signed in
  Future<Either<Failure, bool>> isSignedIn();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, void>> reloadUser();

  /// Update user profile
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  });
}
