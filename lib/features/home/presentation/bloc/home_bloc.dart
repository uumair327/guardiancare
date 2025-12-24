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
    on<CarouselItemsReceived>(_onCarouselItemsReceived);
    on<CarouselItemsError>(_onCarouselItemsError);
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
          (failure) => add(CarouselItemsError(failure.message, code: failure.code)),
          (items) => add(CarouselItemsReceived(items)),
        );
      },
      onError: (error) {
        add(CarouselItemsError('Stream error: ${error.toString()}'));
      },
    );
  }

  void _onCarouselItemsReceived(
    CarouselItemsReceived event,
    Emitter<HomeState> emit,
  ) {
    emit(CarouselItemsLoaded(event.items));
  }

  void _onCarouselItemsError(
    CarouselItemsError event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeError(event.message, code: event.code));
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
