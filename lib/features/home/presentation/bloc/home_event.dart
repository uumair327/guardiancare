import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';

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

/// Internal event for when carousel items are received from stream
/// @internal - Do not use directly, used by HomeBloc internally
class CarouselItemsReceived extends HomeEvent {
  final List<CarouselItemEntity> items;

  const CarouselItemsReceived(this.items);

  @override
  List<Object?> get props => [items];
}

/// Internal event for when an error occurs in the stream
/// @internal - Do not use directly, used by HomeBloc internally
class CarouselItemsError extends HomeEvent {
  final String message;
  final String? code;

  const CarouselItemsError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
