import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/explore/domain/entities/resource_entity.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

/// Use case for searching resources
class SearchResources implements UseCase<List<ResourceEntity>, String> {
  final ExploreRepository repository;

  SearchResources(this.repository);

  @override
  Future<Either<Failure, List<ResourceEntity>>> call(String query) async {
    return await repository.searchResources(query);
  }
}
