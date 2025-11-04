import 'package:equatable/equatable.dart';

abstract class LearnEvent extends Equatable {
  const LearnEvent();

  @override
  List<Object> get props => [];
}

class CategoriesRequested extends LearnEvent {}

class CategorySelected extends LearnEvent {
  final String categoryName;

  const CategorySelected(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

class VideosRequested extends LearnEvent {
  final String category;

  const VideosRequested(this.category);

  @override
  List<Object> get props => [category];
}

class BackToCategories extends LearnEvent {}

class RetryRequested extends LearnEvent {}