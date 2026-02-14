import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';

/// Use case for getting learning categories
class GetCategories implements UseCase<List<CategoryEntity>, NoParams> {

  GetCategories(this.repository);
  final LearnRepository repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return repository.getCategories();
  }
}
