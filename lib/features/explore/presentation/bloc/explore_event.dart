import 'package:equatable/equatable.dart';

/// Base class for explore events
abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load recommended videos
class LoadRecommendedVideos extends ExploreEvent {
  final String uid;

  const LoadRecommendedVideos(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Event to load recommended resources
class LoadRecommendedResources extends ExploreEvent {}

/// Event to search resources
class SearchResourcesRequested extends ExploreEvent {
  final String query;

  const SearchResourcesRequested(this.query);

  @override
  List<Object?> get props => [query];
}
