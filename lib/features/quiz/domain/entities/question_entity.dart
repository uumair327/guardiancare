import 'package:equatable/equatable.dart';

/// Question entity representing a quiz question
class QuestionEntity extends Equatable {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String? explanation;

  const QuestionEntity({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    this.explanation,
  });

  @override
  List<Object?> get props => [
        question,
        options,
        correctAnswerIndex,
        category,
        explanation,
      ];

  bool get isValid =>
      question.isNotEmpty &&
      options.length >= 2 &&
      correctAnswerIndex >= 0 &&
      correctAnswerIndex < options.length;

  String get correctAnswer => options[correctAnswerIndex];
}
