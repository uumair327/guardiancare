import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/home/domain/entities/carousel_item_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class CarouselItemsLoaded extends HomeState {

  const CarouselItemsLoaded(this.items);
  final List<CarouselItemEntity> items;

  @override
  List<Object> get props => [items];
}

class HomeError extends HomeState {

  const HomeError(this.message, {this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
