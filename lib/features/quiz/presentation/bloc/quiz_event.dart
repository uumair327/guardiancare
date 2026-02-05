import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';

/// Base class for quiz events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

/// Event when an answer is selected
class AnswerSelected extends QuizEvent {
  final int questionIndex;
  final String answer;

  const AnswerSelected(this.questionIndex, this.answer);

  @override
  List<Object?> get props => [questionIndex, answer];
}

/// Event when feedback is shown
class FeedbackShown extends QuizEvent {
  final int questionIndex;

  const FeedbackShown(this.questionIndex);

  @override
  List<Object?> get props => [questionIndex];
}

/// Event to navigate to a specific question
class NavigateToQuestion extends QuizEvent {
  final int questionIndex;

  const NavigateToQuestion(this.questionIndex);

  @override
  List<Object?> get props => [questionIndex];
}

/// Event to go to next question
class NextQuestion extends QuizEvent {
  const NextQuestion();
}

/// Event to go to previous question
class PreviousQuestion extends QuizEvent {
  const PreviousQuestion();
}

/// Event when quiz is completed
class QuizCompleted extends QuizEvent {
  const QuizCompleted();
}

/// Event to reset quiz
class QuizReset extends QuizEvent {
  const QuizReset();
}

/// Event to submit quiz for scoring
class QuizSubmitted extends QuizEvent {
  final String quizId;
  final List<QuestionEntity> questions;

  const QuizSubmitted({
    required this.quizId,
    required this.questions,
  });

  @override
  List<Object?> get props => [quizId, questions];
}

/// Event when an answer is submitted for validation
/// Requirements: 2.1
class SubmitAnswerRequested extends QuizEvent {
  final int questionIndex;
  final int selectedOption;
  final int correctAnswerIndex;

  const SubmitAnswerRequested({
    required this.questionIndex,
    required this.selectedOption,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props =>
      [questionIndex, selectedOption, correctAnswerIndex];
}

/// Event when quiz is completed and needs to be processed
/// Requirements: 2.2
class CompleteQuizRequested extends QuizEvent {
  final List<QuestionEntity> questions;
  final int correctAnswers;
  final int totalQuestions;

  const CompleteQuizRequested({
    required this.questions,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [questions, correctAnswers, totalQuestions];
}

/// Event to generate recommendations based on quiz categories
/// Requirements: 2.3
class GenerateRecommendationsRequested extends QuizEvent {
  final List<String> categories;

  const GenerateRecommendationsRequested({required this.categories});

  @override
  List<Object?> get props => [categories];
}
