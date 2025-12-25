import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/quiz/domain/usecases/generate_recommendations.dart';
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
  final SubmitQuiz submitQuiz;
  final ValidateQuiz validateQuiz;
  final GenerateRecommendations generateRecommendations;

  QuizBloc({
    required this.submitQuiz,
    required this.validateQuiz,
    required this.generateRecommendations,
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
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex - 1));
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
    emit(state.copyWith(isSubmitting: true));

    try {
      // Extract categories from questions
      final categories = _extractCategories(event.questions);

      // Persist quiz results to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final quizResultData = {
          'uid': user.uid,
          'quizName': event.questions.isNotEmpty 
              ? event.questions[0]['quiz'] ?? 'Unknown'
              : 'Unknown',
          'score': event.correctAnswers,
          'totalQuestions': event.totalQuestions,
          'categories': categories,
          'timestamp': FieldValue.serverTimestamp(),
        };
        
        await FirebaseFirestore.instance
            .collection('quiz_results')
            .add(quizResultData);
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
      add(GenerateRecommendationsRequested(categories: categories));
    } catch (e) {
      debugPrint('Error completing quiz: $e');
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
    emit(state.copyWith(recommendationsStatus: RecommendationsStatus.generating));

    final result = await generateRecommendations(
      GenerateRecommendationsParams(categories: event.categories),
    );

    result.fold(
      (failure) {
        debugPrint('Recommendation generation failed: ${failure.message}');
        emit(state.copyWith(
          recommendationsStatus: RecommendationsStatus.failed,
          error: failure.message,
        ));
      },
      (_) {
        emit(state.copyWith(
          recommendationsStatus: RecommendationsStatus.generated,
        ));
      },
    );
  }

  /// Extracts categories from quiz questions
  List<String> _extractCategories(List<Map<String, dynamic>> questions) {
    final categories = <String>{};
    
    for (final question in questions) {
      final category = question['category'];
      if (category != null && category.toString().isNotEmpty) {
        categories.add(category.toString());
      }
    }

    // Fallback to quiz name if no categories found
    if (categories.isEmpty && questions.isNotEmpty) {
      final quizName = questions[0]['quiz'];
      if (quizName != null && quizName.toString().isNotEmpty) {
        categories.add(quizName.toString());
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
