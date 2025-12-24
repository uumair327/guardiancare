import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';

/// Base class for learn states
abstract class LearnState extends Equatable {
  const LearnState();

  @override
  List<Object> get props => [];
}

/// Initial state
class LearnInitial extends LearnState {}

/// Loading state
class LearnLoading extends LearnState {}

/// Categories loaded successfully
class CategoriesLoaded extends LearnState {
  final List<CategoryEntity> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

/// Videos loading state
class VideosLoading extends LearnState {
  final String categoryName;

  const VideosLoading(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

/// Videos loaded successfully
class VideosLoaded extends LearnState {
  final String categoryName;
  final List<VideoEntity> videos;

  const VideosLoaded(this.categoryName, this.videos);

  @override
  List<Object> get props => [categoryName, videos];
}

/// Error state
class LearnError extends LearnState {
  final String message;
  final bool canRetry;

  const LearnError(this.message, {this.canRetry = true});

  @override
  List<Object> get props => [message, canRetry];
}
