import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';
import 'package:guardiancare/features/profile/domain/usecases/get_user_stats.dart';

/// Cubit for managing user statistics state.
/// 
/// Separated from ProfileBloc following Single Responsibility Principle.
/// Handles quiz, video, and badge statistics independently.
class UserStatsCubit extends Cubit<UserStatsState> {
  final GetUserStats? getUserStats;

  UserStatsCubit({this.getUserStats}) : super(UserStatsInitial());

  /// Load user statistics for the given user ID
  Future<void> loadStats(String userId) async {
    // Skip if getUserStats is not available (web platform)
    if (getUserStats == null) {
      emit(const UserStatsLoaded(UserStatsEntity.empty));
      return;
    }

    emit(UserStatsLoading());

    final result = await getUserStats!(userId);

    result.fold(
      (failure) => emit(UserStatsError(failure.message)),
      (stats) => emit(UserStatsLoaded(stats)),
    );
  }

  /// Refresh stats (useful after completing a quiz or video)
  Future<void> refreshStats(String userId) => loadStats(userId);
}

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
  final UserStatsEntity stats;

  const UserStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Error state when loading fails
class UserStatsError extends UserStatsState {
  final String message;

  const UserStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
