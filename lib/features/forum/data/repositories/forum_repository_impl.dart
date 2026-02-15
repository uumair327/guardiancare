import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/core/network/network.dart';
import 'package:guardiancare/features/forum/data/datasources/forum_remote_datasource.dart';
import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/domain/entities/user_details_entity.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

/// Implementation of ForumRepository
class ForumRepositoryImpl implements ForumRepository {
  ForumRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final ForumRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Stream<Either<Failure, List<ForumEntity>>> getForums(
      ForumCategory category) async* {
    if (!await networkInfo.isConnected) {
      yield const Left(NetworkFailure(ErrorStrings.noInternet));
    }

    try {
      await for (final forums in remoteDataSource.getForums(category)) {
        yield Right(forums);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message, code: e.code));
    } on Object catch (e) {
      yield Left(ServerFailure(ErrorStrings.withDetails(
          ErrorStrings.unexpectedError, e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<CommentEntity>>> getComments(
      String forumId) async* {
    try {
      await for (final comments in remoteDataSource.getComments(forumId)) {
        yield Right(comments);
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message, code: e.code));
    } on Object catch (e) {
      yield Left(ServerFailure(ErrorStrings.withDetails(
          ErrorStrings.unexpectedError, e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> addComment({
    required String forumId,
    required String text,
    required String userId,
    String? parentId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addComment(forumId, text, userId,
            parentId: parentId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } on Object catch (e) {
        return Left(ServerFailure(ErrorStrings.withDetails(
            ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return const Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, UserDetailsEntity>> getUserDetails(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final userDetails = await remoteDataSource.getUserDetails(userId);
        return Right(userDetails);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } on Object catch (e) {
        return Left(ServerFailure(ErrorStrings.withDetails(
            ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return const Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, String>> createForum({
    required String title,
    required String description,
    required ForumCategory category,
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final forumId = await remoteDataSource.createForum(
          title,
          description,
          category,
          userId,
        );
        return Right(forumId);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } on Object catch (e) {
        return Left(ServerFailure(ErrorStrings.withDetails(
            ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return const Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, void>> deleteForum(String forumId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteForum(forumId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } on Object catch (e) {
        return Left(ServerFailure(ErrorStrings.withDetails(
            ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return const Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String forumId,
    required String commentId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteComment(forumId, commentId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } on Object catch (e) {
        return Left(ServerFailure(ErrorStrings.withDetails(
            ErrorStrings.unexpectedError, e.toString())));
      }
    } else {
      return const Left(NetworkFailure(ErrorStrings.noInternet));
    }
  }
}
