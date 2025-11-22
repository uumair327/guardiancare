import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:guardiancare/features/explore/domain/entities/resource_entity.dart';
import 'package:guardiancare/features/explore/domain/entities/video_entity.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

/// Implementation of ExploreRepository
class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<VideoEntity>>> getRecommendedVideos(
      String uid) {
    try {
      return remoteDataSource.getRecommendedVideos(uid).map(
            (videos) => Right<Failure, List<VideoEntity>>(videos),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure('Failed to get recommended videos: ${e.toString()}')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<ResourceEntity>>> getRecommendedResources() {
    try {
      return remoteDataSource.getRecommendedResources().map(
            (resources) => Right<Failure, List<ResourceEntity>>(resources),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure(
            'Failed to get recommended resources: ${e.toString()}')),
      );
    }
  }

  @override
  Future<Either<Failure, List<ResourceEntity>>> searchResources(
      String query) async {
    try {
      final resources = await remoteDataSource.searchResources(query);
      return Right(resources);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to search resources: ${e.toString()}'));
    }
  }
}
