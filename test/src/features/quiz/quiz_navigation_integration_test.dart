import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_validation_service.dart';

void main() {
  group('Quiz Navigation Integration Tests', () {
    late QuizStateManager stateManager;
    late List<Map<String, dynamic>> sampleQuestions;

    setUp(() {
      stateManager = QuizStateManager();
      sampleQuestions = [
        {
          'question': 'What is 2+2?',
          'options': ['3', '4', '5', '6'],
          'correctAnswerIndex': 1,
          'category': 'math'
        },
        {
          'question': 'What is the capital of France?',
          'options': ['London', 'Berlin', 'Paris', 'Madrid'],
          'correctAnswerIndex': 2,
          'category': 'geography'
        },
        {
          'question': 'What is 3*3?',
          'options': ['6', '9', '12', '15'],
          'correctAnswerIndex': 1,
          'category': 'math'
        },
        {
          'question': 'What is the largest planet?',
          'options': ['Earth', 'Jupiter', 'Saturn', 'Mars'],
          'correctAnswerIndex': 1,
          'category': 'science'
        },
      ];
      stateManager.initializeQuiz(sampleQuestions.length);
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('Sequential Quiz Flow', () {
      test('should prevent navigation without answering current question', () {
        // Initially at question 0, not answered
        expect(QuizValidationService.canNavigateNext(0, stateManager), isFalse);
        
        // Cannot complete quiz
        expect(QuizValidationService.canCompleteQuiz(stateManager), isFalse);
      });

      test('should allow navigation after answering current question', () {
        // Answer question 0
        stateManager.lockAnswer(0, 1, true);
        expect(QuizValidationService.canNavigateNext(0, stateManager), isTrue);
        
        // Still cannot complete quiz (not all questions answered)
        expect(QuizValidationService.canCompleteQuiz(stateManager), isFalse);
      });

      test('should maintain locked answers during navigation', () {
        // Answer questions in sequence
        stateManager.lockAnswer(0, 1, true);   // Correct answer
        stateManager.lockAnswer(1, 0, false);  // Incorrect answer
        stateManager.lockAnswer(2, 1, true);   // Correct answer
        
        // Verify answers are locked
        expect(stateManager.isAnswerLocked(0), isTrue);
        expect(stateManager.isAnswerLocked(1), isTrue);
        expect(stateManager.isAnswerLocked(2), isTrue);
        expect(stateManager.isAnswerLocked(3), isFalse);
        
        // Verify specific answers
        expect(stateManager.getLockedAnswer(0), equals(1));
        expect(stateManager.getLockedAnswer(1), equals(0));
        expect(stateManager.getLockedAnswer(2), equals(1));
        expect(stateManager.getLockedAnswer(3), isNull);
        
        // Verify correctness
        expect(stateManager.isAnswerCorrect(0), isTrue);
        expect(stateManager.isAnswerCorrect(1), isFalse);
        expect(stateManager.isAnswerCorrect(2), isTrue);
        expect(stateManager.isAnswerCorrect(3), isNull);
      });

      test('should prevent answer changes after locking', () {
        // Lock answer for question 0
        stateManager.lockAnswer(0, 1, true);
        expect(stateManager.getLockedAnswer(0), equals(1));
        expect(stateManager.isAnswerCorrect(0), isTrue);
        
        // Try to change the answer
        stateManager.lockAnswer(0, 3, false);
        
        // Answer should remain unchanged
        expect(stateManager.getLockedAnswer(0), equals(1));
        expect(stateManager.isAnswerCorrect(0), isTrue);
        
        // Validation should prevent selection
        expect(QuizValidationService.canSelectAnswer(0, stateManager), isFalse);
      });
    });

    group('Non-Sequential Navigation', () {
      test('should allow navigation to any question', () {
        // Should be able to navigate to any valid question index
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(stateManager.canNavigateToQuestion(i), isTrue);
        }
        
        // Should not be able to navigate to invalid indices
        expect(stateManager.canNavigateToQuestion(-1), isFalse);
        expect(stateManager.canNavigateToQuestion(sampleQuestions.length), isFalse);
      });

      test('should preserve locked answers when jumping between questions', () {
        // Answer questions out of order
        stateManager.lockAnswer(2, 1, true);   // Answer question 3 first
        stateManager.lockAnswer(0, 1, true);   // Answer question 1
        stateManager.lockAnswer(3, 0, false);  // Answer question 4
        
        // All answers should be preserved
        expect(stateManager.getLockedAnswer(0), equals(1));
        expect(stateManager.getLockedAnswer(1), isNull);
        expect(stateManager.getLockedAnswer(2), equals(1));
        expect(stateManager.getLockedAnswer(3), equals(0));
        
        // Correctness should be preserved
        expect(stateManager.isAnswerCorrect(0), isTrue);
        expect(stateManager.isAnswerCorrect(1), isNull);
        expect(stateManager.isAnswerCorrect(2), isTrue);
        expect(stateManager.isAnswerCorrect(3), isFalse);
        
        // Progress should be correct
        expect(stateManager.getAnsweredQuestionsCount(), equals(3));
        expect(stateManager.getCorrectAnswersCount(), equals(2));
      });

      test('should prevent answer selection on previously answered questions', () {
        // Answer some questions
        stateManager.lockAnswer(1, 2, true);
        stateManager.lockAnswer(3, 1, true);
        
        // Should not be able to select answers on answered questions
        expect(QuizValidationService.canSelectAnswer(1, stateManager), isFalse);
        expect(QuizValidationService.canSelectAnswer(3, stateManager), isFalse);
        
        // Should still be able to select answers on unanswered questions
        expect(QuizValidationService.canSelectAnswer(0, stateManager), isTrue);
        expect(QuizValidationService.canSelectAnswer(2, stateManager), isTrue);
      });
    });

    group('Quiz Completion Flow', () {
      test('should require all questions to be answered before completion', () {
        // Answer some but not all questions
        stateManager.lockAnswer(0, 1, true);
        stateManager.lockAnswer(2, 1, true);
        
        expect(QuizValidationService.canCompleteQuiz(stateManager), isFalse);
        expect(stateManager.areAllQuestionsAnswered(), isFalse);
        
        // Answer remaining questions
        stateManager.lockAnswer(1, 2, true);
        stateManager.lockAnswer(3, 1, true);
        
        expect(QuizValidationService.canCompleteQuiz(stateManager), isTrue);
        expect(stateManager.areAllQuestionsAnswered(), isTrue);
      });

      test('should calculate final score correctly after completion', () {
        // Answer all questions with mixed results
        stateManager.lockAnswer(0, 1, true);   // Correct (math)
        stateManager.lockAnswer(1, 0, false);  // Incorrect (geography)
        stateManager.lockAnswer(2, 1, true);   // Correct (math)
        stateManager.lockAnswer(3, 0, false);  // Incorrect (science)
        
        stateManager.completeQuiz();
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          sampleQuestions
        );
        
        expect(result.totalQuestions, equals(4));
        expect(result.correctAnswers, equals(2));
        expect(result.incorrectAnswers, equals(2));
        expect(result.percentage, equals(50.0));
        expect(result.isPerfectScore, isFalse);
        expect(result.incorrectCategories, containsAll(['geography', 'science']));
        expect(result.incorrectCategories.length, equals(2));
      });

      test('should handle perfect score completion', () {
        // Answer all questions correctly
        stateManager.lockAnswer(0, 1, true);
        stateManager.lockAnswer(1, 2, true);
        stateManager.lockAnswer(2, 1, true);
        stateManager.lockAnswer(3, 1, true);
        
        stateManager.completeQuiz();
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          sampleQuestions
        );
        
        expect(result.totalQuestions, equals(4));
        expect(result.correctAnswers, equals(4));
        expect(result.incorrectAnswers, equals(0));
        expect(result.percentage, equals(100.0));
        expect(result.isPerfectScore, isTrue);
        expect(result.incorrectCategories, isEmpty);
      });
    });

    group('Progress Tracking During Navigation', () {
      test('should update progress correctly as questions are answered', () {
        expect(stateManager.getProgress(), equals(0.0));
        
        stateManager.lockAnswer(0, 1, true);
        expect(stateManager.getProgress(), equals(0.25));
        
        stateManager.lockAnswer(2, 1, true); // Skip question 1
        expect(stateManager.getProgress(), equals(0.5));
        
        stateManager.lockAnswer(1, 2, true); // Go back to question 1
        expect(stateManager.getProgress(), equals(0.75));
        
        stateManager.lockAnswer(3, 1, true);
        expect(stateManager.getProgress(), equals(1.0));
      });

      test('should track correct answers regardless of answer order', () {
        // Answer questions out of order
        stateManager.lockAnswer(3, 1, true);   // Correct
        stateManager.lockAnswer(1, 0, false);  // Incorrect
        stateManager.lockAnswer(0, 1, true);   // Correct
        stateManager.lockAnswer(2, 0, false);  // Incorrect
        
        expect(stateManager.getCorrectAnswersCount(), equals(2));
        expect(stateManager.getAnsweredQuestionsCount(), equals(4));
        
        final incorrectAnswers = stateManager.getIncorrectAnswers();
        expect(incorrectAnswers, containsAll([1, 2]));
        expect(incorrectAnswers.length, equals(2));
      });
    });

    group('State Consistency During Navigation', () {
      test('should maintain consistent state across multiple navigation operations', () {
        // Simulate complex navigation pattern
        stateManager.lockAnswer(0, 1, true);   // Answer Q1
        stateManager.lockAnswer(2, 1, true);   // Jump to Q3, answer
        stateManager.lockAnswer(1, 0, false);  // Go back to Q2, answer incorrectly
        
        // Try to change previous answers (should fail)
        stateManager.lockAnswer(0, 3, false);  // Try to change Q1
        stateManager.lockAnswer(2, 0, false);  // Try to change Q3
        
        // Verify original answers are preserved
        expect(stateManager.getLockedAnswer(0), equals(1));
        expect(stateManager.getLockedAnswer(1), equals(0));
        expect(stateManager.getLockedAnswer(2), equals(1));
        
        expect(stateManager.isAnswerCorrect(0), isTrue);
        expect(stateManager.isAnswerCorrect(1), isFalse);
        expect(stateManager.isAnswerCorrect(2), isTrue);
        
        // Complete the quiz
        stateManager.lockAnswer(3, 1, true);
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          sampleQuestions
        );
        
        expect(result.correctAnswers, equals(3));
        expect(result.incorrectAnswers, equals(1));
      });

      test('should handle rapid state changes correctly', () {
        // Rapidly answer multiple questions
        for (int i = 0; i < sampleQuestions.length; i++) {
          stateManager.lockAnswer(i, 1, i % 2 == 0); // Alternate correct/incorrect
        }
        
        // Verify all answers are locked
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(stateManager.isAnswerLocked(i), isTrue);
          expect(stateManager.getLockedAnswer(i), equals(1));
          expect(stateManager.isAnswerCorrect(i), equals(i % 2 == 0));
        }
        
        expect(stateManager.getCorrectAnswersCount(), equals(2)); // Questions 0 and 2
        expect(stateManager.getAnsweredQuestionsCount(), equals(4));
        expect(stateManager.areAllQuestionsAnswered(), isTrue);
      });
    });
  });
}