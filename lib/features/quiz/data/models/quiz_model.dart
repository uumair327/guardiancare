import 'package:guardiancare/features/quiz/data/models/question_model.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';

/// Quiz model extending QuizEntity with JSON serialization
class QuizModel extends QuizEntity {
  const QuizModel({
    required super.id,
    required super.title,
    required super.category,
    required super.questions,
    super.description,
    super.imageUrl,
  });

  /// Create QuizModel from QuizEntity
  factory QuizModel.fromEntity(QuizEntity entity) {
    return QuizModel(
      id: entity.id,
      title: entity.title,
      category: entity.category,
      questions: entity.questions,
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }

  /// Create QuizModel from JSON/Map
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String? ?? '',
      title:
          (json['title'] ?? json['name']) as String? ?? '', // Flexible mapping
      category: json['category'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
      imageUrl: (json['thumbnail'] ?? json['imageUrl']) as String?,
    );
  }

  /// Convert QuizModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'questions':
          questions.map((q) => QuestionModel.fromEntity(q).toJson()).toList(),
      'description': description,
      'thumbnail': imageUrl,
    };
  }
}
