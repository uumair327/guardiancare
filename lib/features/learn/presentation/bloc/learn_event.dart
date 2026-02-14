import 'package:equatable/equatable.dart';

/// Base class for learn events
abstract class LearnEvent extends Equatable {
  const LearnEvent();

  @override
  List<Object> get props => [];
}

/// Event to request categories
/// Alias: LoadCategories (for SRP compliance)
class CategoriesRequested extends LearnEvent {}

/// Alias for CategoriesRequested - used for SRP compliance
/// Requirements: 3.1
typedef LoadCategories = CategoriesRequested;

/// Event when a category is selected
class CategorySelected extends LearnEvent {

  const CategorySelected(this.categoryName);
  final String categoryName;

  @override
  List<Object> get props => [categoryName];
}

/// Event to request videos for a category
/// Alias: LoadVideosByCategory (for SRP compliance)
class VideosRequested extends LearnEvent {

  const VideosRequested(this.category);
  final String category;

  @override
  List<Object> get props => [category];
}

/// Alias for VideosRequested - used for SRP compliance
/// Requirements: 3.2
typedef LoadVideosByCategory = VideosRequested;

/// Event to go back to categories
class BackToCategories extends LearnEvent {}

/// Event to retry after error
class RetryRequested extends LearnEvent {}
