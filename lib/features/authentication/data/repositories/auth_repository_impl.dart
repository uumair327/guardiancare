import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/core/network/network.dart';
import 'package:guardiancare/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithEmailAndPassword(
          email,
          password,
        );
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signUpWithEmailAndPassword(
          email,
          password,
          displayName,
          role,
        );
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithGoogle();
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user != null);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateUserProfile(
          displayName: displayName,
          photoURL: photoURL,
        );
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(ErrorStrings.withDetails(ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }
}
