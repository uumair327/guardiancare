import 'package:flutter_bloc/flutter_bloc.dart';
import 'learn_event.dart';
import 'learn_state.dart';
import '../repositories/learn_repository.dart';

class LearnBloc extends Bloc<LearnEvent, LearnState> {
  final LearnRepository _repository;

  LearnBloc({LearnRepository? repository})
      : _repository = repository ?? FirebaseLearnRepository(),
        super(LearnInitial()) {
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
    try {
      print('🟢 BLoC Created: LearnBloc at ${DateTime.now()}');
      print('📥 Event [LearnBloc]: CategoriesRequested (1ms)');
      print('🔄 State Change [LearnBloc]: ${state.runtimeType} → LearnLoading');
      
      emit(LearnLoading());

      final categories = await _repository.getCategories();
      
      print('📥 Event [LearnBloc]: CategoriesRequested (1ms)');
      print('🔄 State Change [LearnBloc]: LearnLoading → CategoriesLoaded');
      print('LearnBloc: Loaded ${categories.length} categories');
      
      emit(CategoriesLoaded(categories));
    } catch (e) {
      print('LearnBloc: Error loading categories: $e');
      emit(LearnError('Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<LearnState> emit,
  ) async {
    print('📥 Event [LearnBloc]: CategorySelected (1ms)');
    print('🔄 State Change [LearnBloc]: CategoriesLoaded → VideosLoading');
    
    emit(VideosLoading(event.categoryName));
    add(VideosRequested(event.categoryName));
  }

  Future<void> _onVideosRequested(
    VideosRequested event,
    Emitter<LearnState> emit,
  ) async {
    try {
      print('LearnBloc: Loading videos for category: "${event.category}"');

      final videos = await _repository.getVideosByCategory(event.category);

      print('LearnBloc: Emitting VideosLoaded with ${videos.length} videos');
      emit(VideosLoaded(event.category, videos));
    } catch (e) {
      print('LearnBloc: Error loading videos: $e');
      emit(LearnError('Failed to load videos: ${e.toString()}'));
    }
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