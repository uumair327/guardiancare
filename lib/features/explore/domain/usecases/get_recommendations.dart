import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/explore/domain/entities/recommendation.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

class GetRecommendations {
  final ExploreRepository repository;

  GetRecommendations(this.repository);

  Stream<Either<Failure, List<Recommendation>>> call(String userId) {
    return repository.getRecommendations(userId);
  }
}
