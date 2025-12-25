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
  // New fields for answer validation
  final QuizAnswerValidationResult? lastAnswerValidation;
  // New fields for quiz completion
  final QuizCompletionResult? completionResult;
  // New fields for recommendations
  final RecommendationsStatus recommendationsStatus;

  const QuizState({
    this.selectedAnswers = const {},
    this.lockedQuestions = const {},
    this.feedbackShown = const {},
    this.currentQuestionIndex = 0,
    this.quizCompleted = false,
    this.isSubmitting = false,
    this.error,
    this.quizResult,
    this.lastAnswerValidation,
    this.completionResult,
    this.recommendationsStatus = RecommendationsStatus.idle,
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
    QuizAnswerValidationResult? lastAnswerValidation,
    QuizCompletionResult? completionResult,
    RecommendationsStatus? recommendationsStatus,
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
      lastAnswerValidation: lastAnswerValidation ?? this.lastAnswerValidation,
      completionResult: completionResult ?? this.completionResult,
      recommendationsStatus: recommendationsStatus ?? this.recommendationsStatus,
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
        lastAnswerValidation,
        completionResult,
        recommendationsStatus,
      ];
}

/// Result of answer validation
/// Requirements: 2.1
class QuizAnswerValidationResult extends Equatable {
  final int questionIndex;
  final bool isCorrect;
  final int correctAnswerIndex;
  final int selectedOption;

  const QuizAnswerValidationResult({
    required this.questionIndex,
    required this.isCorrect,
    required this.correctAnswerIndex,
    required this.selectedOption,
  });

  @override
  List<Object?> get props => [questionIndex, isCorrect, correctAnswerIndex, selectedOption];
}

/// Result of quiz completion
/// Requirements: 2.2
class QuizCompletionResult extends Equatable {
  final int score;
  final int totalQuestions;
  final List<String> categories;
  final DateTime completedAt;

  const QuizCompletionResult({
    required this.score,
    required this.totalQuestions,
    required this.categories,
    required this.completedAt,
  });

  int get percentage => totalQuestions > 0 
      ? (score / totalQuestions * 100).round() 
      : 0;

  @override
  List<Object?> get props => [score, totalQuestions, categories, completedAt];
}

/// Status of recommendations generation
/// Requirements: 2.3
enum RecommendationsStatus {
  /// No recommendation generation in progress
  idle,
  /// Recommendations are being generated
  generating,
  /// Recommendations have been generated successfully
  generated,
  /// Recommendation generation failed
  failed,
}
