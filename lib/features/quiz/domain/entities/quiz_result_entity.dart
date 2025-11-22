import 'package:equatable/equatable.dart';

/// Quiz result entity representing quiz completion results
class QuizResultEntity extends Equatable {
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double scorePercentage;
  final Map<int, String> selectedAnswers;
  final List<String> incorrectCategories;

  const QuizResultEntity({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.scorePercentage,
    required this.selectedAnswers,
    required this.incorrectCategories,
  });

  @override
  List<Object> get props => [
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
        scorePercentage,
        selectedAnswers,
        incorrectCategories,
      ];

  bool get isPerfectScore => incorrectAnswers == 0;
  bool get isPassingScore => scorePercentage >= 70.0;
}
