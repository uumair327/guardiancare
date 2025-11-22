import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';

void main() {
  group('Quiz Answer Locking Integration Tests', () {
    late QuizStateManager stateManager;

    setUp(() {
      stateManager = QuizStateManager();
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('Answer Locking Mechanism', () {
      test('should prevent answer changes after feedback is shown', () {
        // Arrange - Select initial answer
        expect(stateManager.selectAnswer(0, 'Initial Answer'), isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Initial Answer'));
        expect(stateManager.isQuestionLocked(0), isFalse);

        // Act - Show feedback (this should lock the question)
        stateManager.showFeedback(0);

        // Assert - Question should be locked
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.hasFeedbackBeenShown(0), isTrue);

        // Act - Try to change answer after locking
        final changeResult = stateManager.selectAnswer(0, 'Changed Answer');

        // Assert - Change should be rejected
        expect(changeResult, isFalse);
        expect(stateManager.getSelectedAnswer(0), equals('Initial Answer'));
      });

      test('should allow answer changes before feedback is shown', () {
        // Arrange - Select initial answer
        expect(stateManager.selectAnswer(0, 'Initial Answer'), isTrue);

        // Act - Change answer before feedback
        final changeResult = stateManager.selectAnswer(0, 'Changed Answer');

        // Assert - Change should be allowed
        expect(changeResult, isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Changed Answer'));
        expect(stateManager.isQuestionLocked(0), isFalse);
      });

      test('should lock multiple questions independently', () {
        // Arrange - Answer multiple questions
        stateManager.selectAnswer(0, 'Answer 0');
        stateManager.selectAnswer(1, 'Answer 1');
        stateManager.selectAnswer(2, 'Answer 2');

        // Act - Show feedback for only some questions
        stateManager.showFeedback(0);
        stateManager.showFeedback(2);

        // Assert - Only questions with feedback should be locked
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.isQuestionLocked(1), isFalse);
        expect(stateManager.isQuestionLocked(2), isTrue);

        // Verify answer changes
        expect(stateManager.selectAnswer(0, 'New Answer 0'), isFalse); // Locked
        expect(stateManager.selectAnswer(1, 'New Answer 1'), isTrue);  // Not locked
        expect(stateManager.selectAnswer(2, 'New Answer 2'), isFalse); // Locked

        // Verify final answers
        expect(stateManager.getSelectedAnswer(0), equals('Answer 0'));
        expect(stateManager.getSelectedAnswer(1), equals('New Answer 1'));
        expect(stateManager.getSelectedAnswer(2), equals('Answer 2'));
      });

      test('should maintain lock state during navigation', () {
        // Arrange - Answer and lock first question
        stateManager.selectAnswer(0, 'Answer 0');
        stateManager.showFeedback(0);
        expect(stateManager.isQuestionLocked(0), isTrue);

        // Act - Navigate away and back
        stateManager.navigateToQuestion(1);
        stateManager.selectAnswer(1, 'Answer 1');
        stateManager.navigateToQuestion(0);

        // Assert - First question should still be locked
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Answer 0'));
        expect(stateManager.selectAnswer(0, 'New Answer'), isFalse);
      });
    });

    group('Navigation with Locked Answers', () {
      test('should preserve locked answers when navigating between questions', () {
        // Arrange - Set up multiple questions with some locked
        final questionAnswers = {
          0: 'Answer A',
          1: 'Answer B', 
          2: 'Answer C',
          3: 'Answer D',
        };

        // Answer all questions
        questionAnswers.forEach((questionIndex, answer) {
          stateManager.selectAnswer(questionIndex, answer);
        });

        // Lock some questions by showing feedback
        stateManager.showFeedback(0);
        stateManager.showFeedback(2);

        // Act & Assert - Navigate through all questions
        for (int i = 0; i < 4; i++) {
          stateManager.navigateToQuestion(i);
          
          // Verify answer is preserved
          expect(stateManager.getSelectedAnswer(i), equals(questionAnswers[i]));
          
          // Verify lock state
          final shouldBeLocked = (i == 0 || i == 2);
          expect(stateManager.isQuestionLocked(i), equals(shouldBeLocked));
          
          // Try to change answer
          final changeResult = stateManager.selectAnswer(i, 'Changed Answer');
          expect(changeResult, equals(!shouldBeLocked));
          
          // Verify answer after change attempt
          if (shouldBeLocked) {
            expect(stateManager.getSelectedAnswer(i), equals(questionAnswers[i]));
          } else {
            expect(stateManager.getSelectedAnswer(i), equals('Changed Answer'));
            // Restore original answer for consistency
            stateManager.selectAnswer(i, questionAnswers[i]!);
          }
        }
      });

      test('should handle navigation to questions with no answers', () {
        // Arrange - Answer and lock some questions, leave others empty
        stateManager.selectAnswer(1, 'Answer 1');
        stateManager.showFeedback(1);
        stateManager.selectAnswer(3, 'Answer 3');
        stateManager.showFeedback(3);

        // Act & Assert - Navigate to unanswered questions
        stateManager.navigateToQuestion(0);
        expect(stateManager.getSelectedAnswer(0), isNull);
        expect(stateManager.isQuestionLocked(0), isFalse);
        expect(stateManager.selectAnswer(0, 'New Answer 0'), isTrue);

        stateManager.navigateToQuestion(2);
        expect(stateManager.getSelectedAnswer(2), isNull);
        expect(stateManager.isQuestionLocked(2), isFalse);
        expect(stateManager.selectAnswer(2, 'New Answer 2'), isTrue);

        // Verify locked questions are still locked
        stateManager.navigateToQuestion(1);
        expect(stateManager.isQuestionLocked(1), isTrue);
        expect(stateManager.selectAnswer(1, 'Changed Answer'), isFalse);

        stateManager.navigateToQuestion(3);
        expect(stateManager.isQuestionLocked(3), isTrue);
        expect(stateManager.selectAnswer(3, 'Changed Answer'), isFalse);
      });

      test('should maintain navigation state with locked answers', () {
        // Arrange - Create a complex navigation scenario
        stateManager.selectAnswer(0, 'Answer 0');
        stateManager.navigateToQuestion(1);
        stateManager.selectAnswer(1, 'Answer 1');
        stateManager.showFeedback(1); // Lock question 1
        
        stateManager.navigateToQuestion(2);
        stateManager.selectAnswer(2, 'Answer 2');
        
        stateManager.navigateToQuestion(0);
        stateManager.showFeedback(0); // Lock question 0

        // Act - Navigate through questions in different order
        final navigationOrder = [2, 0, 1, 2, 1, 0];
        
        for (final questionIndex in navigationOrder) {
          stateManager.navigateToQuestion(questionIndex);
          
          // Assert - Current question index is correct
          expect(stateManager.currentQuestionIndex, equals(questionIndex));
          
          // Assert - Answer and lock state are preserved
          expect(stateManager.getSelectedAnswer(questionIndex), isNotNull);
          
          if (questionIndex == 0 || questionIndex == 1) {
            expect(stateManager.isQuestionLocked(questionIndex), isTrue);
          } else {
            expect(stateManager.isQuestionLocked(questionIndex), isFalse);
          }
        }
      });
    });

    group('Score Calculation with First Answers Only', () {
      test('should use only first selected answers for scoring', () {
        // Arrange - Simulate quiz with correct answers at indices [1, 0, 2]
        final correctAnswers = ['B', 'A', 'C'];
        final questionCount = 3;

        // Act - Answer questions, some with changes before feedback
        
        // Question 0: Select wrong answer, change to correct, then lock
        stateManager.selectAnswer(0, 'A'); // Wrong first answer
        stateManager.selectAnswer(0, 'B'); // Correct second answer (before feedback)
        stateManager.showFeedback(0);
        
        // Question 1: Select correct answer, try to change after lock
        stateManager.selectAnswer(1, 'A'); // Correct first answer
        stateManager.showFeedback(1);
        stateManager.selectAnswer(1, 'B'); // Should fail - after feedback
        
        // Question 2: Select correct answer, no changes
        stateManager.selectAnswer(2, 'C'); // Correct first answer
        stateManager.showFeedback(2);

        // Assert - Get final answers for scoring
        final finalAnswers = stateManager.selectedAnswers;
        
        expect(finalAnswers[0], equals('B')); // Changed before feedback - allowed
        expect(finalAnswers[1], equals('A')); // Locked after first selection
        expect(finalAnswers[2], equals('C')); // No changes made

        // Calculate score based on final answers
        int score = 0;
        for (int i = 0; i < questionCount; i++) {
          if (finalAnswers[i] == correctAnswers[i]) {
            score++;
          }
        }
        
        expect(score, equals(3)); // All final answers are correct
      });

      test('should handle scoring with mixed answer changes', () {
        // Arrange - More complex scoring scenario
        final correctAnswers = ['A', 'B', 'C', 'D'];
        
        // Question 0: Correct -> Wrong (before feedback) -> Lock
        stateManager.selectAnswer(0, 'A'); // Correct
        stateManager.selectAnswer(0, 'B'); // Wrong (before feedback)
        stateManager.showFeedback(0);
        
        // Question 1: Wrong -> Correct (before feedback) -> Lock
        stateManager.selectAnswer(1, 'A'); // Wrong
        stateManager.selectAnswer(1, 'B'); // Correct (before feedback)
        stateManager.showFeedback(1);
        
        // Question 2: Wrong -> Lock -> Try to change (should fail)
        stateManager.selectAnswer(2, 'A'); // Wrong
        stateManager.showFeedback(2);
        stateManager.selectAnswer(2, 'C'); // Should fail
        
        // Question 3: Correct -> Lock
        stateManager.selectAnswer(3, 'D'); // Correct
        stateManager.showFeedback(3);

        // Assert - Calculate score
        final finalAnswers = stateManager.selectedAnswers;
        int score = 0;
        
        for (int i = 0; i < correctAnswers.length; i++) {
          if (finalAnswers[i] == correctAnswers[i]) {
            score++;
          }
        }
        
        expect(score, equals(2)); // Questions 1 and 3 are correct
        expect(finalAnswers[0], equals('B')); // Wrong (changed before feedback)
        expect(finalAnswers[1], equals('B')); // Correct (changed before feedback)
        expect(finalAnswers[2], equals('A')); // Wrong (couldn't change after feedback)
        expect(finalAnswers[3], equals('D')); // Correct (no changes)
      });

      test('should handle partial quiz completion for scoring', () {
        // Arrange - User doesn't answer all questions
        stateManager.selectAnswer(0, 'A');
        stateManager.showFeedback(0);
        
        stateManager.selectAnswer(2, 'C');
        stateManager.showFeedback(2);
        
        // Question 1 and 3 are not answered
        
        // Assert - Only answered questions should be in final answers
        final finalAnswers = stateManager.selectedAnswers;
        
        expect(finalAnswers.length, equals(2));
        expect(finalAnswers.containsKey(0), isTrue);
        expect(finalAnswers.containsKey(1), isFalse);
        expect(finalAnswers.containsKey(2), isTrue);
        expect(finalAnswers.containsKey(3), isFalse);
        
        expect(finalAnswers[0], equals('A'));
        expect(finalAnswers[2], equals('C'));
      });
    });

    group('Complex Integration Scenarios', () {
      test('should handle complete quiz flow with navigation and locking', () {
        // Arrange - Simulate a complete quiz session
        final totalQuestions = 5;
        final userAnswers = ['A', 'B', 'C', 'D', 'A'];
        final correctAnswers = ['A', 'C', 'C', 'D', 'B'];

        // Act - Simulate user taking quiz with navigation
        
        // Answer questions in order
        for (int i = 0; i < totalQuestions; i++) {
          stateManager.navigateToQuestion(i);
          stateManager.selectAnswer(i, userAnswers[i]);
          stateManager.showFeedback(i);
        }

        // Navigate back to review (should not be able to change)
        for (int i = totalQuestions - 1; i >= 0; i--) {
          stateManager.navigateToQuestion(i);
          
          // Try to change answer (should fail)
          final changeResult = stateManager.selectAnswer(i, 'Changed');
          expect(changeResult, isFalse);
          
          // Verify original answer is preserved
          expect(stateManager.getSelectedAnswer(i), equals(userAnswers[i]));
          expect(stateManager.isQuestionLocked(i), isTrue);
        }

        // Complete quiz
        stateManager.completeQuiz();

        // Assert - Final state
        expect(stateManager.isQuizCompleted, isTrue);
        expect(stateManager.answeredQuestionsCount, equals(totalQuestions));
        
        // Calculate final score
        final finalAnswers = stateManager.selectedAnswers;
        int score = 0;
        for (int i = 0; i < totalQuestions; i++) {
          if (finalAnswers[i] == correctAnswers[i]) {
            score++;
          }
        }
        expect(score, equals(3)); // Questions 0, 2, and 3 are correct
      });

      test('should handle quiz reset after partial completion', () {
        // Arrange - Partially complete quiz
        stateManager.selectAnswer(0, 'A');
        stateManager.showFeedback(0);
        stateManager.selectAnswer(1, 'B');
        stateManager.showFeedback(1);
        stateManager.selectAnswer(2, 'C'); // Not locked
        stateManager.navigateToQuestion(1);

        // Verify initial state
        expect(stateManager.answeredQuestionsCount, equals(3));
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.isQuestionLocked(1), isTrue);
        expect(stateManager.isQuestionLocked(2), isFalse);

        // Act - Reset quiz
        stateManager.resetQuiz();

        // Assert - All state should be cleared
        expect(stateManager.selectedAnswers, isEmpty);
        expect(stateManager.lockedQuestions, isEmpty);
        expect(stateManager.currentQuestionIndex, equals(0));
        expect(stateManager.isQuizCompleted, isFalse);
        expect(stateManager.answeredQuestionsCount, equals(0));

        // Verify all questions are unlocked and unanswered
        for (int i = 0; i < 5; i++) {
          expect(stateManager.getSelectedAnswer(i), isNull);
          expect(stateManager.isQuestionLocked(i), isFalse);
          expect(stateManager.hasFeedbackBeenShown(i), isFalse);
        }

        // Verify can answer questions again
        expect(stateManager.selectAnswer(0, 'New Answer'), isTrue);
        expect(stateManager.canAnswerCurrentQuestion(), isTrue);
      });

      test('should maintain consistency during rapid state changes', () {
        // Arrange - Rapid sequence of operations
        final operations = [
          () => stateManager.selectAnswer(0, 'A'),
          () => stateManager.navigateToQuestion(1),
          () => stateManager.selectAnswer(1, 'B'),
          () => stateManager.navigateToQuestion(0),
          () => stateManager.selectAnswer(0, 'A2'),
          () => stateManager.showFeedback(0),
          () => stateManager.navigateToQuestion(1),
          () => stateManager.showFeedback(1),
          () => stateManager.selectAnswer(0, 'A3'), // Should fail
          () => stateManager.selectAnswer(1, 'B2'), // Should fail
          () => stateManager.navigateToQuestion(2),
          () => stateManager.selectAnswer(2, 'C'),
        ];

        // Act - Execute all operations rapidly
        for (final operation in operations) {
          operation();
        }

        // Assert - Final state should be consistent
        expect(stateManager.getSelectedAnswer(0), equals('A2')); // Last valid change
        expect(stateManager.getSelectedAnswer(1), equals('B'));  // Original answer
        expect(stateManager.getSelectedAnswer(2), equals('C'));  // New answer
        
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.isQuestionLocked(1), isTrue);
        expect(stateManager.isQuestionLocked(2), isFalse);
        
        expect(stateManager.currentQuestionIndex, equals(2));
        expect(stateManager.answeredQuestionsCount, equals(3));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle feedback shown multiple times', () {
        // Arrange
        stateManager.selectAnswer(0, 'Answer A');
        
        // Act - Show feedback multiple times
        stateManager.showFeedback(0);
        stateManager.showFeedback(0);
        stateManager.showFeedback(0);
        
        // Assert - Should remain locked and consistent
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.hasFeedbackBeenShown(0), isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Answer A'));
      });

      test('should handle navigation to same question multiple times', () {
        // Arrange
        stateManager.selectAnswer(1, 'Answer B');
        stateManager.showFeedback(1);
        
        // Act - Navigate to same question multiple times
        stateManager.navigateToQuestion(1);
        stateManager.navigateToQuestion(1);
        stateManager.navigateToQuestion(1);
        
        // Assert - State should remain consistent
        expect(stateManager.currentQuestionIndex, equals(1));
        expect(stateManager.isQuestionLocked(1), isTrue);
        expect(stateManager.getSelectedAnswer(1), equals('Answer B'));
      });

      test('should handle empty string answers consistently', () {
        // Act
        stateManager.selectAnswer(0, '');
        stateManager.showFeedback(0);
        
        // Assert
        expect(stateManager.getSelectedAnswer(0), equals(''));
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(stateManager.selectAnswer(0, 'New Answer'), isFalse);
      });
    });
  });
}