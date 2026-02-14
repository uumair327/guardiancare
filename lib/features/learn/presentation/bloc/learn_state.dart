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
/// Requirements: 3.1 - Categories fetched through LearnBloc/LearnRepository
class CategoriesLoaded extends LearnState {

  const CategoriesLoaded(this.categories);
  final List<CategoryEntity> categories;

  @override
  List<Object> get props => [categories];
}

/// Videos loading state
class VideosLoading extends LearnState {

  const VideosLoading(this.categoryName);
  final String categoryName;

  @override
  List<Object> get props => [categoryName];
}

/// Videos loaded successfully
/// Requirements: 3.2 - Videos fetched through LearnBloc/LearnRepository
class VideosLoaded extends LearnState {

  const VideosLoaded(this.categoryName, this.videos);
  final String categoryName;
  final List<VideoEntity> videos;

  @override
  List<Object> get props => [categoryName, videos];
}

/// Error state
class LearnError extends LearnState {

  const LearnError(this.message, {this.canRetry = true});
  final String message;
  final bool canRetry;

  @override
  List<Object> get props => [message, canRetry];
}
