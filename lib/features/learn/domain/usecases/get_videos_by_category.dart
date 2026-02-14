import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';

/// Use case for getting videos by category
class GetVideosByCategory implements UseCase<List<VideoEntity>, String> {

  GetVideosByCategory(this.repository);
  final LearnRepository repository;

  @override
  Future<Either<Failure, List<VideoEntity>>> call(String category) async {
    return repository.getVideosByCategory(category);
  }
}
