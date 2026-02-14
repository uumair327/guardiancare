import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';

/// Question model extending QuestionEntity with JSON serialization
class QuestionModel extends QuestionEntity {
  const QuestionModel({
    super.quizId,
    required super.question,
    required super.options,
    required super.correctAnswerIndex,
    required super.category,
    super.explanation,
  });

  /// Create QuestionModel from QuestionEntity
  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      quizId: entity.quizId,
      question: entity.question,
      options: entity.options,
      correctAnswerIndex: entity.correctAnswerIndex,
      category: entity.category,
      explanation: entity.explanation,
    );
  }

  /// Create QuestionModel from JSON/Map
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      quizId: json['quiz'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswerIndex:
          (json['correctAnswerIndex'] ?? json['correctOptionIndex']) as int? ??
              0,
      category: json['category'] as String? ?? 'General',
      explanation: json['explanation'] as String?,
    );
  }

  /// Convert QuestionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'quiz': quizId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category,
      'explanation': explanation,
    };
  }
}
