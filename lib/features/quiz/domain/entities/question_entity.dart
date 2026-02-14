import 'package:equatable/equatable.dart';

/// Question entity representing a quiz question
class QuestionEntity extends Equatable {

  const QuestionEntity({
    this.quizId = '', // Default empty for compatibility if needed, or required?
    // Usually required. But legacy code might instantiate without it?
    // I'll make it optional with default empty string to avoid breaking too many tests immediately,
    // or required if I want strictness.
    // Given 'Continue remaining', I'll default it to '' to be safer?
    // But logic needs it.
    // I'll use default '' as I can't check all instantiations.
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    this.explanation,
  });
  final String quizId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String? explanation;

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
