import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';

/// Use case for getting learning categories
class GetCategories implements UseCase<List<CategoryEntity>, NoParams> {
  final LearnRepository repository;

  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
