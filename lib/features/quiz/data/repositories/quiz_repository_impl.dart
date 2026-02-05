import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/error.dart';
import 'package:guardiancare/features/quiz/data/datasources/quiz_local_datasource.dart';
import 'package:guardiancare/features/quiz/data/models/question_model.dart';
import 'package:guardiancare/features/quiz/data/models/quiz_model.dart'; // Added
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/error/failures.dart'; // Added for ServerFailure

/// Implementation of QuizRepository
class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;
  final IDataStore dataStore;

  QuizRepositoryImpl({
    required this.localDataSource,
    required this.dataStore,
  });

  @override
  Future<Either<Failure, QuizEntity>> getQuiz(String quizId) async {
    try {
      final quiz = await localDataSource.getQuiz(quizId);
      return Right(quiz);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(
          ErrorStrings.withDetails(ErrorStrings.getQuizError, e.toString())));
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
      return Left(CacheFailure(ErrorStrings.withDetails(
          ErrorStrings.getQuestionsError, e.toString())));
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
      final questionModels =
          questions.map((q) => QuestionModel.fromEntity(q)).toList();

      final result = localDataSource.calculateResults(
        quizId: quizId,
        answers: answers,
        questions: questionModels,
      );

      return Right(result);
    } catch (e) {
      return Left(CacheFailure(ErrorStrings.withDetails(
          ErrorStrings.submitQuizError, e.toString())));
    }
  }

  @override
  Either<Failure, bool> validateQuizData(List<QuestionEntity> questions) {
    try {
      final questionModels =
          questions.map((q) => QuestionModel.fromEntity(q)).toList();

      final isValid = localDataSource.validateQuizData(questionModels);
      return Right(isValid);
    } catch (e) {
      return Left(CacheFailure(ErrorStrings.withDetails(
          ErrorStrings.validateQuizError, e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> saveQuizHistory({
    required String uid,
    required String quizName,
    required int score,
    required int totalQuestions,
    required List<String> categories,
  }) async {
    try {
      final quizResultData = {
        'uid': uid,
        'quizName': quizName,
        'score': score,
        'totalQuestions': totalQuestions,
        'categories': categories,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final result = await dataStore.add('quiz_results', quizResultData);

      return result.when(
        success: (_) => const Right(null),
        failure: (e) => Left(ServerFailure(e.message)),
      );
    } catch (e) {
      return Left(ServerFailure(ErrorStrings.withDetails(
          'Failed to save quiz history', e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<QuizEntity>>> getAllQuizzes() async {
    try {
      final quizzesResult = await dataStore.query('quizes');
      if (quizzesResult.isFailure) {
        return Left(ServerFailure(quizzesResult.errorOrNull?.message ??
            'Unknown error loading quizzes'));
      }
      final quizzesData = quizzesResult.dataOrNull!;

      final questionsResult = await dataStore.query('quiz_questions');
      if (questionsResult.isFailure) {
        return Left(ServerFailure(questionsResult.errorOrNull?.message ??
            'Unknown error loading questions'));
      }
      final questionsData = questionsResult.dataOrNull!;

      final List<QuizEntity> quizzes = [];

      for (var qData in quizzesData) {
        if (qData['name'] != null && (qData['use'] == true)) {
          final quizName = qData['name'] as String;

          final relatedQuestionsData = questionsData.where((q) {
            return q['quiz'] == quizName;
          }).toList();

          final questions = relatedQuestionsData
              .map((map) => QuestionModel.fromJson(map))
              .toList();

          quizzes.add(QuizModel(
            id: qData['id'] as String? ?? quizName,
            title: quizName,
            category: qData['category'] as String? ?? 'General',
            questions: questions,
            imageUrl: qData['thumbnail'] as String?,
            description: qData['description'] as String?,
          ));
        }
      }
      return Right(quizzes);
    } catch (e) {
      return Left(ServerFailure(
          ErrorStrings.withDetails('Failed to load quizzes', e.toString())));
    }
  }
}
