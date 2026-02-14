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

  const RecommendationsLoaded(this.recommendations);
  final List<Recommendation> recommendations;

  @override
  List<Object?> get props => [recommendations];
}

class ResourcesLoaded extends ExploreState {

  const ResourcesLoaded(this.resources);
  final List<Resource> resources;

  @override
  List<Object?> get props => [resources];
}

class ExploreError extends ExploreState {

  const ExploreError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
