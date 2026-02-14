import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

/// Use case for getting a quiz
class GetQuiz implements UseCase<QuizEntity, String> {

  GetQuiz(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, QuizEntity>> call(String quizId) async {
    return repository.getQuiz(quizId);
  }
}
