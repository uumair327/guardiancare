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
  final List<CarouselItemEntity> items;

  const CarouselItemsLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class HomeError extends HomeState {
  final String message;
  final String? code;

  const HomeError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
