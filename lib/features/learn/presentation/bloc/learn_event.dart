import 'package:equatable/equatable.dart';

/// Base class for learn events
abstract class LearnEvent extends Equatable {
  const LearnEvent();

  @override
  List<Object> get props => [];
}

/// Event to request categories
class CategoriesRequested extends LearnEvent {}

/// Event when a category is selected
class CategorySelected extends LearnEvent {
  final String categoryName;

  const CategorySelected(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

/// Event to request videos for a category
class VideosRequested extends LearnEvent {
  final String category;

  const VideosRequested(this.category);

  @override
  List<Object> get props => [category];
}

/// Event to go back to categories
class BackToCategories extends LearnEvent {}

/// Event to retry after error
class RetryRequested extends LearnEvent {}
