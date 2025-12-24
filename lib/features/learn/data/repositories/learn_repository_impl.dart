import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/features/learn/data/datasources/learn_remote_datasource.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';

/// Implementation of LearnRepository
class LearnRepositoryImpl implements LearnRepository {
  final LearnRemoteDataSource remoteDataSource;

  LearnRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getVideosByCategory(
      String category) async {
    try {
      final videos = await remoteDataSource.getVideosByCategory(category);
      return Right(videos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get videos by category: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<VideoEntity>>> getVideosByCategoryStream(
      String category) {
    try {
      return remoteDataSource.getVideosByCategoryStream(category).map(
            (videos) => Right<Failure, List<VideoEntity>>(videos),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to stream videos: ${e.toString()}')),
      );
    }
  }
}
