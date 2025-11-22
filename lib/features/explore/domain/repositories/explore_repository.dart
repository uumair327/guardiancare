import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/explore/domain/entities/resource_entity.dart';
import 'package:guardiancare/features/explore/domain/entities/video_entity.dart';

/// Explore repository interface defining explore operations
abstract class ExploreRepository {
  /// Get recommended videos for current user
  Stream<Either<Failure, List<VideoEntity>>> getRecommendedVideos(String uid);

  /// Get recommended resources
  Stream<Either<Failure, List<ResourceEntity>>> getRecommendedResources();

  /// Search resources by query
  Future<Either<Failure, List<ResourceEntity>>> searchResources(String query);
}
