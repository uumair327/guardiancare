import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/profile/data/datasources/user_stats_local_datasource.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';
import 'package:guardiancare/features/profile/domain/repositories/user_stats_repository.dart';

/// Implementation of [UserStatsRepository].
/// 
/// Handles data fetching from local data source with proper
/// error handling and failure mapping.
class UserStatsRepositoryImpl implements UserStatsRepository {

  UserStatsRepositoryImpl({required this.localDataSource});
  final UserStatsLocalDataSource localDataSource;

  @override
  Future<Either<Failure, UserStatsEntity>> getUserStats(String userId) async {
    try {
      final stats = await localDataSource.getUserStats(userId);
      return Right(stats);
    } on Object catch (e) {
      return Left(CacheFailure(
        'Failed to load user statistics: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, List<BadgeEntity>>> calculateBadges(
    String userId,
  ) async {
    try {
      final badges = await localDataSource.calculateBadges(userId);
      return Right(badges);
    } on Object catch (e) {
      return Left(CacheFailure(
        'Failed to calculate badges: ${e.toString()}',
      ));
    }
  }
}
