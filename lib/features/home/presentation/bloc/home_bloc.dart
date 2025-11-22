import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/home/domain/usecases/get_carousel_items.dart';
import 'package:guardiancare/features/home/presentation/bloc/home_event.dart';
import 'package:guardiancare/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCarouselItems getCarouselItems;

  StreamSubscription? _carouselSubscription;

  HomeBloc({
    required this.getCarouselItems,
  }) : super(const HomeInitial()) {
    on<LoadCarouselItems>(_onLoadCarouselItems);
    on<RefreshCarouselItems>(_onRefreshCarouselItems);
  }

  Future<void> _onLoadCarouselItems(
    LoadCarouselItems event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    await _carouselSubscription?.cancel();

    _carouselSubscription = getCarouselItems(NoParams()).listen(
      (result) {
        result.fold(
          (failure) => emit(HomeError(failure.message, code: failure.code)),
          (items) => emit(CarouselItemsLoaded(items)),
        );
      },
      onError: (error) {
        emit(HomeError('Stream error: ${error.toString()}'));
      },
    );
  }

  Future<void> _onRefreshCarouselItems(
    RefreshCarouselItems event,
    Emitter<HomeState> emit,
  ) async {
    // Just reload - the stream will handle the update
    add(const LoadCarouselItems());
  }

  @override
  Future<void> close() {
    _carouselSubscription?.cancel();
    return super.close();
  }
}
