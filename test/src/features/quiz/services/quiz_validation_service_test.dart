import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_validation_service.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';

void main() {
  group('QuizValidationService Tests', () {
    late QuizStateManager stateManager;
    late List<Map<String, dynamic>> sampleQuestions;
    late Map<int, int> sampleCorrectAnswers;

    setUp(() {
      stateManager = QuizStateManager();
      sampleQuestions = [
        {
          'question': 'What is 2 + 2?',
          'options': ['3', '4', '5', '6'],
        },
        {
          'question': 'What is the capital of France?',
          'options': ['London', 'Berlin', 'Paris', 'Madrid'],
        },
        {
          'question': 'What color is the sky?',
          'options': ['Red', 'Blue', 'Green', 'Yellow'],
        },
      ];
      sampleCorrectAnswers = {
        0: 1, // '4'
        1: 2, // 'Paris'
        2: 1, // 'Blue'
      };
    });

    tearDown(() {
      stateManager.dispose();
    });

    group('Answer Selection Validation', () {
      test('should allow answer selection for unlocked question', () {
        // Act
        final canSelect = QuizValidationService.canSelectAnswer(0, stateManager);

        // Assert
        expect(canSelect, isTrue);
      });

      test('should prevent answer selection for locked question', () {
        // Arrange
        stateManager.selectAnswer(0, '4');
        stateManager.showFeedback(0);

        // Act
        final canSelect = QuizValidationService.canSelectAnswer(0, stateManager);

        // Assert
        expect(canSelect, isFalse);
      });
    });

    group('Score Calculation', () {
      test('should calculate correct score for all correct answers', () {
        // Arrange
        final selectedAnswers = {
          0: '4',      // Correct
          1: 'Paris',  // Correct
          2: 'Blue',   // Correct
        };

        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(3));
      });

      test('should calculate correct score for mixed answers', () {
        // Arrange
        final selectedAnswers = {
          0: '4',      // Correct
          1: 'London', // Incorrect
          2: 'Blue',   // Correct
        };

        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(2));
      });

      test('should calculate zero score for all incorrect answers', () {
        // Arrange
        final selectedAnswers = {
          0: '3',      // Incorrect
          1: 'London', // Incorrect
          2: 'Red',    // Incorrect
        };

        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(0));
      });

      test('should handle partial answers correctly', () {
        // Arrange - Only answer first two questions
        final selectedAnswers = {
          0: '4',      // Correct
          1: 'Paris',  // Correct
          // Question 2 not answered
        };

        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(2));
      });

      test('should calculate score percentage correctly', () {
        // Arrange
        final selectedAnswers = {
          0: '4',      // Correct
          1: 'London', // Incorrect
          2: 'Blue',   // Correct
        };

        // Act
        final percentage = QuizValidationService.calculateScorePercentage(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(percentage, closeTo(66.67, 0.01)); // 2/3 * 100
      });

      test('should return 0% for empty quiz', () {
        // Act
        final percentage = QuizValidationService.calculateScorePercentage(
          {},
          {},
          [],
        );

        // Assert
        expect(percentage, equals(0.0));
      });
    });

    group('Quiz Completion Validation', () {
      test('should return true when all questions are answered', () {
        // Arrange
        stateManager.selectAnswer(0, '4');
        stateManager.selectAnswer(1, 'Paris');
        stateManager.selectAnswer(2, 'Blue');

        // Act
        final isComplete = QuizValidationService.isQuizComplete(
          sampleQuestions,
          stateManager,
        );

        // Assert
        expect(isComplete, isTrue);
      });

      test('should return false when some questions are unanswered', () {
        // Arrange
        stateManager.selectAnswer(0, '4');
        stateManager.selectAnswer(1, 'Paris');
        // Question 2 not answered

        // Act
        final isComplete = QuizValidationService.isQuizComplete(
          sampleQuestions,
          stateManager,
        );

        // Assert
        expect(isComplete, isFalse);
      });

      test('should return true for empty quiz', () {
        // Act
        final isComplete = QuizValidationService.isQuizComplete(
          [],
          stateManager,
        );

        // Assert
        expect(isComplete, isTrue);
      });
    });

    group('Answer Counting', () {
      test('should count correct answers correctly', () {
        // Arrange
        final selectedAnswers = {
          0: '4',      // Correct
          1: 'London', // Incorrect
          2: 'Blue',   // Correct
        };

        // Act
        final correctCount = QuizValidationService.getCorrectAnswersCount(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(correctCount, equals(2));
      });

      test('should count incorrect answers correctly', () {
        // Arrange
        final selectedAnswers = {
          0: '4',      // Correct
          1: 'London', // Incorrect
          2: 'Blue',   // Correct
        };

        // Act
        final incorrectCount = QuizValidationService.getIncorrectAnswersCount(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(incorrectCount, equals(1));
      });
    });

    group('Answer Validation', () {
      test('should validate non-empty answers as valid', () {
        // Act & Assert
        expect(QuizValidationService.isValidAnswer('Answer A'), isTrue);
        expect(QuizValidationService.isValidAnswer('  Answer B  '), isTrue);
        expect(QuizValidationService.isValidAnswer('123'), isTrue);
      });

      test('should validate empty answers as invalid', () {
        // Act & Assert
        expect(QuizValidationService.isValidAnswer(''), isFalse);
        expect(QuizValidationService.isValidAnswer('   '), isFalse);
      });
    });

    group('Quiz Status', () {
      test('should provide complete quiz status for finished quiz', () {
        // Arrange
        stateManager.selectAnswer(0, '4');      // Correct
        stateManager.selectAnswer(1, 'London'); // Incorrect
        stateManager.selectAnswer(2, 'Blue');   // Correct

        // Act
        final status = QuizValidationService.getQuizStatus(
          sampleQuestions,
          stateManager,
          sampleCorrectAnswers,
        );

        // Assert
        expect(status['totalQuestions'], equals(3));
        expect(status['answeredQuestions'], equals(3));
        expect(status['correctAnswers'], equals(2));
        expect(status['incorrectAnswers'], equals(1));
        expect(status['isComplete'], isTrue);
        expect(status['progress'], equals(1.0));
        expect(status['score'], equals(2));
        expect(status['scorePercentage'], closeTo(66.67, 0.01));
      });

      test('should provide partial quiz status for incomplete quiz', () {
        // Arrange
        stateManager.selectAnswer(0, '4');      // Correct
        stateManager.selectAnswer(1, 'London'); // Incorrect
        // Question 2 not answered

        // Act
        final status = QuizValidationService.getQuizStatus(
          sampleQuestions,
          stateManager,
          sampleCorrectAnswers,
        );

        // Assert
        expect(status['totalQuestions'], equals(3));
        expect(status['answeredQuestions'], equals(2));
        expect(status['correctAnswers'], equals(0)); // Not calculated for incomplete
        expect(status['incorrectAnswers'], equals(0)); // Not calculated for incomplete
        expect(status['isComplete'], isFalse);
        expect(status['progress'], closeTo(0.67, 0.01));
        expect(status['score'], equals(0));
        expect(status['scorePercentage'], equals(0.0));
      });
    });

    group('Quiz Data Validation', () {
      test('should validate correct quiz data structure', () {
        // Act
        final isValid = QuizValidationService.isValidQuizData(sampleQuestions);

        // Assert
        expect(isValid, isTrue);
      });

      test('should reject empty quiz data', () {
        // Act
        final isValid = QuizValidationService.isValidQuizData([]);

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject quiz data with missing question field', () {
        // Arrange
        final invalidQuestions = [
          {
            // Missing 'question' field
            'options': ['A', 'B', 'C', 'D'],
          }
        ];

        // Act
        final isValid = QuizValidationService.isValidQuizData(invalidQuestions);

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject quiz data with missing options field', () {
        // Arrange
        final invalidQuestions = [
          {
            'question': 'What is 2 + 2?',
            // Missing 'options' field
          }
        ];

        // Act
        final isValid = QuizValidationService.isValidQuizData(invalidQuestions);

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject quiz data with insufficient options', () {
        // Arrange
        final invalidQuestions = [
          {
            'question': 'What is 2 + 2?',
            'options': ['4'], // Only one option
          }
        ];

        // Act
        final isValid = QuizValidationService.isValidQuizData(invalidQuestions);

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject quiz data with empty options', () {
        // Arrange
        final invalidQuestions = [
          {
            'question': 'What is 2 + 2?',
            'options': ['', 'B', 'C', 'D'], // Empty option
          }
        ];

        // Act
        final isValid = QuizValidationService.isValidQuizData(invalidQuestions);

        // Assert
        expect(isValid, isFalse);
      });

      test('should reject quiz data with non-string options', () {
        // Arrange
        final invalidQuestions = [
          {
            'question': 'What is 2 + 2?',
            'options': [1, 2, 3, 4], // Non-string options
          }
        ];

        // Act
        final isValid = QuizValidationService.isValidQuizData(invalidQuestions);

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle out-of-bounds correct answer indices', () {
        // Arrange
        final selectedAnswers = {0: '4'};
        final invalidCorrectAnswers = {0: 10}; // Index out of bounds
        
        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          invalidCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(0)); // Should not crash, return 0
      });

      test('should handle missing correct answer mapping', () {
        // Arrange
        final selectedAnswers = {0: '4', 1: 'Paris'};
        final incompleteCorrectAnswers = {0: 1}; // Missing mapping for question 1
        
        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          incompleteCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(1)); // Only count question 0
      });

      test('should handle selected answers for non-existent questions', () {
        // Arrange
        final selectedAnswers = {
          0: '4',
          10: 'Non-existent', // Question 10 doesn't exist
        };
        
        // Act
        final score = QuizValidationService.calculateScore(
          selectedAnswers,
          sampleCorrectAnswers,
          sampleQuestions,
        );

        // Assert
        expect(score, equals(1)); // Only count valid question 0
      });
    });

    group('Service Reset', () {
      test('should reset validation state without errors', () {
        // Act & Assert - Should not throw
        expect(() => QuizValidationService.resetValidation(), returnsNormally);
      });
    });
  });
}