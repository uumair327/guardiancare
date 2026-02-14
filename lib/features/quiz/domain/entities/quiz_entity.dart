import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';

/// Quiz entity representing a quiz with questions
class QuizEntity extends Equatable {

  const QuizEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    this.description,
    this.imageUrl,
  });
  final String id;
  final String title;
  final String category;
  final List<QuestionEntity> questions;
  final String? description;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, title, category, questions, description];

  bool get isValid => title.isNotEmpty && questions.isNotEmpty;
}
