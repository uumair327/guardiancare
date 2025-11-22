import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';

/// Quiz state for Clean Architecture
class QuizState extends Equatable {
  final Map<int, String> selectedAnswers;
  final Map<int, bool> lockedQuestions;
  final Map<int, bool> feedbackShown;
  final int currentQuestionIndex;
  final bool quizCompleted;
  final bool isSubmitting;
  final String? error;
  final QuizResultEntity? quizResult;

  const QuizState({
    this.selectedAnswers = const {},
    this.lockedQuestions = const {},
    this.feedbackShown = const {},
    this.currentQuestionIndex = 0,
    this.quizCompleted = false,
    this.isSubmitting = false,
    this.error,
    this.quizResult,
  });

  QuizState copyWith({
    Map<int, String>? selectedAnswers,
    Map<int, bool>? lockedQuestions,
    Map<int, bool>? feedbackShown,
    int? currentQuestionIndex,
    bool? quizCompleted,
    bool? isSubmitting,
    String? error,
    QuizResultEntity? quizResult,
  }) {
    return QuizState(
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      lockedQuestions: lockedQuestions ?? this.lockedQuestions,
      feedbackShown: feedbackShown ?? this.feedbackShown,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      quizCompleted: quizCompleted ?? this.quizCompleted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      quizResult: quizResult ?? this.quizResult,
    );
  }

  @override
  List<Object?> get props => [
        selectedAnswers,
        lockedQuestions,
        feedbackShown,
        currentQuestionIndex,
        quizCompleted,
        isSubmitting,
        error,
        quizResult,
      ];
}
