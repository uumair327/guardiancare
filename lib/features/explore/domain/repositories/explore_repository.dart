import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/explore/domain/entities/recommendation.dart';
import 'package:guardiancare/features/explore/domain/entities/resource.dart';

abstract class ExploreRepository {
  Stream<Either<Failure, List<Recommendation>>> getRecommendations(String userId);
  Stream<Either<Failure, List<Resource>>> getResources();
}
