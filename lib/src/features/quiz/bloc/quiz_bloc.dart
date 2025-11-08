import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class AnswerSelected extends QuizEvent {
  final int questionIndex;
  final String answer;

  const AnswerSelected(this.questionIndex, this.answer);

  @override
  List<Object?> get props => [questionIndex, answer];
}

class FeedbackShown extends QuizEvent {
  final int questionIndex;

  const FeedbackShown(this.questionIndex);

  @override
  List<Object?> get props => [questionIndex];
}

class NavigateToQuestion extends QuizEvent {
  final int questionIndex;

  const NavigateToQuestion(this.questionIndex);

  @override
  List<Object?> get props => [questionIndex];
}

class NextQuestion extends QuizEvent {
  const NextQuestion();
}

class PreviousQuestion extends QuizEvent {
  const PreviousQuestion();
}

class QuizCompleted extends QuizEvent {
  const QuizCompleted();
}

class QuizReset extends QuizEvent {
  const QuizReset();
}

// State
class QuizState extends Equatable {
  final Map<int, String> selectedAnswers;
  final Map<int, bool> lockedQuestions;
  final Map<int, bool> feedbackShown;
  final int currentQuestionIndex;
  final bool quizCompleted;

  const QuizState({
    this.selectedAnswers = const {},
    this.lockedQuestions = const {},
    this.feedbackShown = const {},
    this.currentQuestionIndex = 0,
    this.quizCompleted = false,
  });

  QuizState copyWith({
    Map<int, String>? selectedAnswers,
    Map<int, bool>? lockedQuestions,
    Map<int, bool>? feedbackShown,
    int? currentQuestionIndex,
    bool? quizCompleted,
  }) {
    return QuizState(
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      lockedQuestions: lockedQuestions ?? this.lockedQuestions,
      feedbackShown: feedbackShown ?? this.feedbackShown,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      quizCompleted: quizCompleted ?? this.quizCompleted,
    );
  }

  @override
  List<Object?> get props => [
        selectedAnswers,
        lockedQuestions,
        feedbackShown,
        currentQuestionIndex,
        quizCompleted,
      ];
}

// BLoC
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(const QuizState()) {
    on<AnswerSelected>(_onAnswerSelected);
    on<FeedbackShown>(_onFeedbackShown);
    on<NavigateToQuestion>(_onNavigateToQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<QuizCompleted>(_onQuizCompleted);
    on<QuizReset>(_onQuizReset);
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

  void _onNavigateToQuestion(NavigateToQuestion event, Emitter<QuizState> emit) {
    emit(state.copyWith(currentQuestionIndex: event.questionIndex));
  }

  void _onNextQuestion(NextQuestion event, Emitter<QuizState> emit) {
    emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1));
  }

  void _onPreviousQuestion(PreviousQuestion event, Emitter<QuizState> emit) {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  void _onQuizCompleted(QuizCompleted event, Emitter<QuizState> emit) {
    emit(state.copyWith(quizCompleted: true));
  }

  void _onQuizReset(QuizReset event, Emitter<QuizState> emit) {
    emit(const QuizState());
  }

  // Helper getters
  String? getSelectedAnswer(int questionIndex) => state.selectedAnswers[questionIndex];
  bool isQuestionLocked(int questionIndex) => state.lockedQuestions[questionIndex] == true;
  bool hasFeedbackBeenShown(int questionIndex) => state.feedbackShown[questionIndex] == true;
  bool hasAnsweredQuestion(int questionIndex) => state.selectedAnswers.containsKey(questionIndex);
  int get totalAnswered => state.selectedAnswers.length;
}
