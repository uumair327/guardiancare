import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/features/consent/data/datasources/consent_local_datasource.dart';
import 'package:guardiancare/features/consent/data/datasources/consent_remote_datasource.dart';
import 'package:guardiancare/features/consent/data/models/consent_model.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class ConsentRepositoryImpl implements ConsentRepository {
  final ConsentRemoteDataSource remoteDataSource;
  final ConsentLocalDataSource localDataSource;

  ConsentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> submitConsent(ConsentEntity consent, String uid) async {
    try {
      final model = ConsentModel.fromEntity(consent);
      await remoteDataSource.submitConsent(model, uid);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to submit consent: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyParentalKey(String uid, String key) async {
    try {
      final result = await remoteDataSource.verifyParentalKey(uid, key);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to verify key: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetParentalKey(
      String uid, String securityAnswer, String newKey) async {
    try {
      await remoteDataSource.resetParentalKey(uid, securityAnswer, newKey);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to reset key: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ConsentEntity>> getConsent(String uid) async {
    try {
      final consent = await remoteDataSource.getConsent(uid);
      return Right(consent);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get consent: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasConsent(String uid) async {
    try {
      final result = await remoteDataSource.hasConsent(uid);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check consent: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveParentalKeyLocally(String key) async {
    try {
      await localDataSource.saveParentalKey(key);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save parental key locally: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> getLocalParentalKey() async {
    try {
      final key = await localDataSource.getParentalKey();
      return Right(key);
    } catch (e) {
      return Left(CacheFailure('Failed to get local parental key: ${e.toString()}'));
    }
  }
}
