import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadCarouselItems extends HomeEvent {
  const LoadCarouselItems();
}

class RefreshCarouselItems extends HomeEvent {
  const RefreshCarouselItems();
}
