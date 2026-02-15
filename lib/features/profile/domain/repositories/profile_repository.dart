import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';

/// Profile repository interface defining profile operations
abstract class ProfileRepository {
  /// Get user profile by user ID
  Future<Either<Failure, ProfileEntity>> getProfile(String uid);

  /// Update user profile
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile);

  /// Delete user account and all associated data
  Future<Either<Failure, void>> deleteAccount(String uid, {String? password});

  /// Clear user preferences
  Future<Either<Failure, void>> clearUserPreferences();
}
