import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

/// Use case for validating quiz data
class ValidateQuiz implements UseCase<bool, List<QuestionEntity>> {

  ValidateQuiz(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, bool>> call(List<QuestionEntity> questions) async {
    return Future.value(repository.validateQuizData(questions));
  }
}
