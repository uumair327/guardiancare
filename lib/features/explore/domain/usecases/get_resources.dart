import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/explore/domain/entities/resource.dart';
import 'package:guardiancare/features/explore/domain/repositories/explore_repository.dart';

class GetResources {
  final ExploreRepository repository;

  GetResources(this.repository);

  Stream<Either<Failure, List<Resource>>> call() {
    return repository.getResources();
  }
}
