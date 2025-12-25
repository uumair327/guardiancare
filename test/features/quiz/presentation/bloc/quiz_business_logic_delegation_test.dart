import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:guardiancare/features/quiz/domain/usecases/generate_recommendations.dart';
import 'package:guardiancare/features/quiz/domain/usecases/submit_quiz.dart';
import 'package:guardiancare/features/quiz/domain/usecases/validate_quiz.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_state.dart';

/// **Feature: srp-clean-architecture-fix, Property 2: Quiz Business Logic Delegation**
/// **Validates: Requirements 2.1, 2.2, 2.3**
///
/// Property: For any quiz answer submission, quiz completion, or recommendation
/// generation request, the QuizQuestionsPage SHALL dispatch events to QuizBloc,
/// and the QuizBloc SHALL handle all business logic including validation, scoring,
/// and repository coordination.

// ============================================================================
// Mock Implementations for Testing
// ============================================================================

/// Mock SubmitQuiz use case that tracks calls
class MockSubmitQuiz extends SubmitQuiz {
  final List<SubmitQuizParams> calls = [];
  Either<Failure, QuizResultEntity> mockResult = Right(const QuizResultEntity(
    totalQuestions: 10,
    correctAnswers: 8,
    incorrectAnswers: 2,
    scorePercentage: 80.0,
    selectedAnswers: {},
    incorrectCategories: [],
  ));

  MockSubmitQuiz() : super(MockQuizRepository());

  @override
  Future<Either<Failure, QuizResultEntity>> call(SubmitQuizParams params) async {
    calls.add(params);
    return mockResult;
  }
}

/// Mock ValidateQuiz use case that tracks calls
class MockValidateQuiz extends ValidateQuiz {
  final List<List<QuestionEntity>> calls = [];
  Either<Failure, bool> mockResult = const Right(true);

  MockValidateQuiz() : super(MockQuizRepository());

  @override
  Future<Either<Failure, bool>> call(List<QuestionEntity> params) async {
    calls.add(params);
    return mockResult;
  }
}

/// Mock GenerateRecommendations use case that tracks calls
class MockGenerateRecommendations extends GenerateRecommendations {
  final List<GenerateRecommendationsParams> calls = [];
  Either<Failure, void> mockResult = const Right(null);

  MockGenerateRecommendations() : super();

  @override
  Future<Either<Failure, void>> call(GenerateRecommendationsParams params) async {
    calls.add(params);
    return mockResult;
  }
}

/// Mock QuizRepository for use case construction
class MockQuizRepository implements QuizRepository {
  @override
  Future<Either<Failure, QuizEntity>> getQuiz(String quizId) async {
    return Right(QuizEntity(
      id: quizId,
      title: 'Test Quiz',
      description: 'Test Description',
      category: 'test',
      questions: const [],
    ));
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestions(String quizId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, QuizResultEntity>> submitQuiz({
    required String quizId,
    required Map<int, String> answers,
    required List<QuestionEntity> questions,
  }) async {
    return Right(const QuizResultEntity(
      totalQuestions: 10,
      correctAnswers: 8,
      incorrectAnswers: 2,
      scorePercentage: 80.0,
      selectedAnswers: {},
      incorrectCategories: [],
    ));
  }

  @override
  Either<Failure, bool> validateQuizData(List<QuestionEntity> questions) {
    return const Right(true);
  }
}

// ============================================================================
// Test Fixture
// ============================================================================

class QuizTestFixture {
  final MockSubmitQuiz submitQuiz;
  final MockValidateQuiz validateQuiz;
  final MockGenerateRecommendations generateRecommendations;
  final QuizBloc bloc;

  QuizTestFixture._({
    required this.submitQuiz,
    required this.validateQuiz,
    required this.generateRecommendations,
    required this.bloc,
  });

  factory QuizTestFixture.create() {
    final submitQuiz = MockSubmitQuiz();
    final validateQuiz = MockValidateQuiz();
    final generateRecommendations = MockGenerateRecommendations();
    final bloc = QuizBloc(
      submitQuiz: submitQuiz,
      validateQuiz: validateQuiz,
      generateRecommendations: generateRecommendations,
    );
    return QuizTestFixture._(
      submitQuiz: submitQuiz,
      validateQuiz: validateQuiz,
      generateRecommendations: generateRecommendations,
      bloc: bloc,
    );
  }

  void dispose() {
    bloc.close();
  }
}

// ============================================================================
// Custom Generators for Glados
// ============================================================================

/// Extension to add custom generators for quiz testing
extension QuizGenerators on Any {
  /// Generator for question indices (0-19 range for typical quiz)
  Generator<int> get questionIndex => intInRange(0, 20);

  /// Generator for option indices (0-3 for typical 4-option questions)
  Generator<int> get optionIndex => intInRange(0, 4);

  /// Generator for correct answer counts
  Generator<int> get correctAnswerCount => intInRange(0, 20);

  /// Generator for total question counts (1-20)
  Generator<int> get totalQuestionCount => intInRange(1, 21);

  /// Generator for positive integers between min and max (inclusive)
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }

  /// Generator for quiz categories
  Generator<String> get category => choose([
        'child safety',
        'parenting tips',
        'online safety',
        'cyberbullying',
        'digital wellness',
        'family communication',
      ]);

  /// Generator for category lists
  Generator<List<String>> get categoryList =>
      nonEmptyList(category);
}

/// Data class for answer submission test input
class AnswerSubmissionInput {
  final int questionIndex;
  final int selectedOption;
  final int correctAnswerIndex;

  AnswerSubmissionInput({
    required this.questionIndex,
    required this.selectedOption,
    required this.correctAnswerIndex,
  });

  @override
  String toString() =>
      'AnswerSubmissionInput(q:$questionIndex, sel:$selectedOption, correct:$correctAnswerIndex)';
}

/// Data class for quiz completion test input
class QuizCompletionInput {
  final int correctAnswers;
  final int totalQuestions;
  final List<String> categories;

  QuizCompletionInput({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.categories,
  });

  @override
  String toString() =>
      'QuizCompletionInput(correct:$correctAnswers, total:$totalQuestions, cats:$categories)';
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  group('Property 2: Quiz Business Logic Delegation', () {
    // ========================================================================
    // Property 2.1: Answer submission validation is handled by QuizBloc
    // Validates: Requirement 2.1
    // ========================================================================
    Glados3(any.questionIndex, any.optionIndex, any.optionIndex, ExploreConfig(numRuns: 100))
        .test(
      'For any answer submission, QuizBloc SHALL handle validation logic',
      (questionIndex, selectedOption, correctAnswerIndex) async {
        final fixture = QuizTestFixture.create();

        try {
          // Act - dispatch SubmitAnswerRequested event
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: questionIndex,
            selectedOption: selectedOption,
            correctAnswerIndex: correctAnswerIndex,
          ));

          // Allow bloc to process
          await Future.delayed(const Duration(milliseconds: 50));

          // Assert: QuizBloc processed the validation
          final state = fixture.bloc.state;

          // Verify validation result is set
          expect(
            state.lastAnswerValidation,
            isNotNull,
            reason: 'QuizBloc should set lastAnswerValidation after SubmitAnswerRequested',
          );

          // Verify validation correctness
          final expectedIsCorrect = selectedOption == correctAnswerIndex;
          expect(
            state.lastAnswerValidation!.isCorrect,
            equals(expectedIsCorrect),
            reason:
                'Validation should be correct=$expectedIsCorrect for selected=$selectedOption, correct=$correctAnswerIndex',
          );

          // Verify question is locked after submission
          expect(
            state.lockedQuestions[questionIndex],
            isTrue,
            reason: 'Question $questionIndex should be locked after answer submission',
          );

          // Verify feedback is shown
          expect(
            state.feedbackShown[questionIndex],
            isTrue,
            reason: 'Feedback should be shown for question $questionIndex',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 2.2: Correct answer detection is accurate
    // Validates: Requirement 2.1
    // ========================================================================
    Glados2(any.questionIndex, any.optionIndex, ExploreConfig(numRuns: 100)).test(
      'For any answer where selected equals correct, isCorrect SHALL be true',
      (questionIndex, optionIndex) async {
        final fixture = QuizTestFixture.create();

        try {
          // Act - submit answer where selected == correct
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: questionIndex,
            selectedOption: optionIndex,
            correctAnswerIndex: optionIndex, // Same as selected
          ));

          await Future.delayed(const Duration(milliseconds: 50));

          // Assert
          final validation = fixture.bloc.state.lastAnswerValidation;
          expect(
            validation?.isCorrect,
            isTrue,
            reason: 'When selected option equals correct answer, isCorrect should be true',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 2.3: Incorrect answer detection is accurate
    // Validates: Requirement 2.1
    // ========================================================================
    Glados3(any.questionIndex, any.optionIndex, any.optionIndex, ExploreConfig(numRuns: 100))
        .test(
      'For any answer where selected differs from correct, isCorrect SHALL be false',
      (questionIndex, selectedOption, correctAnswerIndex) async {
        // Skip if they happen to be equal
        if (selectedOption == correctAnswerIndex) return;

        final fixture = QuizTestFixture.create();

        try {
          // Act
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: questionIndex,
            selectedOption: selectedOption,
            correctAnswerIndex: correctAnswerIndex,
          ));

          await Future.delayed(const Duration(milliseconds: 50));

          // Assert
          final validation = fixture.bloc.state.lastAnswerValidation;
          expect(
            validation?.isCorrect,
            isFalse,
            reason:
                'When selected ($selectedOption) differs from correct ($correctAnswerIndex), isCorrect should be false',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 2.4: Recommendation generation is delegated to use case
    // Validates: Requirement 2.3
    // ========================================================================
    Glados(any.categoryList, ExploreConfig(numRuns: 100)).test(
      'For any recommendation request, QuizBloc SHALL delegate to GenerateRecommendations use case',
      (categories) async {
        final fixture = QuizTestFixture.create();

        try {
          // Act
          fixture.bloc.add(GenerateRecommendationsRequested(categories: categories));

          await Future.delayed(const Duration(milliseconds: 50));

          // Assert: Use case was called
          expect(
            fixture.generateRecommendations.calls.length,
            equals(1),
            reason: 'GenerateRecommendations use case should be called once',
          );

          // Assert: Correct categories were passed
          expect(
            fixture.generateRecommendations.calls.first.categories,
            equals(categories),
            reason: 'Categories should be passed to use case',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 2.5: Recommendation status transitions correctly
    // Validates: Requirement 2.3
    // ========================================================================
    Glados(any.categoryList, ExploreConfig(numRuns: 100)).test(
      'For any successful recommendation generation, status SHALL transition to generated',
      (categories) async {
        final fixture = QuizTestFixture.create();
        fixture.generateRecommendations.mockResult = const Right(null);

        try {
          final states = <RecommendationsStatus>[];
          final subscription = fixture.bloc.stream.listen((state) {
            states.add(state.recommendationsStatus);
          });

          // Act
          fixture.bloc.add(GenerateRecommendationsRequested(categories: categories));

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: Status transitioned through generating to generated
          expect(
            states,
            contains(RecommendationsStatus.generating),
            reason: 'Status should transition to generating',
          );
          expect(
            fixture.bloc.state.recommendationsStatus,
            equals(RecommendationsStatus.generated),
            reason: 'Final status should be generated on success',
          );

          await subscription.cancel();
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 2.6: Failed recommendation generation sets failed status
    // Validates: Requirement 2.3
    // ========================================================================
    Glados(any.categoryList, ExploreConfig(numRuns: 100)).test(
      'For any failed recommendation generation, status SHALL be failed',
      (categories) async {
        final fixture = QuizTestFixture.create();
        fixture.generateRecommendations.mockResult =
            const Left(ServerFailure('Test failure'));

        try {
          // Act
          fixture.bloc.add(GenerateRecommendationsRequested(categories: categories));

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert
          expect(
            fixture.bloc.state.recommendationsStatus,
            equals(RecommendationsStatus.failed),
            reason: 'Status should be failed when use case returns failure',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 2.7: Multiple answer submissions are all validated
    // Validates: Requirement 2.1
    // ========================================================================
    Glados(
      any.intBetween(1, 5),
      ExploreConfig(numRuns: 100),
    ).test(
      'For any sequence of answer submissions, all SHALL be validated by QuizBloc',
      (count) async {
        final fixture = QuizTestFixture.create();

        try {
          // Act - submit answers for each question index
          for (var i = 0; i < count; i++) {
            fixture.bloc.add(SubmitAnswerRequested(
              questionIndex: i,
              selectedOption: 0,
              correctAnswerIndex: 1,
            ));
          }

          await Future.delayed(Duration(milliseconds: 50 + (count * 20).toInt()));

          // Assert: All questions are locked
          for (var i = 0; i < count; i++) {
            expect(
              fixture.bloc.state.lockedQuestions[i],
              isTrue,
              reason: 'Question $i should be locked after submission',
            );
          }

          // Assert: All questions have feedback shown
          for (var i = 0; i < count; i++) {
            expect(
              fixture.bloc.state.feedbackShown[i],
              isTrue,
              reason: 'Feedback should be shown for question $i',
            );
          }
        } finally {
          fixture.dispose();
        }
      },
    );
  });

  // ==========================================================================
  // Unit Tests for Edge Cases
  // ==========================================================================
  group('Quiz Business Logic Delegation - Edge Cases', () {
    test('QuizBloc should handle empty category list for recommendations', () async {
      final fixture = QuizTestFixture.create();

      try {
        fixture.bloc.add(const GenerateRecommendationsRequested(categories: []));

        await Future.delayed(const Duration(milliseconds: 100));

        // Use case should still be called (validation happens in use case)
        expect(fixture.generateRecommendations.calls.length, equals(1));
      } finally {
        fixture.dispose();
      }
    });

    test('QuizBloc should handle rapid answer submissions', () async {
      final fixture = QuizTestFixture.create();

      try {
        // Rapidly submit answers
        for (var i = 0; i < 5; i++) {
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: i,
            selectedOption: i % 4,
            correctAnswerIndex: 0,
          ));
        }

        await Future.delayed(const Duration(milliseconds: 200));

        // All should be processed
        expect(fixture.bloc.state.lockedQuestions.length, equals(5));
        expect(fixture.bloc.state.feedbackShown.length, equals(5));
      } finally {
        fixture.dispose();
      }
    });

    test('QuizBloc should preserve validation result details', () async {
      final fixture = QuizTestFixture.create();

      try {
        fixture.bloc.add(const SubmitAnswerRequested(
          questionIndex: 5,
          selectedOption: 2,
          correctAnswerIndex: 3,
        ));

        await Future.delayed(const Duration(milliseconds: 50));

        final validation = fixture.bloc.state.lastAnswerValidation;
        expect(validation, isNotNull);
        expect(validation!.questionIndex, equals(5));
        expect(validation.selectedOption, equals(2));
        expect(validation.correctAnswerIndex, equals(3));
        expect(validation.isCorrect, isFalse);
      } finally {
        fixture.dispose();
      }
    });

    test('QuizBloc should handle recommendation generation after quiz reset', () async {
      final fixture = QuizTestFixture.create();

      try {
        // Generate recommendations
        fixture.bloc.add(const GenerateRecommendationsRequested(
          categories: ['child safety'],
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Reset quiz
        fixture.bloc.add(const QuizReset());
        await Future.delayed(const Duration(milliseconds: 50));

        // State should be reset
        expect(
          fixture.bloc.state.recommendationsStatus,
          equals(RecommendationsStatus.idle),
        );
      } finally {
        fixture.dispose();
      }
    });
  });
}
