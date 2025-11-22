import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/explore/domain/entities/resource_entity.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

/// Use case for getting recommended resources
class GetRecommendedResources {
  final ExploreRepository repository;

  GetRecommendedResources(this.repository);

  Stream<Either<Failure, List<ResourceEntity>>> call(NoParams params) {
    return repository.getRecommendedResources();
  }
}
