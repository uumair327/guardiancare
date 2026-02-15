import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/usecases/generate_recommendations.dart';
import 'package:guardiancare/features/quiz/domain/usecases/save_quiz_history.dart';
import 'package:guardiancare/features/quiz/domain/usecases/submit_quiz.dart';
import 'package:guardiancare/features/quiz/domain/usecases/validate_quiz.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_state.dart';

/// BLoC for managing quiz state with Clean Architecture
///
/// Handles all quiz business logic including:
/// - Answer selection and validation (Requirements: 2.1)
/// - Quiz completion and result persistence (Requirements: 2.2)
/// - Recommendation generation delegation (Requirements: 2.3)
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc({
    required this.submitQuiz,
    required this.validateQuiz,
    required this.generateRecommendations,
    required this.saveQuizHistory,
    required this.authService,
  }) : super(const QuizState()) {
    on<AnswerSelected>(_onAnswerSelected);
    on<FeedbackShown>(_onFeedbackShown);
    on<NavigateToQuestion>(_onNavigateToQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<QuizCompleted>(_onQuizCompleted);
    on<QuizReset>(_onQuizReset);
    on<QuizSubmitted>(_onQuizSubmitted);
    // New event handlers for SRP compliance
    on<SubmitAnswerRequested>(_onSubmitAnswerRequested);
    on<CompleteQuizRequested>(_onCompleteQuizRequested);
    on<GenerateRecommendationsRequested>(_onGenerateRecommendationsRequested);
  }
  final SubmitQuiz submitQuiz;
  final ValidateQuiz validateQuiz;
  final GenerateRecommendations generateRecommendations;
  final SaveQuizHistory saveQuizHistory;
  final IAuthService authService;

  void _onAnswerSelected(AnswerSelected event, Emitter<QuizState> emit) {
    // Cannot change answer if question is locked
    if (state.lockedQuestions[event.questionIndex] == true) {
      return;
    }

    // If no answer selected yet, allow selection
    if (!state.selectedAnswers.containsKey(event.questionIndex)) {
      final newAnswers = Map<int, String>.from(state.selectedAnswers);
      newAnswers[event.questionIndex] = event.answer;
      emit(state.copyWith(selectedAnswers: newAnswers));
      return;
    }

    // If feedback not shown yet, allow changing answer
    if (state.feedbackShown[event.questionIndex] != true) {
      final newAnswers = Map<int, String>.from(state.selectedAnswers);
      newAnswers[event.questionIndex] = event.answer;
      emit(state.copyWith(selectedAnswers: newAnswers));
    }
  }

  void _onFeedbackShown(FeedbackShown event, Emitter<QuizState> emit) {
    final newFeedback = Map<int, bool>.from(state.feedbackShown);
    final newLocked = Map<int, bool>.from(state.lockedQuestions);

    newFeedback[event.questionIndex] = true;
    newLocked[event.questionIndex] = true;

    emit(state.copyWith(
      feedbackShown: newFeedback,
      lockedQuestions: newLocked,
    ));
  }

  void _onNavigateToQuestion(
      NavigateToQuestion event, Emitter<QuizState> emit) {
    emit(state.copyWith(currentQuestionIndex: event.questionIndex));
  }

  void _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) {
    emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
  }

  void _onPreviousQuestion(PreviousQuestion event, Emitter<QuizState> emit) {
    if (state.currentQuestionIndex > 0) {
      emit(
          state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void _onQuizCompleted(QuizCompleted event, Emitter<QuizState> emit) {
    emit(state.copyWith(quizCompleted: true));
  }

  void _onQuizReset(QuizReset event, Emitter<QuizState> emit) {
    emit(const QuizState());
  }

  Future<void> _onQuizSubmitted(
      QuizSubmitted event, Emitter<QuizState> emit) async {
    emit(state.copyWith(isSubmitting: true));

    final result = await submitQuiz(
      SubmitQuizParams(
        quizId: event.quizId,
        answers: state.selectedAnswers,
        questions: event.questions,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        error: failure.message,
      )),
      (quizResult) => emit(state.copyWith(
        isSubmitting: false,
        quizCompleted: true,
        quizResult: quizResult,
      )),
    );
  }

  /// Handles answer submission with validation logic
  /// Requirements: 2.1
  void _onSubmitAnswerRequested(
      SubmitAnswerRequested event, Emitter<QuizState> emit) {
    final isCorrect = event.selectedOption == event.correctAnswerIndex;

    final validationResult = QuizAnswerValidationResult(
      questionIndex: event.questionIndex,
      isCorrect: isCorrect,
      correctAnswerIndex: event.correctAnswerIndex,
      selectedOption: event.selectedOption,
    );

    // Lock the question and show feedback
    final newFeedback = Map<int, bool>.from(state.feedbackShown);
    final newLocked = Map<int, bool>.from(state.lockedQuestions);
    newFeedback[event.questionIndex] = true;
    newLocked[event.questionIndex] = true;

    emit(state.copyWith(
      lastAnswerValidation: validationResult,
      feedbackShown: newFeedback,
      lockedQuestions: newLocked,
    ));
  }

  /// Handles quiz completion with repository coordination
  /// Requirements: 2.2
  Future<void> _onCompleteQuizRequested(
      CompleteQuizRequested event, Emitter<QuizState> emit) async {
    Log.d('🎯 QuizBloc: Quiz completion requested');
    Log.d(
        '   Correct answers: ${event.correctAnswers}/${event.totalQuestions}');

    emit(state.copyWith(isSubmitting: true));

    try {
      // Extract categories from questions
      final categories = _extractCategories(event.questions);
      Log.d('📂 Extracted categories: $categories');

      // Persist quiz results
      final user = authService.currentUser;
      if (user != null) {
        Log.d('💾 Saving quiz results for user: ${user.id}');

        // Logic to get quizName from first question's quizId
        final quizName =
            event.questions.isNotEmpty ? event.questions[0].quizId : 'Unknown';

        await saveQuizHistory(SaveQuizHistoryParams(
          uid: user.id,
          quizName: quizName,
          score: event.correctAnswers,
          totalQuestions: event.totalQuestions,
          categories: categories,
        ));
        Log.d('✅ Quiz results saved');
      } else {
        Log.w('⚠️ No user logged in, skipping quiz result save');
      }

      final completionResult = QuizCompletionResult(
        score: event.correctAnswers,
        totalQuestions: event.totalQuestions,
        categories: categories,
        completedAt: DateTime.now(),
      );

      emit(state.copyWith(
        isSubmitting: false,
        quizCompleted: true,
        completionResult: completionResult,
      ));

      // Trigger recommendation generation
      Log.d('🚀 Triggering recommendation generation...');
      add(GenerateRecommendationsRequested(categories: categories));
    } on Object catch (e) {
      Log.e('❌ Error completing quiz: $e');
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Failed to complete quiz: ${e.toString()}',
      ));
    }
  }

  /// Handles recommendation generation delegation
  /// Requirements: 2.3
  Future<void> _onGenerateRecommendationsRequested(
      GenerateRecommendationsRequested event, Emitter<QuizState> emit) async {
    Log.d('🎯 QuizBloc: Starting recommendation generation');
    Log.d('   Categories: ${event.categories}');

    emit(state.copyWith(
        recommendationsStatus: RecommendationsStatus.generating));

    final result = await generateRecommendations(
      GenerateRecommendationsParams(categories: event.categories),
    );

    result.fold(
      (failure) {
        Log.e(
            '❌ QuizBloc: Recommendation generation failed: ${failure.message}');
        emit(state.copyWith(
          recommendationsStatus: RecommendationsStatus.failed,
          error: failure.message,
        ));
      },
      (_) {
        Log.d('✅ QuizBloc: Recommendations generated successfully');
        emit(state.copyWith(
          recommendationsStatus: RecommendationsStatus.generated,
        ));
      },
    );
  }

  /// Extracts categories from quiz questions
  List<String> _extractCategories(List<QuestionEntity> questions) {
    final categories = <String>{};

    for (final question in questions) {
      if (question.category.isNotEmpty) {
        categories.add(question.category);
      }
    }

    // Fallback to quiz name if no categories found
    if (categories.isEmpty && questions.isNotEmpty) {
      final quizName = questions[0].quizId;
      if (quizName.isNotEmpty) {
        categories.add(quizName);
      }
    }

    // Default categories if still empty
    if (categories.isEmpty) {
      categories.addAll(['child safety', 'parenting tips']);
    }

    return categories.toList();
  }

  // Helper getters
  String? getSelectedAnswer(int questionIndex) =>
      state.selectedAnswers[questionIndex];
  bool isQuestionLocked(int questionIndex) =>
      state.lockedQuestions[questionIndex] == true;
  bool hasFeedbackBeenShown(int questionIndex) =>
      state.feedbackShown[questionIndex] == true;
  bool hasAnsweredQuestion(int questionIndex) =>
      state.selectedAnswers.containsKey(questionIndex);
  int get totalAnswered => state.selectedAnswers.length;
}
