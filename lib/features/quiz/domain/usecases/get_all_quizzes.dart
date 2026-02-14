import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

class GetAllQuizzes implements UseCase<List<QuizEntity>, NoParams> {

  GetAllQuizzes(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, List<QuizEntity>>> call(NoParams params) async {
    return repository.getAllQuizzes();
  }
}
