import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';

/// Repository interface for user statistics operations.
/// 
/// Follows the Dependency Inversion Principle - domain layer
/// defines the interface, data layer provides implementation.
abstract class UserStatsRepository {
  /// Fetches aggregated user statistics including quiz, video, and badge data.
  /// 
  /// Returns [UserStatsEntity] on success or [Failure] on error.
  Future<Either<Failure, UserStatsEntity>> getUserStats(String userId);
  
  /// Calculates and returns badges earned by the user based on their activity.
  /// 
  /// Badge calculation is done locally based on quiz and video stats.
  Future<Either<Failure, List<BadgeEntity>>> calculateBadges(String userId);
}
