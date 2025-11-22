import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/explore/domain/entities/resource_entity.dart';
import 'package:guardiancare/features/explore/domain/entities/video_entity.dart';

/// Base class for explore states
abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExploreInitial extends ExploreState {}

/// Loading state
class ExploreLoading extends ExploreState {}

/// Searching state
class ExploreSearching extends ExploreState {}

/// Recommended videos loaded
class RecommendedVideosLoaded extends ExploreState {
  final List<VideoEntity> videos;

  const RecommendedVideosLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

/// Recommended resources loaded
class RecommendedResourcesLoaded extends ExploreState {
  final List<ResourceEntity> resources;

  const RecommendedResourcesLoaded(this.resources);

  @override
  List<Object?> get props => [resources];
}

/// Search results loaded
class SearchResultsLoaded extends ExploreState {
  final List<ResourceEntity> resources;
  final String query;

  const SearchResultsLoaded(this.resources, this.query);

  @override
  List<Object?> get props => [resources, query];
}

/// Error state
class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}
