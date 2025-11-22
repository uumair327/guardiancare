import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';

void main() {
  group('QuizStateManager Tests', () {
    late QuizStateManager stateManager;

    setUp(() {
      stateManager = QuizStateManager();
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('Answer Selection', () {
      test('should allow selecting answer for unlocked question', () {
        // Act
        final result = stateManager.selectAnswer(0, 'Answer A');

        // Assert
        expect(result, isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Answer A'));
        expect(stateManager.isQuestionAnswered(0), isTrue);
      });

      test('should prevent changing answer after feedback is shown', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.showFeedback(0);

        // Act
        final result = stateManager.selectAnswer(0, 'Answer B');

        // Assert
        expect(result, isFalse);
        expect(stateManager.getSelectedAnswer(0), equals('Answer A'));
        expect(stateManager.isQuestionLocked(0), isTrue);
      });

      test('should allow changing answer before feedback is shown', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');

        // Act
        final result = stateManager.selectAnswer(0, 'Answer B');

        // Assert
        expect(result, isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Answer B'));
      });

      test('should prevent selecting answer for locked question', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.showFeedback(0);

        // Act
        final result = stateManager.selectAnswer(0, 'Answer B');

        // Assert
        expect(result, isFalse);
        expect(stateManager.getSelectedAnswer(0), equals('Answer A'));
      });
    });

    group('Question Locking', () {
      test('should lock question when feedback is shown', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');

        // Act
        stateManager.showFeedback(0);

        // Assert
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.hasFeedbackBeenShown(0), isTrue);
      });

      test('should not lock question before feedback is shown', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');

        // Assert
        expect(stateManager.isQuestionLocked(0), isFalse);
        expect(stateManager.hasFeedbackBeenShown(0), isFalse);
      });

      test('should maintain locked state after multiple feedback calls', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.showFeedback(0);

        // Act
        stateManager.showFeedback(0); // Call again

        // Assert
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.hasFeedbackBeenShown(0), isTrue);
      });
    });

    group('Navigation', () {
      test('should navigate to specific question', () {
        // Act
        stateManager.navigateToQuestion(2);

        // Assert
        expect(stateManager.currentQuestionIndex, equals(2));
      });

      test('should move to next question', () {
        // Arrange
        stateManager.navigateToQuestion(1);

        // Act
        stateManager.nextQuestion();

        // Assert
        expect(stateManager.currentQuestionIndex, equals(2));
      });

      test('should move to previous question', () {
        // Arrange
        stateManager.navigateToQuestion(2);

        // Act
        stateManager.previousQuestion();

        // Assert
        expect(stateManager.currentQuestionIndex, equals(1));
      });

      test('should not go below question 0 when going to previous', () {
        // Arrange
        stateManager.navigateToQuestion(0);

        // Act
        stateManager.previousQuestion();

        // Assert
        expect(stateManager.currentQuestionIndex, equals(0));
      });
    });

    group('Quiz Completion', () {
      test('should mark quiz as completed', () {
        // Act
        stateManager.completeQuiz();

        // Assert
        expect(stateManager.isQuizCompleted, isTrue);
      });

      test('should not be completed initially', () {
        // Assert
        expect(stateManager.isQuizCompleted, isFalse);
      });
    });

    group('Progress Tracking', () {
      test('should calculate progress correctly', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.selectAnswer(1, 'Answer B');

        // Act
        final progress = stateManager.getProgress(4);

        // Assert
        expect(progress, equals(0.5)); // 2 out of 4 questions
      });

      test('should return 0 progress for no questions', () {
        // Act
        final progress = stateManager.getProgress(0);

        // Assert
        expect(progress, equals(0.0));
      });

      test('should count answered questions correctly', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.selectAnswer(2, 'Answer C');

        // Assert
        expect(stateManager.answeredQuestionsCount, equals(2));
      });
    });

    group('State Management', () {
      test('should reset quiz state completely', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.selectAnswer(1, 'Answer B');
        stateManager.showFeedback(0);
        stateManager.navigateToQuestion(2);
        stateManager.completeQuiz();

        // Act
        stateManager.resetQuiz();

        // Assert
        expect(stateManager.selectedAnswers, isEmpty);
        expect(stateManager.lockedQuestions, isEmpty);
        expect(stateManager.currentQuestionIndex, equals(0));
        expect(stateManager.isQuizCompleted, isFalse);
        expect(stateManager.answeredQuestionsCount, equals(0));
      });

      test('should check if current question can be answered', () {
        // Initially should be able to answer
        expect(stateManager.canAnswerCurrentQuestion(), isTrue);

        // After locking, should not be able to answer
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.showFeedback(0);
        expect(stateManager.canAnswerCurrentQuestion(), isFalse);
      });

      test('should provide debug information', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.showFeedback(0);
        stateManager.navigateToQuestion(1);

        // Act
        final debugInfo = stateManager.getDebugInfo();

        // Assert
        expect(debugInfo['currentQuestionIndex'], equals(1));
        expect(debugInfo['selectedAnswers'], containsPair(0, 'Answer A'));
        expect(debugInfo['lockedQuestions'], containsPair(0, true));
        expect(debugInfo['feedbackShown'], containsPair(0, true));
        expect(debugInfo['quizCompleted'], isFalse);
        expect(debugInfo['answeredQuestionsCount'], equals(1));
      });
    });

    group('Question Status Checks', () {
      test('should correctly identify answered questions', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.selectAnswer(2, 'Answer C');

        // Assert
        expect(stateManager.isQuestionAnswered(0), isTrue);
        expect(stateManager.isQuestionAnswered(1), isFalse);
        expect(stateManager.isQuestionAnswered(2), isTrue);
      });

      test('should return null for unanswered questions', () {
        // Assert
        expect(stateManager.getSelectedAnswer(0), isNull);
        expect(stateManager.getSelectedAnswer(5), isNull);
      });

      test('should return false for unlocked questions', () {
        // Assert
        expect(stateManager.isQuestionLocked(0), isFalse);
        expect(stateManager.isQuestionLocked(10), isFalse);
      });

      test('should return false for questions without feedback', () {
        // Assert
        expect(stateManager.hasFeedbackBeenShown(0), isFalse);
        expect(stateManager.hasFeedbackBeenShown(5), isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle empty answer selection', () {
        // Act
        final result = stateManager.selectAnswer(0, '');

        // Assert
        expect(result, isTrue); // Empty answers are allowed
        expect(stateManager.getSelectedAnswer(0), equals(''));
      });

      test('should handle negative question indices gracefully', () {
        // Act & Assert - should not crash
        expect(stateManager.getSelectedAnswer(-1), isNull);
        expect(stateManager.isQuestionLocked(-1), isFalse);
        expect(stateManager.hasFeedbackBeenShown(-1), isFalse);
      });

      test('should handle large question indices gracefully', () {
        // Act & Assert - should not crash
        expect(stateManager.getSelectedAnswer(1000), isNull);
        expect(stateManager.isQuestionLocked(1000), isFalse);
        expect(stateManager.hasFeedbackBeenShown(1000), isFalse);
      });

      test('should maintain state consistency after multiple operations', () {
        // Arrange - Complex sequence of operations
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.selectAnswer(1, 'Answer B');
        stateManager.showFeedback(0);
        stateManager.selectAnswer(0, 'Answer C'); // Should fail
        stateManager.selectAnswer(1, 'Answer D'); // Should succeed
        stateManager.showFeedback(1);
        stateManager.navigateToQuestion(2);
        stateManager.selectAnswer(2, 'Answer E');

        // Assert
        expect(stateManager.getSelectedAnswer(0), equals('Answer A'));
        expect(stateManager.getSelectedAnswer(1), equals('Answer D'));
        expect(stateManager.getSelectedAnswer(2), equals('Answer E'));
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.isQuestionLocked(1), isTrue);
        expect(stateManager.isQuestionLocked(2), isFalse);
        expect(stateManager.currentQuestionIndex, equals(2));
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners when answer is selected', () {
        // Arrange
        bool notified = false;
        stateManager.addListener(() {
          notified = true;
        });

        // Act
        stateManager.selectAnswer(0, 'Answer A');

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners when feedback is shown', () {
        // Arrange
        bool notified = false;
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.addListener(() {
          notified = true;
        });

        // Act
        stateManager.showFeedback(0);

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners when navigating', () {
        // Arrange
        bool notified = false;
        stateManager.addListener(() {
          notified = true;
        });

        // Act
        stateManager.navigateToQuestion(1);

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners when quiz is completed', () {
        // Arrange
        bool notified = false;
        stateManager.addListener(() {
          notified = true;
        });

        // Act
        stateManager.completeQuiz();

        // Assert
        expect(notified, isTrue);
      });

      test('should notify listeners when quiz is reset', () {
        // Arrange
        bool notified = false;
        stateManager.selectAnswer(0, 'Answer A');
        stateManager.addListener(() {
          notified = true;
        });

        // Act
        stateManager.resetQuiz();

        // Assert
        expect(notified, isTrue);
      });
    });
  });
}