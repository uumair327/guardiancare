import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_recommended_resources.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_recommended_videos.dart';
import 'package:guardiancare/features/explore/domain/usecases/search_resources.dart';
import 'package:guardiancare/features/explore/presentation/bloc/explore_event.dart';
import 'package:guardiancare/features/explore/presentation/bloc/explore_state.dart';

/// BLoC for managing explore state
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetRecommendedVideos getRecommendedVideos;
  final GetRecommendedResources getRecommendedResources;
  final SearchResources searchResources;

  ExploreBloc({
    required this.getRecommendedVideos,
    required this.getRecommendedResources,
    required this.searchResources,
  }) : super(ExploreInitial()) {
    on<LoadRecommendedVideos>(_onLoadRecommendedVideos);
    on<LoadRecommendedResources>(_onLoadRecommendedResources);
    on<SearchResourcesRequested>(_onSearchResources);
  }

  Future<void> _onLoadRecommendedVideos(
    LoadRecommendedVideos event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());

    // Note: Stream handling - emit initial loading then listen to stream
    await emit.forEach(
      getRecommendedVideos(event.uid),
      onData: (result) {
        return result.fold(
          (failure) => ExploreError(failure.message),
          (videos) => RecommendedVideosLoaded(videos),
        );
      },
    );
  }

  Future<void> _onLoadRecommendedResources(
    LoadRecommendedResources event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());

    await emit.forEach(
      getRecommendedResources(NoParams()),
      onData: (result) {
        return result.fold(
          (failure) => ExploreError(failure.message),
          (resources) => RecommendedResourcesLoaded(resources),
        );
      },
    );
  }

  Future<void> _onSearchResources(
    SearchResourcesRequested event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreSearching());

    final result = await searchResources(event.query);

    result.fold(
      (failure) => emit(ExploreError(failure.message)),
      (resources) => emit(SearchResultsLoaded(resources, event.query)),
    );
  }
}
