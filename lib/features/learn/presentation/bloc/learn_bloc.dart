import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_categories.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_by_category.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_stream.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_event.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_state.dart';

/// BLoC for managing learn state
class LearnBloc extends Bloc<LearnEvent, LearnState> {
  final GetCategories getCategories;
  final GetVideosByCategory getVideosByCategory;
  final GetVideosStream getVideosStream;

  LearnBloc({
    required this.getCategories,
    required this.getVideosByCategory,
    required this.getVideosStream,
  }) : super(LearnInitial()) {
    on<CategoriesRequested>(_onCategoriesRequested);
    on<CategorySelected>(_onCategorySelected);
    on<VideosRequested>(_onVideosRequested);
    on<BackToCategories>(_onBackToCategories);
    on<RetryRequested>(_onRetryRequested);
  }

  Future<void> _onCategoriesRequested(
    CategoriesRequested event,
    Emitter<LearnState> emit,
  ) async {
    emit(LearnLoading());

    final result = await getCategories(NoParams());

    result.fold(
      (failure) => emit(LearnError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<LearnState> emit,
  ) async {
    // Emit VideosLoaded immediately - UI will use stream for real-time updates
    emit(VideosLoaded(event.categoryName, const []));
  }

  Future<void> _onVideosRequested(
    VideosRequested event,
    Emitter<LearnState> emit,
  ) async {
    emit(VideosLoading(event.category));

    final result = await getVideosByCategory(event.category);

    result.fold(
      (failure) => emit(LearnError(failure.message)),
      (videos) => emit(VideosLoaded(event.category, videos)),
    );
  }

  Future<void> _onBackToCategories(
    BackToCategories event,
    Emitter<LearnState> emit,
  ) async {
    add(CategoriesRequested());
  }

  Future<void> _onRetryRequested(
    RetryRequested event,
    Emitter<LearnState> emit,
  ) async {
    if (state is LearnError) {
      add(CategoriesRequested());
    }
  }
}
