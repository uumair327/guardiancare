import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_validation_service.dart';

void main() {
  group('Quiz Score Calculation - First Answer Only', () {
    late QuizStateManager stateManager;
    late List<Map<String, dynamic>> testQuestions;

    setUp(() {
      stateManager = QuizStateManager();
      testQuestions = [
        {
          'question': 'What is 2+2?',
          'options': ['3', '4', '5', '6'],
          'correctAnswerIndex': 1, // '4' is correct
          'category': 'math'
        },
        {
          'question': 'What is the capital of France?',
          'options': ['London', 'Berlin', 'Paris', 'Madrid'],
          'correctAnswerIndex': 2, // 'Paris' is correct
          'category': 'geography'
        },
        {
          'question': 'What is 5*5?',
          'options': ['20', '25', '30', '35'],
          'correctAnswerIndex': 1, // '25' is correct
          'category': 'math'
        },
      ];
      stateManager.initializeQuiz(testQuestions.length);
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('First Answer Locking Behavior', () {
      test('should lock the first selected answer permanently', () {
        // Select first answer for question 0
        stateManager.lockAnswer(0, 0, false); // Wrong answer (3 instead of 4)
        
        expect(stateManager.getLockedAnswer(0), equals(0));
        expect(stateManager.isAnswerCorrect(0), isFalse);
        expect(stateManager.isAnswerLocked(0), isTrue);
        
        // Try to change to correct answer - should be ignored
        stateManager.lockAnswer(0, 1, true); // Try to change to correct answer
        
        // Verify the answer remains the first selected (incorrect) answer
        expect(stateManager.getLockedAnswer(0), equals(0));
        expect(stateManager.isAnswerCorrect(0), isFalse);
      });

      test('should prevent any answer selection after first selection', () {
        // Select answer for question 1
        stateManager.lockAnswer(1, 0, false); // Wrong answer
        
        // Verify answer is locked
        expect(QuizValidationService.canSelectAnswer(1, stateManager), isFalse);
        
        // Multiple attempts to change should all fail
        stateManager.lockAnswer(1, 1, false);
        stateManager.lockAnswer(1, 2, true);  // Correct answer
        stateManager.lockAnswer(1, 3, false);
        
        // Answer should remain the first selection
        expect(stateManager.getLockedAnswer(1), equals(0));
        expect(stateManager.isAnswerCorrect(1), isFalse);
      });

      test('should maintain first answer integrity across navigation', () {
        // Answer questions in different order
        stateManager.lockAnswer(2, 0, false); // Q3: Wrong answer first
        stateManager.lockAnswer(0, 1, true);  // Q1: Correct answer
        stateManager.lockAnswer(1, 1, false); // Q2: Wrong answer
        
        // Try to "improve" answers by changing them
        stateManager.lockAnswer(2, 1, true);  // Try to fix Q3
        stateManager.lockAnswer(1, 2, true);  // Try to fix Q2
        stateManager.lockAnswer(0, 0, false); // Try to break Q1
        
        // All answers should remain as first selected
        expect(stateManager.getLockedAnswer(0), equals(1)); // Still correct
        expect(stateManager.getLockedAnswer(1), equals(1)); // Still wrong
        expect(stateManager.getLockedAnswer(2), equals(0)); // Still wrong
        
        expect(stateManager.isAnswerCorrect(0), isTrue);
        expect(stateManager.isAnswerCorrect(1), isFalse);
        expect(stateManager.isAnswerCorrect(2), isFalse);
      });
    });

    group('Score Calculation Based on First Answers', () {
      test('should calculate score using only first selected answers', () {
        // Scenario: User selects wrong answers first, then tries to correct them
        stateManager.lockAnswer(0, 0, false); // Wrong first (3 instead of 4)
        stateManager.lockAnswer(1, 0, false); // Wrong first (London instead of Paris)
        stateManager.lockAnswer(2, 1, true);  // Correct first (25)
        
        // Attempts to "fix" wrong answers (should be ignored)
        stateManager.lockAnswer(0, 1, true);  // Try to change to correct
        stateManager.lockAnswer(1, 2, true);  // Try to change to correct
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          testQuestions
        );
        
        // Score should reflect only first answers: 1 correct out of 3
        expect(result.totalQuestions, equals(3));
        expect(result.correctAnswers, equals(1));
        expect(result.incorrectAnswers, equals(2));
        expect(result.percentage, closeTo(33.33, 0.01));
        expect(result.isPerfectScore, isFalse);
        expect(result.incorrectCategories, containsAll(['math', 'geography']));
      });

      test('should handle perfect score with first answers', () {
        // Select all correct answers on first try
        stateManager.lockAnswer(0, 1, true);  // Correct: 4
        stateManager.lockAnswer(1, 2, true);  // Correct: Paris
        stateManager.lockAnswer(2, 1, true);  // Correct: 25
        
        // Try to change correct answers to wrong ones (should be ignored)
        stateManager.lockAnswer(0, 0, false);
        stateManager.lockAnswer(1, 0, false);
        stateManager.lockAnswer(2, 0, false);
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          testQuestions
        );
        
        // Should maintain perfect score
        expect(result.totalQuestions, equals(3));
        expect(result.correctAnswers, equals(3));
        expect(result.incorrectAnswers, equals(0));
        expect(result.percentage, equals(100.0));
        expect(result.isPerfectScore, isTrue);
        expect(result.incorrectCategories, isEmpty);
      });

      test('should handle zero score with first answers', () {
        // Select all wrong answers on first try
        stateManager.lockAnswer(0, 0, false); // Wrong: 3
        stateManager.lockAnswer(1, 0, false); // Wrong: London
        stateManager.lockAnswer(2, 0, false); // Wrong: 20
        
        // Try to change to correct answers (should be ignored)
        stateManager.lockAnswer(0, 1, true);
        stateManager.lockAnswer(1, 2, true);
        stateManager.lockAnswer(2, 1, true);
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          testQuestions
        );
        
        // Should maintain zero score
        expect(result.totalQuestions, equals(3));
        expect(result.correctAnswers, equals(0));
        expect(result.incorrectAnswers, equals(3));
        expect(result.percentage, equals(0.0));
        expect(result.isPerfectScore, isFalse);
        expect(result.incorrectCategories, containsAll(['math', 'geography']));
      });
    });

    group('Educational Integrity Scenarios', () {
      test('should prevent cheating by answer changing after feedback', () {
        // Simulate user seeing feedback and trying to change answer
        
        // User selects wrong answer and sees red feedback
        stateManager.lockAnswer(0, 0, false);
        expect(stateManager.isAnswerCorrect(0), isFalse);
        
        // User tries to change to correct answer after seeing it's wrong
        stateManager.lockAnswer(0, 1, true);
        
        // System should ignore the change attempt
        expect(stateManager.getLockedAnswer(0), equals(0));
        expect(stateManager.isAnswerCorrect(0), isFalse);
        expect(QuizValidationService.canSelectAnswer(0, stateManager), isFalse);
      });

      test('should maintain quiz integrity during back navigation', () {
        // User answers questions sequentially
        stateManager.lockAnswer(0, 0, false); // Q1: Wrong
        stateManager.lockAnswer(1, 2, true);  // Q2: Correct
        stateManager.lockAnswer(2, 0, false); // Q3: Wrong
        
        // User navigates back to previous questions and tries to change answers
        stateManager.lockAnswer(0, 1, true);  // Try to fix Q1
        stateManager.lockAnswer(1, 0, false); // Try to break Q2
        
        // All original answers should be preserved
        expect(stateManager.getLockedAnswer(0), equals(0));
        expect(stateManager.getLockedAnswer(1), equals(2));
        expect(stateManager.getLockedAnswer(2), equals(0));
        
        // Final score should reflect original answers
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          testQuestions
        );
        
        expect(result.correctAnswers, equals(1)); // Only Q2 was correct
        expect(result.incorrectAnswers, equals(2)); // Q1 and Q3 were wrong
      });

      test('should handle rapid answer change attempts', () {
        // Simulate rapid clicking/tapping on different options
        stateManager.lockAnswer(0, 0, false); // First selection
        stateManager.lockAnswer(0, 1, true);  // Rapid second attempt
        stateManager.lockAnswer(0, 2, false); // Rapid third attempt
        stateManager.lockAnswer(0, 3, false); // Rapid fourth attempt
        
        // Only first selection should count
        expect(stateManager.getLockedAnswer(0), equals(0));
        expect(stateManager.isAnswerCorrect(0), isFalse);
        
        // No further selections should be possible
        expect(QuizValidationService.canSelectAnswer(0, stateManager), isFalse);
      });
    });

    group('Category-based Recommendations', () {
      test('should identify incorrect categories for recommendations', () {
        // Create scenario with mixed category performance
        stateManager.lockAnswer(0, 0, false); // Math: Wrong
        stateManager.lockAnswer(1, 2, true);  // Geography: Correct
        stateManager.lockAnswer(2, 0, false); // Math: Wrong
        
        // Try to "fix" the wrong answers
        stateManager.lockAnswer(0, 1, true);
        stateManager.lockAnswer(2, 1, true);
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          testQuestions
        );
        
        // Should recommend math category (both math questions were wrong on first try)
        expect(result.incorrectCategories, contains('math'));
        expect(result.incorrectCategories, isNot(contains('geography')));
        expect(result.correctAnswers, equals(1));
        expect(result.incorrectAnswers, equals(2));
      });

      test('should not recommend categories where first answers were correct', () {
        // All first answers correct
        stateManager.lockAnswer(0, 1, true);  // Math: Correct
        stateManager.lockAnswer(1, 2, true);  // Geography: Correct
        stateManager.lockAnswer(2, 1, true);  // Math: Correct
        
        // Try to change to wrong answers
        stateManager.lockAnswer(0, 0, false);
        stateManager.lockAnswer(1, 0, false);
        stateManager.lockAnswer(2, 0, false);
        
        final result = QuizValidationService.calculateFinalScore(
          stateManager, 
          testQuestions
        );
        
        // No categories should be recommended since first answers were all correct
        expect(result.incorrectCategories, isEmpty);
        expect(result.isPerfectScore, isTrue);
      });
    });
  });
}