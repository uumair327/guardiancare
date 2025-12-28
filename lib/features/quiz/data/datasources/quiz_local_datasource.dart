import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/quiz/data/models/question_model.dart';
import 'package:guardiancare/features/quiz/data/models/quiz_model.dart';
import 'package:guardiancare/features/quiz/data/models/quiz_result_model.dart';

/// Local data source for quiz operations (in-memory for now)
abstract class QuizLocalDataSource {
  /// Get quiz by ID
  Future<QuizModel> getQuiz(String quizId);

  /// Get questions for a quiz
  Future<List<QuestionModel>> getQuestions(String quizId);

  /// Calculate quiz results
  QuizResultModel calculateResults({
    required String quizId,
    required Map<int, String> answers,
    required List<QuestionModel> questions,
  });

  /// Validate quiz data
  bool validateQuizData(List<QuestionModel> questions);
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  @override
  Future<QuizModel> getQuiz(String quizId) async {
    // In a real implementation, this would fetch from local storage
    // For now, return a placeholder
    throw CacheException(ErrorStrings.cacheNotFound);
  }

  @override
  Future<List<QuestionModel>> getQuestions(String quizId) async {
    // In a real implementation, this would fetch from local storage
    throw CacheException(ErrorStrings.cacheNotFound);
  }

  @override
  QuizResultModel calculateResults({
    required String quizId,
    required Map<int, String> answers,
    required List<QuestionModel> questions,
  }) {
    int correctCount = 0;
    final List<String> incorrectCategories = [];

    for (final entry in answers.entries) {
      final questionIndex = entry.key;
      final selectedAnswer = entry.value;

      if (questionIndex < questions.length) {
        final question = questions[questionIndex];
        final correctAnswer = question.correctAnswer;

        if (selectedAnswer == correctAnswer) {
          correctCount++;
        } else {
          if (!incorrectCategories.contains(question.category)) {
            incorrectCategories.add(question.category);
          }
        }
      }
    }

    final totalQuestions = questions.length;
    final incorrectCount = answers.length - correctCount;
    final scorePercentage =
        totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;

    return QuizResultModel(
      totalQuestions: totalQuestions,
      correctAnswers: correctCount,
      incorrectAnswers: incorrectCount,
      scorePercentage: scorePercentage,
      selectedAnswers: answers,
      incorrectCategories: incorrectCategories,
    );
  }

  @override
  bool validateQuizData(List<QuestionModel> questions) {
    if (questions.isEmpty) return false;

    for (final question in questions) {
      if (!question.isValid) {
        return false;
      }
    }

    return true;
  }
}
