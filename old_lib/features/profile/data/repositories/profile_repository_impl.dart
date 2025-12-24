import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:guardiancare/features/profile/data/models/profile_model.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String uid) async {
    try {
      final profile = await remoteDataSource.getProfile(uid);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(ProfileEntity profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      await remoteDataSource.updateProfile(profileModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String uid) async {
    try {
      await remoteDataSource.deleteAccount(uid);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete account: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearUserPreferences() async {
    try {
      await remoteDataSource.clearUserPreferences();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to clear preferences: ${e.toString()}'));
    }
  }
}
