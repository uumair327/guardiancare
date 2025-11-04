import 'package:flutter/foundation.dart';

/// Manages quiz state including answer locking and question progression
class QuizStateManager extends ChangeNotifier {
  final Map<int, String> _selectedAnswers = {};
  final Map<int, bool> _lockedQuestions = {};
  final Map<int, bool> _feedbackShown = {};
  int _currentQuestionIndex = 0;
  bool _quizCompleted = false;

  /// Get the currently selected answer for a question
  String? getSelectedAnswer(int questionIndex) {
    return _selectedAnswers[questionIndex];
  }

  /// Check if a question's answer is locked (cannot be changed)
  bool isQuestionLocked(int questionIndex) {
    return _lockedQuestions[questionIndex] ?? false;
  }

  /// Check if feedback has been shown for a question
  bool hasFeedbackBeenShown(int questionIndex) {
    return _feedbackShown[questionIndex] ?? false;
  }

  /// Get the current question index
  int get currentQuestionIndex => _currentQuestionIndex;

  /// Check if the quiz is completed
  bool get isQuizCompleted => _quizCompleted;

  /// Get all selected answers (only first selections count for scoring)
  Map<int, String> get selectedAnswers => Map.unmodifiable(_selectedAnswers);

  /// Get all locked questions
  Map<int, bool> get lockedQuestions => Map.unmodifiable(_lockedQuestions);

  /// Select an answer for a question (only if not locked)
  bool selectAnswer(int questionIndex, String answer) {
    // Cannot change answer if question is locked
    if (isQuestionLocked(questionIndex)) {
      print('QuizStateManager: Cannot change answer for locked question $questionIndex');
      return false;
    }

    // If this is the first time selecting an answer for this question
    if (!_selectedAnswers.containsKey(questionIndex)) {
      _selectedAnswers[questionIndex] = answer;
      print('QuizStateManager: Selected answer "$answer" for question $questionIndex');
      notifyListeners();
      return true;
    }

    // If answer already exists and feedback hasn't been shown, allow change
    if (!hasFeedbackBeenShown(questionIndex)) {
      _selectedAnswers[questionIndex] = answer;
      print('QuizStateManager: Changed answer to "$answer" for question $questionIndex (before feedback)');
      notifyListeners();
      return true;
    }

    print('QuizStateManager: Cannot change answer for question $questionIndex - feedback already shown');
    return false;
  }

  /// Show feedback for a question and lock it
  void showFeedback(int questionIndex) {
    if (!_feedbackShown.containsKey(questionIndex)) {
      _feedbackShown[questionIndex] = true;
      _lockedQuestions[questionIndex] = true;
      print('QuizStateManager: Feedback shown and question $questionIndex locked');
      notifyListeners();
    }
  }

  /// Navigate to a specific question
  void navigateToQuestion(int questionIndex) {
    _currentQuestionIndex = questionIndex;
    print('QuizStateManager: Navigated to question $questionIndex');
    notifyListeners();
  }

  /// Move to the next question
  void nextQuestion() {
    _currentQuestionIndex++;
    print('QuizStateManager: Moved to next question $_currentQuestionIndex');
    notifyListeners();
  }

  /// Move to the previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      print('QuizStateManager: Moved to previous question $_currentQuestionIndex');
      notifyListeners();
    }
  }

  /// Complete the quiz
  void completeQuiz() {
    _quizCompleted = true;
    print('QuizStateManager: Quiz completed with ${_selectedAnswers.length} answers');
    notifyListeners();
  }

  /// Reset the quiz state
  void resetQuiz() {
    _selectedAnswers.clear();
    _lockedQuestions.clear();
    _feedbackShown.clear();
    _currentQuestionIndex = 0;
    _quizCompleted = false;
    print('QuizStateManager: Quiz state reset');
    notifyListeners();
  }

  /// Get the number of answered questions
  int get answeredQuestionsCount => _selectedAnswers.length;

  /// Check if a specific question has been answered
  bool isQuestionAnswered(int questionIndex) {
    return _selectedAnswers.containsKey(questionIndex);
  }

  /// Get quiz progress as a percentage
  double getProgress(int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    return answeredQuestionsCount / totalQuestions;
  }

  /// Check if the current question can be answered
  bool canAnswerCurrentQuestion() {
    return !isQuestionLocked(_currentQuestionIndex);
  }

  /// Get debug information about the quiz state
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentQuestionIndex': _currentQuestionIndex,
      'selectedAnswers': _selectedAnswers,
      'lockedQuestions': _lockedQuestions,
      'feedbackShown': _feedbackShown,
      'quizCompleted': _quizCompleted,
      'answeredQuestionsCount': answeredQuestionsCount,
    };
  }

  @override
  void dispose() {
    print('QuizStateManager: Disposing quiz state manager');
    super.dispose();
  }
}