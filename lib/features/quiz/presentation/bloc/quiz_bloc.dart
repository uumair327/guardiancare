import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/usecases/submit_quiz.dart';
import 'package:guardiancare/features/quiz/domain/usecases/validate_quiz.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_state.dart';

/// BLoC for managing quiz state with Clean Architecture
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final SubmitQuiz submitQuiz;
  final ValidateQuiz validateQuiz;

  QuizBloc({
    required this.submitQuiz,
    required this.validateQuiz,
  }) : super(const QuizState()) {
    on<AnswerSelected>(_onAnswerSelected);
    on<FeedbackShown>(_onFeedbackShown);
    on<NavigateToQuestion>(_onNavigateToQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<QuizCompleted>(_onQuizCompleted);
    on<QuizReset>(_onQuizReset);
    on<QuizSubmitted>(_onQuizSubmitted);
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
