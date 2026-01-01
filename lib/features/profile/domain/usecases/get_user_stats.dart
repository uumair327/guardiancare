import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';
import 'package:guardiancare/features/profile/domain/repositories/user_stats_repository.dart';

/// Use case for fetching user statistics.
/// 
/// Single Responsibility: Only handles fetching aggregated user stats.
/// This use case combines quiz results, video history, and badge data
/// into a unified [UserStatsEntity].
class GetUserStats implements UseCase<UserStatsEntity, String> {
  final UserStatsRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, UserStatsEntity>> call(String userId) {
    return repository.getUserStats(userId);
  }
}
