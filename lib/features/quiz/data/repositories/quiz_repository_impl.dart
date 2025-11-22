import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/data/datasources/quiz_local_datasource.dart';
import 'package:guardiancare/features/quiz/data/models/question_model.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';

/// Implementation of QuizRepository
class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;

  QuizRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, QuizEntity>> getQuiz(String quizId) async {
    try {
      final quiz = await localDataSource.getQuiz(quizId);
      return Right(quiz);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get quiz: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestions(
      String quizId) async {
    try {
      final questions = await localDataSource.getQuestions(quizId);
      return Right(questions);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get questions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizResultEntity>> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required List<QuestionEntity> questions,
  }) async {
    try {
      // Convert entities to models for calculation
      final questionModels = questions
          .map((q) => QuestionModel.fromEntity(q))
          .toList();

      final result = localDataSource.calculateResults(
        quizId: quizId,
        answers: answers,
        questions: questionModels,
      );

      return Right(result);
    } catch (e) {
      return Left(CacheFailure('Failed to submit quiz: ${e.toString()}'));
    }
  }

  @override
  Either<Failure, bool> validateQuizData(List<QuestionEntity> questions) {
    try {
      final questionModels = questions
          .map((q) => QuestionModel.fromEntity(q))
          .toList();

      final isValid = localDataSource.validateQuizData(questionModels);
      return Right(isValid);
    } catch (e) {
      return Left(CacheFailure('Failed to validate quiz: ${e.toString()}'));
    }
  }
}
