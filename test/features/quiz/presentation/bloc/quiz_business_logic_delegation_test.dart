import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart'
    hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/question_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_entity.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:guardiancare/features/quiz/domain/usecases/generate_recommendations.dart';
import 'package:guardiancare/features/quiz/domain/usecases/save_quiz_history.dart';
import 'package:guardiancare/features/quiz/domain/usecases/submit_quiz.dart';
import 'package:guardiancare/features/quiz/domain/usecases/validate_quiz.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_bloc.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_event.dart';
import 'package:guardiancare/features/quiz/presentation/bloc/quiz_state.dart';

// ... Docs ...

// Mocks

class MockQuizRepository implements QuizRepository {
  @override
  Future<Either<Failure, QuizEntity>> getQuiz(String quizId) async {
    return Right(QuizEntity(
      id: quizId,
      title: 'Test Quiz',
      description: 'Test Description',
      category: 'test',
      questions: const [],
      imageUrl: null,
    ));
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestions(
      String quizId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<QuizEntity>>> getAllQuizzes() async {
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

  @override
  Future<Either<Failure, void>> saveQuizHistory({
    required String uid,
    required String quizName,
    required int score,
    required int totalQuestions,
    required List<String> categories,
  }) async {
    return const Right(null);
  }
}

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
  Future<Either<Failure, QuizResultEntity>> call(
      SubmitQuizParams params) async {
    calls.add(params);
    return mockResult;
  }
}

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

class MockGenerateRecommendations extends GenerateRecommendations {
  final List<GenerateRecommendationsParams> calls = [];
  Either<Failure, void> mockResult = const Right(null);

  MockGenerateRecommendations() : super();

  @override
  Future<Either<Failure, void>> call(
      GenerateRecommendationsParams params) async {
    calls.add(params);
    return mockResult;
  }
}

class MockSaveQuizHistory extends SaveQuizHistory {
  final List<SaveQuizHistoryParams> calls = [];
  Either<Failure, void> mockResult = const Right(null);

  MockSaveQuizHistory() : super(MockQuizRepository());

  @override
  Future<Either<Failure, void>> call(SaveQuizHistoryParams params) async {
    calls.add(params);
    return mockResult;
  }
}

class MockAuthService implements IAuthService {
  @override
  BackendUser? get currentUser =>
      const BackendUser(id: 'test_user', email: 'test@example.com');

  @override
  Stream<BackendUser?> get authStateChanges => Stream.value(currentUser);

  @override
  Stream<BackendUser?> get userChanges => Stream.value(currentUser);

  @override
  bool get isSignedIn => true;

  @override
  Future<BackendResult<BackendUser>> signInWithGoogle() async =>
      BackendResult.success(currentUser!);

  @override
  Future<BackendResult<void>> signOut() async =>
      const BackendResult.success(null);

  // Stubs using BackendResult
  @override
  Future<BackendResult<BackendUser>> signInWithEmail(
          {required String email, required String password}) async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<BackendUser>> createUserWithEmail(
          {required String email,
          required String password,
          String? displayName}) async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<void>> sendPasswordResetEmail(
          {required String email}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> confirmPasswordReset(
          {required String code, required String newPassword}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<BackendUser>> signInWithApple() async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<BackendUser>> signInWithOAuth(
          OAuthProvider provider) async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<BackendUser>> signInAnonymously() async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<BackendUser>> linkWithEmail(
          {required String email, required String password}) async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<BackendUser>> linkWithOAuth(
          OAuthProvider provider) async =>
      BackendResult.success(currentUser!);
  @override
  Future<BackendResult<void>> updateProfile(
          {String? displayName, String? photoUrl}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> updateEmail(
          {required String newEmail, required String currentPassword}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> updatePassword(
          {required String currentPassword,
          required String newPassword}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> sendEmailVerification() async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> verifyEmail({required String code}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> deleteAccount({String? password}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<String>> refreshToken() async =>
      const BackendResult.success('token');
  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => 'token';
  @override
  Future<BackendResult<void>> reauthenticate(
          {required String email, required String password}) async =>
      const BackendResult.success(null);
  @override
  Future<BackendResult<void>> reauthenticateWithOAuth(
          OAuthProvider provider) async =>
      const BackendResult.success(null);
}

// Fixture
class QuizTestFixture {
  final MockSubmitQuiz submitQuiz;
  final MockValidateQuiz validateQuiz;
  final MockGenerateRecommendations generateRecommendations;
  final MockSaveQuizHistory saveQuizHistory;
  final MockAuthService authService;
  final QuizBloc bloc;

  QuizTestFixture._({
    required this.submitQuiz,
    required this.validateQuiz,
    required this.generateRecommendations,
    required this.saveQuizHistory,
    required this.authService,
    required this.bloc,
  });

  factory QuizTestFixture.create() {
    final submitQuiz = MockSubmitQuiz();
    final validateQuiz = MockValidateQuiz();
    final generateRecommendations = MockGenerateRecommendations();
    final saveQuizHistory = MockSaveQuizHistory();
    final authService = MockAuthService();

    final bloc = QuizBloc(
      submitQuiz: submitQuiz,
      validateQuiz: validateQuiz,
      generateRecommendations: generateRecommendations,
      saveQuizHistory: saveQuizHistory,
      authService: authService,
    );
    return QuizTestFixture._(
      submitQuiz: submitQuiz,
      validateQuiz: validateQuiz,
      generateRecommendations: generateRecommendations,
      saveQuizHistory: saveQuizHistory,
      authService: authService,
      bloc: bloc,
    );
  }

  void dispose() {
    bloc.close();
  }
}

// Generators - Same
extension QuizGenerators on Any {
  Generator<int> get questionIndex => intInRange(0, 20);
  Generator<int> get optionIndex => intInRange(0, 4);
  Generator<int> get correctAnswerCount => intInRange(0, 20);
  Generator<int> get totalQuestionCount => intInRange(1, 21);
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }

  Generator<String> get category => choose([
        'child safety',
        'parenting tips',
        'online safety',
        'cyberbullying',
        'digital wellness',
        'family communication',
      ]);
  Generator<List<String>> get categoryList => nonEmptyList(category);
}

// Tests - same
void main() {
  group('Property 2: Quiz Business Logic Delegation', () {
    Glados3(any.questionIndex, any.optionIndex, any.optionIndex,
            ExploreConfig(numRuns: 100))
        .test(
      'For any answer submission, QuizBloc SHALL handle validation logic',
      (questionIndex, selectedOption, correctAnswerIndex) async {
        final fixture = QuizTestFixture.create();
        try {
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: questionIndex,
            selectedOption: selectedOption,
            correctAnswerIndex: correctAnswerIndex,
          ));
          await Future.delayed(const Duration(milliseconds: 50));
          final state = fixture.bloc.state;
          expect(state.lastAnswerValidation, isNotNull);
          final expectedIsCorrect = selectedOption == correctAnswerIndex;
          expect(
              state.lastAnswerValidation!.isCorrect, equals(expectedIsCorrect));
          expect(state.lockedQuestions[questionIndex], isTrue);
          expect(state.feedbackShown[questionIndex], isTrue);
        } finally {
          fixture.dispose();
        }
      },
    );

    Glados2(any.questionIndex, any.optionIndex, ExploreConfig(numRuns: 100))
        .test(
      'For any answer where selected equals correct, isCorrect SHALL be true',
      (questionIndex, optionIndex) async {
        final fixture = QuizTestFixture.create();
        try {
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: questionIndex,
            selectedOption: optionIndex,
            correctAnswerIndex: optionIndex,
          ));
          await Future.delayed(const Duration(milliseconds: 50));
          final validation = fixture.bloc.state.lastAnswerValidation;
          expect(validation?.isCorrect, isTrue);
        } finally {
          fixture.dispose();
        }
      },
    );

    Glados3(any.questionIndex, any.optionIndex, any.optionIndex,
            ExploreConfig(numRuns: 100))
        .test(
      'For any answer where selected differs from correct, isCorrect SHALL be false',
      (questionIndex, selectedOption, correctAnswerIndex) async {
        if (selectedOption == correctAnswerIndex) return;
        final fixture = QuizTestFixture.create();
        try {
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: questionIndex,
            selectedOption: selectedOption,
            correctAnswerIndex: correctAnswerIndex,
          ));
          await Future.delayed(const Duration(milliseconds: 50));
          final validation = fixture.bloc.state.lastAnswerValidation;
          expect(validation?.isCorrect, isFalse);
        } finally {
          fixture.dispose();
        }
      },
    );

    Glados(any.categoryList, ExploreConfig(numRuns: 100)).test(
      'For any recommendation request, QuizBloc SHALL delegate to GenerateRecommendations use case',
      (categories) async {
        final fixture = QuizTestFixture.create();
        try {
          fixture.bloc
              .add(GenerateRecommendationsRequested(categories: categories));
          await Future.delayed(const Duration(milliseconds: 50));
          expect(fixture.generateRecommendations.calls.length, equals(1));
          expect(fixture.generateRecommendations.calls.first.categories,
              equals(categories));
        } finally {
          fixture.dispose();
        }
      },
    );

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
          fixture.bloc
              .add(GenerateRecommendationsRequested(categories: categories));
          await Future.delayed(const Duration(milliseconds: 100));
          expect(states, contains(RecommendationsStatus.generating));
          expect(fixture.bloc.state.recommendationsStatus,
              equals(RecommendationsStatus.generated));
          await subscription.cancel();
        } finally {
          fixture.dispose();
        }
      },
    );

    Glados(any.categoryList, ExploreConfig(numRuns: 100)).test(
      'For any failed recommendation generation, status SHALL be failed',
      (categories) async {
        final fixture = QuizTestFixture.create();
        fixture.generateRecommendations.mockResult =
            const Left(ServerFailure('Test failure'));
        try {
          fixture.bloc
              .add(GenerateRecommendationsRequested(categories: categories));
          await Future.delayed(const Duration(milliseconds: 100));
          expect(fixture.bloc.state.recommendationsStatus,
              equals(RecommendationsStatus.failed));
        } finally {
          fixture.dispose();
        }
      },
    );

    Glados(any.intBetween(1, 5), ExploreConfig(numRuns: 100)).test(
      'For any sequence of answer submissions, all SHALL be validated by QuizBloc',
      (count) async {
        final fixture = QuizTestFixture.create();
        try {
          for (var i = 0; i < count; i++) {
            fixture.bloc.add(SubmitAnswerRequested(
              questionIndex: i,
              selectedOption: 0,
              correctAnswerIndex: 1,
            ));
          }
          await Future.delayed(
              Duration(milliseconds: 50 + (count * 20).toInt()));
          for (var i = 0; i < count; i++) {
            expect(fixture.bloc.state.lockedQuestions[i], isTrue);
            expect(fixture.bloc.state.feedbackShown[i], isTrue);
          }
        } finally {
          fixture.dispose();
        }
      },
    );
  });

  group('Quiz Business Logic Delegation - Edge Cases', () {
    test('QuizBloc should handle empty category list for recommendations',
        () async {
      final fixture = QuizTestFixture.create();
      try {
        fixture.bloc
            .add(const GenerateRecommendationsRequested(categories: []));
        await Future.delayed(const Duration(milliseconds: 100));
        expect(fixture.generateRecommendations.calls.length, equals(1));
      } finally {
        fixture.dispose();
      }
    });

    test('QuizBloc should handle rapid answer submissions', () async {
      final fixture = QuizTestFixture.create();
      try {
        for (var i = 0; i < 5; i++) {
          fixture.bloc.add(SubmitAnswerRequested(
            questionIndex: i,
            selectedOption: i % 4,
            correctAnswerIndex: 0,
          ));
        }
        await Future.delayed(const Duration(milliseconds: 200));
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

    test('QuizBloc should handle recommendation generation after quiz reset',
        () async {
      final fixture = QuizTestFixture.create();
      try {
        fixture.bloc.add(const GenerateRecommendationsRequested(
            categories: ['child safety']));
        await Future.delayed(const Duration(milliseconds: 100));
        fixture.bloc.add(const QuizReset());
        await Future.delayed(const Duration(milliseconds: 50));
        expect(fixture.bloc.state.recommendationsStatus,
            equals(RecommendationsStatus.idle));
      } finally {
        fixture.dispose();
      }
    });
  });
}
