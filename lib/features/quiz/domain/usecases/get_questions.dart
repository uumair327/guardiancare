import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

/// Use case for getting quiz questions
class GetQuestions implements UseCase<List<QuestionEntity>, String> {
  final QuizRepository repository;

  GetQuestions(this.repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(String quizId) async {
    return await repository.getQuestions(quizId);
  }
}
