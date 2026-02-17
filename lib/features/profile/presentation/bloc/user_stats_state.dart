import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';

/// Base state for user statistics
abstract class UserStatsState extends Equatable {
  const UserStatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class UserStatsInitial extends UserStatsState {}

/// Loading state while fetching stats
class UserStatsLoading extends UserStatsState {}

/// Stats loaded successfully
class UserStatsLoaded extends UserStatsState {
  const UserStatsLoaded(this.stats);
  final UserStatsEntity stats;

  @override
  List<Object?> get props => [stats];
}

/// Error state when loading fails
class UserStatsError extends UserStatsState {
  const UserStatsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
