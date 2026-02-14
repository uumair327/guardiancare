import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

/// Parameters for submitting a quiz
class SubmitQuizParams extends Equatable {

  const SubmitQuizParams({
    required this.quizId,
    required this.answers,
    required this.questions,
  });
  final String quizId;
  final Map<int, String> answers;
  final List<QuestionEntity> questions;

  @override
  List<Object> get props => [quizId, answers, questions];
}

/// Use case for submitting quiz answers
class SubmitQuiz implements UseCase<QuizResultEntity, SubmitQuizParams> {

  SubmitQuiz(this.repository);
  final QuizRepository repository;

  @override
  Future<Either<Failure, QuizResultEntity>> call(
      SubmitQuizParams params) async {
    return repository.submitQuiz(
      quizId: params.quizId,
      answers: params.answers,
      questions: params.questions,
    );
  }
}
