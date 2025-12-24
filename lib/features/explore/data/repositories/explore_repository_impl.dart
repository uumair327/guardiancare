import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:guardiancare/features/explore/domain/entities/recommendation.dart';
import 'package:guardiancare/features/explore/domain/entities/resource.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<Either<Failure, List<Recommendation>>> getRecommendations(
      String userId) {
    try {
      return remoteDataSource.getRecommendations(userId).map(
            (recommendations) => Right<Failure, List<Recommendation>>(
              recommendations,
            ),
          );
    } catch (e) {
      return Stream.value(
        Left(ServerFailure(e.toString())),
      );
    }
  }

  @override
  Stream<Either<Failure, List<Resource>>> getResources() {
    return remoteDataSource.getResources().map(
      (resources) => Right<Failure, List<Resource>>(resources),
    ).handleError((error) {
      return Left<Failure, List<Resource>>(
        ServerFailure(error.toString()),
      );
    });
  }
}
