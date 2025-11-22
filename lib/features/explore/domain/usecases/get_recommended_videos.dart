import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/explore/domain/entities/video_entity.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

/// Use case for getting recommended videos
class GetRecommendedVideos {
  final ExploreRepository repository;

  GetRecommendedVideos(this.repository);

  Stream<Either<Failure, List<VideoEntity>>> call(String uid) {
    return repository.getRecommendedVideos(uid);
  }
}
