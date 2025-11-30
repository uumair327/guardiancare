import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/explore/domain/entities/recommendation.dart';
import 'package:guardiancare/features/explore/domain/entities/resource.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class RecommendationsLoaded extends ExploreState {
  final List<Recommendation> recommendations;

  const RecommendationsLoaded(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class ResourcesLoaded extends ExploreState {
  final List<Resource> resources;

  const ResourcesLoaded(this.resources);

  @override
  List<Object?> get props => [resources];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}
