import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:guardiancare/features/profile/data/models/profile_model.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.remoteDataSource});
  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String uid) async {
    try {
      final profile = await remoteDataSource.getProfile(uid);
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Object catch (e) {
      return Left(ServerFailure(ErrorStrings.withDetails(
          ErrorStrings.getProfileError, e.toString())));
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
    } on Object catch (e) {
      return Left(ServerFailure(ErrorStrings.withDetails(
          ErrorStrings.updateProfileError, e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String uid,
      {String? password}) async {
    try {
      await remoteDataSource.deleteAccount(uid, password: password);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Object catch (e) {
      return Left(ServerFailure(ErrorStrings.withDetails(
          ErrorStrings.deleteAccountError, e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> clearUserPreferences() async {
    try {
      await remoteDataSource.clearUserPreferences();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on Object catch (e) {
      return Left(CacheFailure(ErrorStrings.withDetails(
          ErrorStrings.clearPreferencesError, e.toString())));
    }
  }
}
