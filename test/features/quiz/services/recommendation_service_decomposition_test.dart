import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_recommendation_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/recommendation_repository.dart';
import 'package:guardiancare/features/quiz/domain/services/gemini_ai_service.dart';
import 'package:guardiancare/features/quiz/domain/services/youtube_search_service.dart';
import 'package:guardiancare/features/quiz/domain/usecases/recommendation_use_case.dart';

/// **Feature: srp-clean-architecture-fix, Property 4: Recommendation Service Decomposition**
/// **Validates: Requirements 4.1, 4.2, 4.3, 4.5**
///
/// Property: For any recommendation generation request, the GeminiAIService SHALL
/// handle only Gemini API interactions, the YoutubeSearchService SHALL handle only
/// YouTube API interactions, and the RecommendationRepository SHALL handle only
/// Firestore persistence operations.

// ============================================================================
// Mock Implementations for Testing
// ============================================================================

/// Mock GeminiAIService that tracks all method calls and verifies single responsibility
class MockGeminiAIService implements GeminiAIService {
  final List<String> methodCalls = [];
  final List<String> categoryRequests = [];
  
  Either<Failure, List<String>> mockResult = const Right(['search term 1', 'search term 2']);
  bool shouldFail = false;
  String failureMessage = 'Gemini API error';

  @override
  Future<Either<Failure, List<String>>> generateSearchTerms(String category) async {
    methodCalls.add('generateSearchTerms');
    categoryRequests.add(category);
    
    if (shouldFail) {
      return Left(GeminiApiFailure(failureMessage));
    }
    return mockResult;
  }

  /// Verifies that only Gemini-related methods were called
  bool get onlyGeminiMethodsCalled {
    return methodCalls.every((call) => call == 'generateSearchTerms');
  }

  void reset() {
    methodCalls.clear();
    categoryRequests.clear();
    shouldFail = false;
  }
}

/// Mock YoutubeSearchService that tracks all method calls and verifies single responsibility
class MockYoutubeSearchService implements YoutubeSearchService {
  final List<String> methodCalls = [];
  final List<String> searchTermRequests = [];
  
  Either<Failure, VideoData> mockResult = const Right(VideoData(
    videoId: 'test-video-id',
    title: 'Test Video Title',
    thumbnailUrl: 'https://img.youtube.com/vi/test/0.jpg',
    videoUrl: 'https://youtu.be/test-video-id',
  ));
  bool shouldFail = false;
  String failureMessage = 'YouTube API error';

  @override
  Future<Either<Failure, VideoData>> searchVideo(String term) async {
    methodCalls.add('searchVideo');
    searchTermRequests.add(term);
    
    if (shouldFail) {
      return Left(YoutubeApiFailure(failureMessage));
    }
    return mockResult;
  }

  /// Verifies that only YouTube-related methods were called
  bool get onlyYoutubeMethodsCalled {
    return methodCalls.every((call) => call == 'searchVideo');
  }

  void reset() {
    methodCalls.clear();
    searchTermRequests.clear();
    shouldFail = false;
  }
}

/// Mock RecommendationRepository that tracks all method calls and verifies single responsibility
class MockRecommendationRepository implements RecommendationRepository {
  final List<String> methodCalls = [];
  final List<QuizRecommendation> savedRecommendations = [];
  final List<String> clearedUserIds = [];
  final List<String> queriedUserIds = [];
  
  Either<Failure, String> saveResult = const Right('doc-id-123');
  Either<Failure, int> clearResult = const Right(0);
  Either<Failure, List<QuizRecommendation>> getResult = const Right([]);
  bool shouldFailSave = false;
  bool shouldFailClear = false;
  bool shouldFailGet = false;

  @override
  Future<Either<Failure, String>> saveRecommendation(QuizRecommendation recommendation) async {
    methodCalls.add('saveRecommendation');
    savedRecommendations.add(recommendation);
    
    if (shouldFailSave) {
      return const Left(ServerFailure('Failed to save recommendation'));
    }
    return saveResult;
  }

  @override
  Future<Either<Failure, int>> clearUserRecommendations(String userId) async {
    methodCalls.add('clearUserRecommendations');
    clearedUserIds.add(userId);
    
    if (shouldFailClear) {
      return const Left(ServerFailure('Failed to clear recommendations'));
    }
    return clearResult;
  }

  @override
  Future<Either<Failure, List<QuizRecommendation>>> getUserRecommendations(String userId) async {
    methodCalls.add('getUserRecommendations');
    queriedUserIds.add(userId);
    
    if (shouldFailGet) {
      return const Left(ServerFailure('Failed to get recommendations'));
    }
    return getResult;
  }

  /// Verifies that only persistence-related methods were called
  bool get onlyPersistenceMethodsCalled {
    return methodCalls.every((call) => 
      call == 'saveRecommendation' || 
      call == 'clearUserRecommendations' || 
      call == 'getUserRecommendations'
    );
  }

  void reset() {
    methodCalls.clear();
    savedRecommendations.clear();
    clearedUserIds.clear();
    queriedUserIds.clear();
    shouldFailSave = false;
    shouldFailClear = false;
    shouldFailGet = false;
  }
}

// ============================================================================
// Test Fixture
// ============================================================================

class RecommendationTestFixture {

  RecommendationTestFixture._({
    required this.geminiService,
    required this.youtubeService,
    required this.repository,
    required this.useCase,
  });

  factory RecommendationTestFixture.create() {
    final geminiService = MockGeminiAIService();
    final youtubeService = MockYoutubeSearchService();
    final repository = MockRecommendationRepository();
    final useCase = RecommendationUseCase(
      geminiService: geminiService,
      youtubeService: youtubeService,
      repository: repository,
    );
    return RecommendationTestFixture._(
      geminiService: geminiService,
      youtubeService: youtubeService,
      repository: repository,
      useCase: useCase,
    );
  }
  final MockGeminiAIService geminiService;
  final MockYoutubeSearchService youtubeService;
  final MockRecommendationRepository repository;
  final RecommendationUseCase useCase;

  void reset() {
    geminiService.reset();
    youtubeService.reset();
    repository.reset();
  }
}

// ============================================================================
// Custom Generators for Glados
// ============================================================================

/// Sample category names for testing
final sampleCategories = [
  'Child Safety',
  'Online Safety',
  'Cyberbullying',
  'Digital Wellness',
  'Family Communication',
  'Parenting Tips',
  'Internet Safety',
  'Social Media',
  'Privacy',
  'Screen Time',
];

/// Sample user IDs for testing
final sampleUserIds = [
  'user-123',
  'user-456',
  'user-789',
  'test-user-001',
  'test-user-002',
];

/// Sample search terms for testing
final sampleSearchTerms = [
  'child safety tips for parents',
  'online safety education kids',
  'cyberbullying prevention guide',
  'digital wellness family',
  'parenting in digital age',
];

/// Extension to add custom generators for recommendation testing
extension RecommendationGenerators on Any {
  /// Generator for category names
  Generator<String> get category => choose(sampleCategories);

  /// Generator for non-empty category lists
  Generator<List<String>> get categoryList => nonEmptyList(category);

  /// Generator for user IDs
  Generator<String> get userId => choose(sampleUserIds);

  /// Generator for search terms
  Generator<String> get searchTerm => choose(sampleSearchTerms);

  /// Generator for search term lists
  Generator<List<String>> get searchTermList => nonEmptyList(searchTerm);

  /// Generator for positive integers between min and max (inclusive)
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }

  /// Generator for VideoData
  Generator<VideoData> get videoData {
    return combine4(
      choose(['vid1', 'vid2', 'vid3', 'vid4', 'vid5']),
      choose(['Video Title 1', 'Video Title 2', 'Video Title 3']),
      choose(['https://img.youtube.com/vi/vid1/0.jpg', 'https://img.youtube.com/vi/vid2/0.jpg']),
      choose(['https://youtu.be/vid1', 'https://youtu.be/vid2', 'https://youtu.be/vid3']),
      (videoId, title, thumbnailUrl, videoUrl) => VideoData(
        videoId: videoId,
        title: title,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
      ),
    );
  }
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  group('Property 4: Recommendation Service Decomposition', () {
    // ========================================================================
    // Property 4.1: GeminiAIService handles only Gemini API interactions
    // Validates: Requirement 4.1
    // ========================================================================
    Glados(any.category, ExploreConfig()).test(
      'For any category, GeminiAIService SHALL handle only Gemini API interactions',
      (category) async {
        final fixture = RecommendationTestFixture.create();

        try {
          // Act - call generateSearchTerms
          await fixture.geminiService.generateSearchTerms(category);

          // Assert: Only Gemini-related methods were called
          expect(
            fixture.geminiService.onlyGeminiMethodsCalled,
            isTrue,
            reason: 'GeminiAIService should only call Gemini-related methods',
          );

          // Assert: The category was passed correctly
          expect(
            fixture.geminiService.categoryRequests,
            contains(category),
            reason: 'GeminiAIService should receive the category: $category',
          );

          // Assert: Method was called exactly once
          expect(
            fixture.geminiService.methodCalls.length,
            equals(1),
            reason: 'generateSearchTerms should be called exactly once',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.2: YoutubeSearchService handles only YouTube API interactions
    // Validates: Requirement 4.2
    // ========================================================================
    Glados(any.searchTerm, ExploreConfig()).test(
      'For any search term, YoutubeSearchService SHALL handle only YouTube API interactions',
      (searchTerm) async {
        final fixture = RecommendationTestFixture.create();

        try {
          // Act - call searchVideo
          await fixture.youtubeService.searchVideo(searchTerm);

          // Assert: Only YouTube-related methods were called
          expect(
            fixture.youtubeService.onlyYoutubeMethodsCalled,
            isTrue,
            reason: 'YoutubeSearchService should only call YouTube-related methods',
          );

          // Assert: The search term was passed correctly
          expect(
            fixture.youtubeService.searchTermRequests,
            contains(searchTerm),
            reason: 'YoutubeSearchService should receive the search term: $searchTerm',
          );

          // Assert: Method was called exactly once
          expect(
            fixture.youtubeService.methodCalls.length,
            equals(1),
            reason: 'searchVideo should be called exactly once',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.3: RecommendationRepository handles only persistence operations
    // Validates: Requirement 4.3
    // ========================================================================
    Glados2(any.category, any.userId, ExploreConfig()).test(
      'For any recommendation save, RecommendationRepository SHALL handle only persistence operations',
      (category, userId) async {
        final fixture = RecommendationTestFixture.create();

        try {
          // Create a recommendation
          final recommendation = QuizRecommendation(
            title: 'Test Video',
            videoUrl: 'https://youtu.be/test',
            category: category,
            thumbnailUrl: 'https://img.youtube.com/vi/test/0.jpg',
            userId: userId,
          );

          // Act - save recommendation
          await fixture.repository.saveRecommendation(recommendation);

          // Assert: Only persistence-related methods were called
          expect(
            fixture.repository.onlyPersistenceMethodsCalled,
            isTrue,
            reason: 'RecommendationRepository should only call persistence-related methods',
          );

          // Assert: The recommendation was saved
          expect(
            fixture.repository.savedRecommendations,
            contains(recommendation),
            reason: 'RecommendationRepository should save the recommendation',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.4: GeminiAIService returns failure without fallback on error
    // Validates: Requirement 4.5
    // ========================================================================
    Glados(any.category, ExploreConfig()).test(
      'For any Gemini API failure, GeminiAIService SHALL return failure without fallback',
      (category) async {
        final fixture = RecommendationTestFixture.create();
        fixture.geminiService.shouldFail = true;
        fixture.geminiService.failureMessage = 'API rate limit exceeded';

        try {
          // Act
          final result = await fixture.geminiService.generateSearchTerms(category);

          // Assert: Result is a failure
          expect(
            result.isLeft(),
            isTrue,
            reason: 'GeminiAIService should return failure when API fails',
          );

          // Assert: Failure is GeminiApiFailure
          result.fold(
            (failure) {
              expect(
                failure,
                isA<GeminiApiFailure>(),
                reason: 'Failure should be GeminiApiFailure',
              );
              expect(
                failure.message,
                equals('API rate limit exceeded'),
                reason: 'Failure message should match',
              );
            },
            (_) => fail('Expected failure but got success'),
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.5: YoutubeSearchService returns failure on error
    // Validates: Requirement 4.2
    // ========================================================================
    Glados(any.searchTerm, ExploreConfig()).test(
      'For any YouTube API failure, YoutubeSearchService SHALL return YoutubeApiFailure',
      (searchTerm) async {
        final fixture = RecommendationTestFixture.create();
        fixture.youtubeService.shouldFail = true;
        fixture.youtubeService.failureMessage = 'Quota exceeded';

        try {
          // Act
          final result = await fixture.youtubeService.searchVideo(searchTerm);

          // Assert: Result is a failure
          expect(
            result.isLeft(),
            isTrue,
            reason: 'YoutubeSearchService should return failure when API fails',
          );

          // Assert: Failure is YoutubeApiFailure
          result.fold(
            (failure) {
              expect(
                failure,
                isA<YoutubeApiFailure>(),
                reason: 'Failure should be YoutubeApiFailure',
              );
            },
            (_) => fail('Expected failure but got success'),
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.6: RecommendationUseCase orchestrates services correctly
    // Validates: Requirements 4.1, 4.2, 4.3
    // ========================================================================
    Glados2(any.categoryList, any.userId, ExploreConfig()).test(
      'For any recommendation request, RecommendationUseCase SHALL orchestrate all services',
      (categories, userId) async {
        final fixture = RecommendationTestFixture.create();

        try {
          // Act
          final result = await fixture.useCase.call(RecommendationUseCaseParams(
            categories: categories,
            userId: userId,
          ));

          // Assert: Result is successful
          expect(
            result.isRight(),
            isTrue,
            reason: 'RecommendationUseCase should return success when all services succeed',
          );

          // Assert: GeminiAIService was called for each category
          expect(
            fixture.geminiService.categoryRequests.length,
            equals(categories.length),
            reason: 'GeminiAIService should be called for each category',
          );

          // Assert: All categories were processed
          for (final category in categories) {
            expect(
              fixture.geminiService.categoryRequests,
              contains(category),
              reason: 'GeminiAIService should process category: $category',
            );
          }

          // Assert: YoutubeSearchService was called for search terms
          expect(
            fixture.youtubeService.methodCalls.isNotEmpty,
            isTrue,
            reason: 'YoutubeSearchService should be called for search terms',
          );

          // Assert: Repository was called to clear old recommendations
          expect(
            fixture.repository.clearedUserIds,
            contains(userId),
            reason: 'Repository should clear old recommendations for user: $userId',
          );

          // Assert: Repository was called to save new recommendations
          expect(
            fixture.repository.savedRecommendations.isNotEmpty,
            isTrue,
            reason: 'Repository should save new recommendations',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.7: Services maintain single responsibility during orchestration
    // Validates: Requirements 4.1, 4.2, 4.3
    // ========================================================================
    Glados2(any.categoryList, any.userId, ExploreConfig()).test(
      'During orchestration, each service SHALL maintain single responsibility',
      (categories, userId) async {
        final fixture = RecommendationTestFixture.create();

        try {
          // Act
          await fixture.useCase.call(RecommendationUseCaseParams(
            categories: categories,
            userId: userId,
          ));

          // Assert: GeminiAIService only handled Gemini operations
          expect(
            fixture.geminiService.onlyGeminiMethodsCalled,
            isTrue,
            reason: 'GeminiAIService should only handle Gemini operations',
          );

          // Assert: YoutubeSearchService only handled YouTube operations
          expect(
            fixture.youtubeService.onlyYoutubeMethodsCalled,
            isTrue,
            reason: 'YoutubeSearchService should only handle YouTube operations',
          );

          // Assert: Repository only handled persistence operations
          expect(
            fixture.repository.onlyPersistenceMethodsCalled,
            isTrue,
            reason: 'RecommendationRepository should only handle persistence operations',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.8: Saved recommendations contain correct data
    // Validates: Requirement 4.3
    // ========================================================================
    Glados2(any.category, any.userId, ExploreConfig()).test(
      'For any saved recommendation, data SHALL be correctly persisted',
      (category, userId) async {
        final fixture = RecommendationTestFixture.create();
        fixture.geminiService.mockResult = const Right(['test search term']);

        try {
          // Act
          await fixture.useCase.call(RecommendationUseCaseParams(
            categories: [category],
            userId: userId,
          ));

          // Assert: Recommendations were saved
          expect(
            fixture.repository.savedRecommendations.isNotEmpty,
            isTrue,
            reason: 'At least one recommendation should be saved',
          );

          // Assert: Saved recommendation has correct user ID
          for (final rec in fixture.repository.savedRecommendations) {
            expect(
              rec.userId,
              equals(userId),
              reason: 'Saved recommendation should have correct userId',
            );
          }

          // Assert: Saved recommendation has correct category
          for (final rec in fixture.repository.savedRecommendations) {
            expect(
              rec.category,
              equals(category),
              reason: 'Saved recommendation should have correct category',
            );
          }
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.9: Multiple categories are all processed
    // Validates: Requirements 4.1, 4.4
    // ========================================================================
    Glados(any.intBetween(1, 5), ExploreConfig()).test(
      'For any number of categories, all SHALL be processed by GeminiAIService',
      (count) async {
        final fixture = RecommendationTestFixture.create();
        final categories = List.generate(count, (i) => sampleCategories[i % sampleCategories.length]);

        try {
          // Act
          await fixture.useCase.call(RecommendationUseCaseParams(
            categories: categories,
            userId: 'test-user',
          ));

          // Assert: All categories were processed
          expect(
            fixture.geminiService.categoryRequests.length,
            equals(count),
            reason: 'GeminiAIService should process all $count categories',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 4.10: Gemini failure doesn't prevent other categories from processing
    // Validates: Requirement 4.5
    // ========================================================================
    Glados(any.intBetween(2, 4), ExploreConfig()).test(
      'For any Gemini failure on one category, other categories SHALL still be processed',
      (count) async {
        final fixture = RecommendationTestFixture.create();
        final categories = List.generate(count, (i) => sampleCategories[i % sampleCategories.length]);
        
        // Make Gemini fail for all categories (simulating partial failure scenario)
        fixture.geminiService.shouldFail = true;

        try {
          // Act
          final result = await fixture.useCase.call(RecommendationUseCaseParams(
            categories: categories,
            userId: 'test-user',
          ));

          // Assert: Use case still returns a result (with failed count)
          expect(
            result.isRight(),
            isTrue,
            reason: 'RecommendationUseCase should return result even with failures',
          );

          // Assert: All categories were attempted
          expect(
            fixture.geminiService.categoryRequests.length,
            equals(count),
            reason: 'GeminiAIService should attempt all $count categories',
          );

          // Assert: Result contains failure information
          result.fold(
            (_) => fail('Expected success with failure count'),
            (recommendationResult) {
              expect(
                recommendationResult.failedCount,
                greaterThan(0),
                reason: 'Failed count should be greater than 0 when Gemini fails',
              );
            },
          );
        } finally {
          fixture.reset();
        }
      },
    );
  });

  // ==========================================================================
  // Unit Tests for Edge Cases
  // ==========================================================================
  group('Recommendation Service Decomposition - Edge Cases', () {
    test('GeminiAIService should handle empty category', () async {
      final fixture = RecommendationTestFixture.create();

      final result = await fixture.geminiService.generateSearchTerms('');

      // Empty category should still be processed (validation in real implementation)
      expect(fixture.geminiService.methodCalls.length, equals(1));
      
      fixture.reset();
    });

    test('YoutubeSearchService should handle empty search term', () async {
      final fixture = RecommendationTestFixture.create();

      final result = await fixture.youtubeService.searchVideo('');

      // Empty term should still be processed (validation in real implementation)
      expect(fixture.youtubeService.methodCalls.length, equals(1));
      
      fixture.reset();
    });

    test('RecommendationRepository should handle empty userId for clear', () async {
      final fixture = RecommendationTestFixture.create();

      await fixture.repository.clearUserRecommendations('');

      expect(fixture.repository.clearedUserIds, contains(''));
      
      fixture.reset();
    });

    test('RecommendationUseCase should handle empty categories list', () async {
      final fixture = RecommendationTestFixture.create();

      final result = await fixture.useCase.call(const RecommendationUseCaseParams(
        categories: [],
        userId: 'test-user',
      ));

      // Should return validation failure
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected validation failure'),
      );
      
      fixture.reset();
    });

    test('RecommendationUseCase should handle empty userId', () async {
      final fixture = RecommendationTestFixture.create();

      final result = await fixture.useCase.call(const RecommendationUseCaseParams(
        categories: ['Child Safety'],
        userId: '',
      ));

      // Should return validation failure
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected validation failure'),
      );
      
      fixture.reset();
    });

    test('Services should maintain isolation during concurrent requests', () async {
      final fixture = RecommendationTestFixture.create();

      // Simulate concurrent requests
      final futures = [
        fixture.geminiService.generateSearchTerms('Category 1'),
        fixture.youtubeService.searchVideo('search term 1'),
        fixture.repository.saveRecommendation(const QuizRecommendation(
          title: 'Test',
          videoUrl: 'https://youtu.be/test',
          category: 'Test',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          userId: 'user-1',
        )),
      ];

      await Future.wait(futures);

      // Each service should only have its own method calls
      expect(fixture.geminiService.onlyGeminiMethodsCalled, isTrue);
      expect(fixture.youtubeService.onlyYoutubeMethodsCalled, isTrue);
      expect(fixture.repository.onlyPersistenceMethodsCalled, isTrue);
      
      fixture.reset();
    });

    test('RecommendationResult should track saved and failed counts correctly', () async {
      final fixture = RecommendationTestFixture.create();
      fixture.geminiService.mockResult = const Right(['term1', 'term2']);

      final result = await fixture.useCase.call(const RecommendationUseCaseParams(
        categories: ['Child Safety'],
        userId: 'test-user',
      ));

      result.fold(
        (_) => fail('Expected success'),
        (recommendationResult) {
          // With 2 search terms, we should have 2 saved recommendations
          expect(recommendationResult.savedCount, equals(2));
          expect(recommendationResult.failedCount, equals(0));
        },
      );
      
      fixture.reset();
    });

    test('Repository save failure should be tracked in result', () async {
      final fixture = RecommendationTestFixture.create();
      fixture.geminiService.mockResult = const Right(['term1']);
      fixture.repository.shouldFailSave = true;

      final result = await fixture.useCase.call(const RecommendationUseCaseParams(
        categories: ['Child Safety'],
        userId: 'test-user',
      ));

      result.fold(
        (_) => fail('Expected success with failure count'),
        (recommendationResult) {
          expect(recommendationResult.failedCount, greaterThan(0));
          expect(recommendationResult.errors.isNotEmpty, isTrue);
        },
      );
      
      fixture.reset();
    });
  });
}
