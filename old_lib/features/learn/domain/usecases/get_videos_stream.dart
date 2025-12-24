import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';

/// Use case for getting videos by category as a stream
class GetVideosStream {
  final LearnRepository repository;

  GetVideosStream(this.repository);

  Stream<Either<Failure, List<VideoEntity>>> call(String category) {
    return repository.getVideosByCategoryStream(category);
  }
}
