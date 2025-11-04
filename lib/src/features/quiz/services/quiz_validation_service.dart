import 'quiz_state_manager.dart';

/// Service for validating quiz answers and calculating scores
class QuizValidationService {
  /// Check if a user can select an answer for a specific question
  static bool canSelectAnswer(int questionIndex, QuizStateManager stateManager) {
    return !stateManager.isQuestionLocked(questionIndex);
  }

  /// Calculate the quiz score based on correct answers
  /// Only counts the first selected answer for each question
  static int calculateScore(
    Map<int, String> selectedAnswers,
    Map<int, int> correctAnswers,
    List<Map<String, dynamic>> questions,
  ) {
    int score = 0;
    
    for (final entry in selectedAnswers.entries) {
      final questionIndex = entry.key;
      final selectedAnswer = entry.value;
      final correctAnswerIndex = correctAnswers[questionIndex];
      
      if (correctAnswerIndex != null && questionIndex < questions.length) {
        final question = questions[questionIndex];
        final options = question['options'] as List<String>;
        
        if (correctAnswerIndex < options.length) {
          final correctAnswerText = options[correctAnswerIndex];
          if (selectedAnswer == correctAnswerText) {
            score++;
          }
        }
      }
    }
    
    return score;
  }

  /// Calculate the quiz score as a percentage
  static double calculateScorePercentage(
    Map<int, String> selectedAnswers,
    Map<int, int> correctAnswers,
    List<Map<String, dynamic>> questions,
  ) {
    final totalQuestions = questions.length;
    if (totalQuestions == 0) return 0.0;
    
    final score = calculateScore(selectedAnswers, correctAnswers, questions);
    return (score / totalQuestions) * 100;
  }

  /// Validate that all questions have been answered
  static bool isQuizComplete(
    List<Map<String, dynamic>> questions,
    QuizStateManager stateManager,
  ) {
    for (int i = 0; i < questions.length; i++) {
      if (!stateManager.isQuestionAnswered(i)) {
        return false;
      }
    }
    return true;
  }

  /// Get the number of correct answers
  static int getCorrectAnswersCount(
    Map<int, String> selectedAnswers,
    Map<int, int> correctAnswers,
    List<Map<String, dynamic>> questions,
  ) {
    return calculateScore(selectedAnswers, correctAnswers, questions);
  }

  /// Get the number of incorrect answers
  static int getIncorrectAnswersCount(
    Map<int, String> selectedAnswers,
    Map<int, int> correctAnswers,
    List<Map<String, dynamic>> questions,
  ) {
    final totalAnswered = selectedAnswers.length;
    final correctCount = calculateScore(selectedAnswers, correctAnswers, questions);
    return totalAnswered - correctCount;
  }

  /// Validate answer format and content
  static bool isValidAnswer(String answer) {
    return answer.trim().isNotEmpty;
  }

  /// Get quiz completion status
  static Map<String, dynamic> getQuizStatus(
    List<Map<String, dynamic>> questions,
    QuizStateManager stateManager,
    Map<int, int> correctAnswers,
  ) {
    final selectedAnswers = stateManager.selectedAnswers;
    final totalQuestions = questions.length;
    final answeredQuestions = selectedAnswers.length;
    final isComplete = isQuizComplete(questions, stateManager);
    
    int correctCount = 0;
    int incorrectCount = 0;
    
    if (isComplete) {
      correctCount = getCorrectAnswersCount(selectedAnswers, correctAnswers, questions);
      incorrectCount = getIncorrectAnswersCount(selectedAnswers, correctAnswers, questions);
    }
    
    return {
      'totalQuestions': totalQuestions,
      'answeredQuestions': answeredQuestions,
      'correctAnswers': correctCount,
      'incorrectAnswers': incorrectCount,
      'isComplete': isComplete,
      'progress': answeredQuestions / totalQuestions,
      'score': isComplete ? correctCount : 0,
      'scorePercentage': isComplete ? calculateScorePercentage(selectedAnswers, correctAnswers, questions) : 0.0,
    };
  }

  /// Validate quiz data structure
  static bool isValidQuizData(List<Map<String, dynamic>> questions) {
    if (questions.isEmpty) return false;
    
    for (final question in questions) {
      if (!question.containsKey('question') || 
          !question.containsKey('options') ||
          question['question'] == null ||
          question['options'] == null) {
        return false;
      }
      
      final options = question['options'];
      if (options is! List || options.length < 2) {
        return false;
      }
      
      // Check that all options are valid strings
      for (final option in options) {
        if (option is! String || option.trim().isEmpty) {
          return false;
        }
      }
    }
    
    return true;
  }

  /// Reset validation state
  static void resetValidation() {
    // Any cleanup needed for validation state
    print('QuizValidationService: Validation state reset');
  }
}