import 'package:equatable/equatable.dart';
import '../models/models.dart';

abstract class LearnState extends Equatable {
  const LearnState();

  @override
  List<Object> get props => [];
}

class LearnInitial extends LearnState {}

class LearnLoading extends LearnState {}

class CategoriesLoaded extends LearnState {
  final List<CategoryModel> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class VideosLoading extends LearnState {
  final String categoryName;

  const VideosLoading(this.categoryName);

  @override
  List<Object> get props => [categoryName];
}

class VideosLoaded extends LearnState {
  final String categoryName;
  final List<VideoModel> videos;

  const VideosLoaded(this.categoryName, this.videos);

  @override
  List<Object> get props => [categoryName, videos];
}

class LearnError extends LearnState {
  final String message;
  final bool canRetry;

  const LearnError(this.message, {this.canRetry = true});

  @override
  List<Object> get props => [message, canRetry];
}