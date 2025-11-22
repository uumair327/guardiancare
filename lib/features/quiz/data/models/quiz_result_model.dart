import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';

/// Quiz result model extending QuizResultEntity with JSON serialization
class QuizResultModel extends QuizResultEntity {
  const QuizResultModel({
    required super.totalQuestions,
    required super.correctAnswers,
    required super.incorrectAnswers,
    required super.scorePercentage,
    required super.selectedAnswers,
    required super.incorrectCategories,
  });

  /// Create QuizResultModel from JSON
  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
      scorePercentage: (json['scorePercentage'] as num?)?.toDouble() ?? 0.0,
      selectedAnswers: Map<int, String>.from(json['selectedAnswers'] ?? {}),
      incorrectCategories:
          List<String>.from(json['incorrectCategories'] ?? []),
    );
  }

  /// Convert QuizResultModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'scorePercentage': scorePercentage,
      'selectedAnswers': selectedAnswers,
      'incorrectCategories': incorrectCategories,
    };
  }

  /// Create QuizResultModel from QuizResultEntity
  factory QuizResultModel.fromEntity(QuizResultEntity entity) {
    return QuizResultModel(
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      incorrectAnswers: entity.incorrectAnswers,
      scorePercentage: entity.scorePercentage,
      selectedAnswers: entity.selectedAnswers,
      incorrectCategories: entity.incorrectCategories,
    );
  }
}
