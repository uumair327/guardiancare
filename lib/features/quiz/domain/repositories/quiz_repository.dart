import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';

/// Quiz repository interface defining quiz operations
abstract class QuizRepository {
  /// Get quiz by ID
  Future<Either<Failure, QuizEntity>> getQuiz(String quizId);

  /// Get questions for a quiz
  Future<Either<Failure, List<QuestionEntity>>> getQuestions(String quizId);

  /// Submit quiz answers and get results
  Future<Either<Failure, QuizResultEntity>> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required List<QuestionEntity> questions,
  });

  /// Validate quiz data
  Either<Failure, bool> validateQuizData(List<QuestionEntity> questions);
}
