import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/profile/domain/entities/user_stats_entity.dart';
import 'package:guardiancare/features/profile/domain/usecases/get_user_stats.dart';
import 'package:guardiancare/features/profile/presentation/bloc/user_stats_state.dart';

/// Cubit for managing user statistics state.
///
/// Separated from ProfileBloc following Single Responsibility Principle.
/// Handles quiz, video, and badge statistics independently.
class UserStatsCubit extends Cubit<UserStatsState> {
  UserStatsCubit({this.getUserStats}) : super(UserStatsInitial());
  final GetUserStats? getUserStats;

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
