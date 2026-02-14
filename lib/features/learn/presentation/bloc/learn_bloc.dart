import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_categories.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_by_category.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_stream.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_event.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_state.dart';

/// BLoC for managing learn state
/// 
/// This BLoC handles all business logic for the Learn feature, ensuring
/// that presentation layer (VideoPage) only dispatches events and renders UI.
/// 
/// Requirements: 3.1, 3.2, 3.3, 3.4
/// - Categories are fetched through LearnRepository (3.1)
/// - Videos are fetched through LearnRepository (3.2)
/// - VideoPage only renders UI and dispatches events (3.3)
/// - No direct Firestore queries in VideoPage (3.4)
class LearnBloc extends Bloc<LearnEvent, LearnState> {

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
  final GetCategories getCategories;
  final GetVideosByCategory getVideosByCategory;
  final GetVideosStream getVideosStream;

  /// Handles CategoriesRequested (LoadCategories) event
  /// Fetches categories through GetCategories use case
  /// Requirements: 3.1
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

  /// Handles CategorySelected event
  /// Triggers video loading for the selected category
  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<LearnState> emit,
  ) async {
    // Dispatch VideosRequested to load videos for the category
    add(VideosRequested(event.categoryName));
  }

  /// Handles VideosRequested (LoadVideosByCategory) event
  /// Fetches videos through GetVideosByCategory use case
  /// Requirements: 3.2
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

  /// Handles BackToCategories event
  /// Returns to category list view
  Future<void> _onBackToCategories(
    BackToCategories event,
    Emitter<LearnState> emit,
  ) async {
    add(CategoriesRequested());
  }

  /// Handles RetryRequested event
  /// Retries the last failed operation
  Future<void> _onRetryRequested(
    RetryRequested event,
    Emitter<LearnState> emit,
  ) async {
    if (state is LearnError) {
      add(CategoriesRequested());
    }
  }
}
