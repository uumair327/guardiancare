import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_recommendations.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_resources.dart';
import 'package:guardiancare/features/explore/presentation/bloc/explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {

  ExploreCubit({
    required this.getRecommendations,
    required this.getResources,
  }) : super(ExploreInitial());
  final GetRecommendations getRecommendations;
  final GetResources getResources;

  StreamSubscription? _recommendationsSubscription;
  StreamSubscription? _resourcesSubscription;

  void loadRecommendations(String userId) {
    emit(ExploreLoading());
    _recommendationsSubscription?.cancel();
    _recommendationsSubscription = getRecommendations(userId).listen(
      (result) {
        result.fold(
          (failure) => emit(ExploreError(failure.message)),
          (recommendations) => emit(RecommendationsLoaded(recommendations)),
        );
      },
      onError: (error) => emit(ExploreError(error.toString())),
    );
  }

  void loadResources() {
    emit(ExploreLoading());
    _resourcesSubscription?.cancel();
    _resourcesSubscription = getResources().listen(
      (result) {
        result.fold(
          (failure) => emit(ExploreError(failure.message)),
          (resources) => emit(ResourcesLoaded(resources)),
        );
      },
      onError: (error) => emit(ExploreError(error.toString())),
    );
  }

  @override
  Future<void> close() {
    _recommendationsSubscription?.cancel();
    _resourcesSubscription?.cancel();
    return super.close();
  }
}
