import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';
import 'package:guardiancare/features/learn/domain/repositories/learn_repository.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_categories.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_by_category.dart';
import 'package:guardiancare/features/learn/domain/usecases/get_videos_stream.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_bloc.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_event.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_state.dart';

/// **Feature: srp-clean-architecture-fix, Property 3: Learn Business Logic Delegation**
/// **Validates: Requirements 3.1, 3.2**
///
/// Property: For any video category request or video list request, the VideoPage
/// SHALL dispatch events to LearnBloc, and the LearnBloc SHALL fetch data through
/// LearnRepository without direct Firestore access in the page.

// ============================================================================
// Mock Implementations for Testing
// ============================================================================

/// Mock LearnRepository that tracks all method calls
class MockLearnRepository implements LearnRepository {
  final List<String> methodCalls = [];
  final List<String> categoryRequests = [];
  
  Either<Failure, List<CategoryEntity>> categoriesResult = const Right([]);
  Either<Failure, List<VideoEntity>> videosResult = const Right([]);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    methodCalls.add('getCategories');
    return categoriesResult;
  }

  @override
  Future<Either<Failure, List<VideoEntity>>> getVideosByCategory(String category) async {
    methodCalls.add('getVideosByCategory:$category');
    categoryRequests.add(category);
    return videosResult;
  }

  @override
  Stream<Either<Failure, List<VideoEntity>>> getVideosByCategoryStream(String category) {
    methodCalls.add('getVideosByCategoryStream:$category');
    return Stream.value(videosResult);
  }
}

/// Mock GetCategories use case that tracks calls
class MockGetCategories extends GetCategories {

  MockGetCategories() : super(MockLearnRepository());
  final List<NoParams> calls = [];
  Either<Failure, List<CategoryEntity>> mockResult = const Right([]);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    calls.add(params);
    return mockResult;
  }
}

/// Mock GetVideosByCategory use case that tracks calls
class MockGetVideosByCategory extends GetVideosByCategory {

  MockGetVideosByCategory() : super(MockLearnRepository());
  final List<String> calls = [];
  Either<Failure, List<VideoEntity>> mockResult = const Right([]);

  @override
  Future<Either<Failure, List<VideoEntity>>> call(String category) async {
    calls.add(category);
    return mockResult;
  }
}

/// Mock GetVideosStream use case
class MockGetVideosStream extends GetVideosStream {
  MockGetVideosStream() : super(MockLearnRepository());

  @override
  Stream<Either<Failure, List<VideoEntity>>> call(String category) {
    return Stream.value(const Right([]));
  }
}

// ============================================================================
// Test Fixture
// ============================================================================

class LearnTestFixture {

  LearnTestFixture._({
    required this.getCategories,
    required this.getVideosByCategory,
    required this.getVideosStream,
    required this.bloc,
  });

  factory LearnTestFixture.create() {
    final getCategories = MockGetCategories();
    final getVideosByCategory = MockGetVideosByCategory();
    final getVideosStream = MockGetVideosStream();
    final bloc = LearnBloc(
      getCategories: getCategories,
      getVideosByCategory: getVideosByCategory,
      getVideosStream: getVideosStream,
    );
    return LearnTestFixture._(
      getCategories: getCategories,
      getVideosByCategory: getVideosByCategory,
      getVideosStream: getVideosStream,
      bloc: bloc,
    );
  }
  final MockGetCategories getCategories;
  final MockGetVideosByCategory getVideosByCategory;
  final MockGetVideosStream getVideosStream;
  final LearnBloc bloc;

  void dispose() {
    bloc.close();
  }
}

// ============================================================================
// Custom Generators for Glados
// ============================================================================

/// Sample category names for testing
final sampleCategoryNames = [
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

/// Extension to add custom generators for learn testing
extension LearnGenerators on Any {
  /// Generator for category names
  Generator<String> get categoryName => choose(sampleCategoryNames);

  /// Generator for non-empty category name lists
  Generator<List<String>> get categoryNameList => nonEmptyList(categoryName);

  /// Generator for positive integers between min and max (inclusive)
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }

  /// Generator for CategoryEntity
  Generator<CategoryEntity> get categoryEntity {
    return combine2(
      categoryName,
      choose(['https://example.com/thumb1.jpg', 'https://example.com/thumb2.jpg', 'https://example.com/thumb3.jpg']),
      (name, thumbnail) => CategoryEntity(name: name, thumbnail: thumbnail),
    );
  }

  /// Generator for list of CategoryEntity
  Generator<List<CategoryEntity>> get categoryEntityList => nonEmptyList(categoryEntity);

  /// Generator for VideoEntity
  Generator<VideoEntity> get videoEntity {
    return combine5(
      choose(['video1', 'video2', 'video3', 'video4', 'video5']),
      choose(['Video Title 1', 'Video Title 2', 'Video Title 3']),
      choose(['https://youtube.com/watch?v=abc', 'https://youtube.com/watch?v=def']),
      choose(['https://img.youtube.com/vi/abc/0.jpg', 'https://img.youtube.com/vi/def/0.jpg']),
      categoryName,
      (id, title, videoUrl, thumbnailUrl, category) => VideoEntity(
        id: id,
        title: title,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        category: category,
      ),
    );
  }

  /// Generator for list of VideoEntity
  Generator<List<VideoEntity>> get videoEntityList => nonEmptyList(videoEntity);
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  group('Property 3: Learn Business Logic Delegation', () {
    // ========================================================================
    // Property 3.1: Category requests are delegated to GetCategories use case
    // Validates: Requirement 3.1
    // ========================================================================
    Glados(any.intBetween(1, 5), ExploreConfig()).test(
      'For any CategoriesRequested event, LearnBloc SHALL delegate to GetCategories use case',
      (count) async {
        final fixture = LearnTestFixture.create();
        fixture.getCategories.mockResult = const Right([
          CategoryEntity(name: 'Test Category', thumbnail: 'https://example.com/thumb.jpg'),
        ]);

        try {
          // Act - dispatch CategoriesRequested event 'count' times
          for (var i = 0; i < count; i++) {
            fixture.bloc.add(CategoriesRequested());
            await Future.delayed(const Duration(milliseconds: 50));
          }

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: GetCategories use case was called for each request
          expect(
            fixture.getCategories.calls.length,
            equals(count),
            reason: 'GetCategories use case should be called $count times',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.2: Video requests are delegated to GetVideosByCategory use case
    // Validates: Requirement 3.2
    // ========================================================================
    Glados(any.categoryName, ExploreConfig()).test(
      'For any VideosRequested event, LearnBloc SHALL delegate to GetVideosByCategory use case',
      (categoryName) async {
        final fixture = LearnTestFixture.create();
        fixture.getVideosByCategory.mockResult = Right([
          VideoEntity(
            id: 'test-video',
            title: 'Test Video',
            videoUrl: 'https://youtube.com/watch?v=test',
            thumbnailUrl: 'https://img.youtube.com/vi/test/0.jpg',
            category: categoryName,
          ),
        ]);

        try {
          // Act
          fixture.bloc.add(VideosRequested(categoryName));

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: GetVideosByCategory use case was called with correct category
          expect(
            fixture.getVideosByCategory.calls.length,
            equals(1),
            reason: 'GetVideosByCategory use case should be called once',
          );
          expect(
            fixture.getVideosByCategory.calls.first,
            equals(categoryName),
            reason: 'GetVideosByCategory should be called with category: $categoryName',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.3: Successful category fetch emits CategoriesLoaded state
    // Validates: Requirement 3.1
    // ========================================================================
    Glados(any.categoryEntityList, ExploreConfig()).test(
      'For any successful category fetch, LearnBloc SHALL emit CategoriesLoaded state',
      (categories) async {
        final fixture = LearnTestFixture.create();
        fixture.getCategories.mockResult = Right(categories);

        try {
          final states = <LearnState>[];
          final subscription = fixture.bloc.stream.listen(states.add);

          // Act
          fixture.bloc.add(CategoriesRequested());

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: CategoriesLoaded state was emitted
          expect(
            states.any((s) => s is CategoriesLoaded),
            isTrue,
            reason: 'CategoriesLoaded state should be emitted on success',
          );

          // Assert: Categories match
          final loadedState = states.whereType<CategoriesLoaded>().first;
          expect(
            loadedState.categories.length,
            equals(categories.length),
            reason: 'Loaded categories count should match',
          );

          await subscription.cancel();
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.4: Successful video fetch emits VideosLoaded state
    // Validates: Requirement 3.2
    // ========================================================================
    Glados2(any.categoryName, any.videoEntityList, ExploreConfig()).test(
      'For any successful video fetch, LearnBloc SHALL emit VideosLoaded state',
      (categoryName, videos) async {
        final fixture = LearnTestFixture.create();
        fixture.getVideosByCategory.mockResult = Right(videos);

        try {
          final states = <LearnState>[];
          final subscription = fixture.bloc.stream.listen(states.add);

          // Act
          fixture.bloc.add(VideosRequested(categoryName));

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: VideosLoaded state was emitted
          expect(
            states.any((s) => s is VideosLoaded),
            isTrue,
            reason: 'VideosLoaded state should be emitted on success',
          );

          // Assert: Videos and category match
          final loadedState = states.whereType<VideosLoaded>().first;
          expect(
            loadedState.categoryName,
            equals(categoryName),
            reason: 'Category name should match',
          );
          expect(
            loadedState.videos.length,
            equals(videos.length),
            reason: 'Loaded videos count should match',
          );

          await subscription.cancel();
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.5: Failed category fetch emits LearnError state
    // Validates: Requirement 3.1
    // ========================================================================
    Glados(any.intBetween(1, 3), ExploreConfig()).test(
      'For any failed category fetch, LearnBloc SHALL emit LearnError state',
      (count) async {
        final fixture = LearnTestFixture.create();
        fixture.getCategories.mockResult = const Left(ServerFailure('Test failure'));

        try {
          // Act
          fixture.bloc.add(CategoriesRequested());

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: LearnError state was emitted
          expect(
            fixture.bloc.state,
            isA<LearnError>(),
            reason: 'LearnError state should be emitted on failure',
          );

          final errorState = fixture.bloc.state as LearnError;
          expect(
            errorState.message,
            equals('Test failure'),
            reason: 'Error message should match',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.6: Failed video fetch emits LearnError state
    // Validates: Requirement 3.2
    // ========================================================================
    Glados(any.categoryName, ExploreConfig()).test(
      'For any failed video fetch, LearnBloc SHALL emit LearnError state',
      (categoryName) async {
        final fixture = LearnTestFixture.create();
        fixture.getVideosByCategory.mockResult = const Left(ServerFailure('Video fetch failed'));

        try {
          // Act
          fixture.bloc.add(VideosRequested(categoryName));

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: LearnError state was emitted
          expect(
            fixture.bloc.state,
            isA<LearnError>(),
            reason: 'LearnError state should be emitted on failure',
          );

          final errorState = fixture.bloc.state as LearnError;
          expect(
            errorState.message,
            equals('Video fetch failed'),
            reason: 'Error message should match',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.7: CategorySelected triggers VideosRequested
    // Validates: Requirement 3.2
    // ========================================================================
    Glados(any.categoryName, ExploreConfig()).test(
      'For any CategorySelected event, LearnBloc SHALL trigger video loading',
      (categoryName) async {
        final fixture = LearnTestFixture.create();
        fixture.getVideosByCategory.mockResult = const Right([]);

        try {
          // Act
          fixture.bloc.add(CategorySelected(categoryName));

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: GetVideosByCategory was called
          expect(
            fixture.getVideosByCategory.calls.length,
            equals(1),
            reason: 'GetVideosByCategory should be called when category is selected',
          );
          expect(
            fixture.getVideosByCategory.calls.first,
            equals(categoryName),
            reason: 'GetVideosByCategory should be called with selected category',
          );
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.8: Multiple category requests are all delegated
    // Validates: Requirement 3.1
    // ========================================================================
    Glados(any.intBetween(1, 5), ExploreConfig()).test(
      'For any sequence of category selections, all SHALL be delegated to use case',
      (count) async {
        final fixture = LearnTestFixture.create();
        fixture.getVideosByCategory.mockResult = const Right([]);

        // Generate categories based on count
        final categories = List.generate(count, (i) => sampleCategoryNames[i % sampleCategoryNames.length]);

        try {
          // Act - select each category
          for (final category in categories) {
            fixture.bloc.add(CategorySelected(category));
          }

          // Wait for all events to be processed
          await Future.delayed(Duration(milliseconds: 50 + (count * 30)));

          // Assert: All category selections were delegated
          expect(
            fixture.getVideosByCategory.calls.length,
            equals(categories.length),
            reason: 'All ${categories.length} category selections should be delegated',
          );

          // Assert: Each category was requested
          for (int i = 0; i < categories.length; i++) {
            expect(
              fixture.getVideosByCategory.calls[i],
              equals(categories[i]),
              reason: 'Category at index $i should match',
            );
          }
        } finally {
          fixture.dispose();
        }
      },
    );

    // ========================================================================
    // Property 3.9: BackToCategories triggers category reload
    // Validates: Requirement 3.1
    // ========================================================================
    Glados(any.intBetween(1, 3), ExploreConfig()).test(
      'For any BackToCategories event, LearnBloc SHALL reload categories',
      (count) async {
        final fixture = LearnTestFixture.create();
        fixture.getCategories.mockResult = const Right([]);

        try {
          // Act - go back to categories 'count' times
          for (var i = 0; i < count; i++) {
            fixture.bloc.add(BackToCategories());
            await Future.delayed(const Duration(milliseconds: 50));
          }

          await Future.delayed(const Duration(milliseconds: 100));

          // Assert: GetCategories was called for each back navigation
          expect(
            fixture.getCategories.calls.length,
            equals(count),
            reason: 'GetCategories should be called $count times for back navigation',
          );
        } finally {
          fixture.dispose();
        }
      },
    );
  });

  // ==========================================================================
  // Unit Tests for Edge Cases
  // ==========================================================================
  group('Learn Business Logic Delegation - Edge Cases', () {
    test('LearnBloc should handle empty category list', () async {
      final fixture = LearnTestFixture.create();
      fixture.getCategories.mockResult = const Right([]);

      try {
        fixture.bloc.add(CategoriesRequested());

        await Future.delayed(const Duration(milliseconds: 100));

        expect(fixture.bloc.state, isA<CategoriesLoaded>());
        final state = fixture.bloc.state as CategoriesLoaded;
        expect(state.categories, isEmpty);
      } finally {
        fixture.dispose();
      }
    });

    test('LearnBloc should handle empty video list', () async {
      final fixture = LearnTestFixture.create();
      fixture.getVideosByCategory.mockResult = const Right([]);

      try {
        fixture.bloc.add(const VideosRequested('Test Category'));

        await Future.delayed(const Duration(milliseconds: 100));

        expect(fixture.bloc.state, isA<VideosLoaded>());
        final state = fixture.bloc.state as VideosLoaded;
        expect(state.videos, isEmpty);
        expect(state.categoryName, equals('Test Category'));
      } finally {
        fixture.dispose();
      }
    });

    test('LearnBloc should handle rapid category selections', () async {
      final fixture = LearnTestFixture.create();
      fixture.getVideosByCategory.mockResult = const Right([]);

      try {
        // Rapidly select categories
        final categories = ['Category 1', 'Category 2', 'Category 3'];
        for (final category in categories) {
          fixture.bloc.add(CategorySelected(category));
        }

        await Future.delayed(const Duration(milliseconds: 200));

        // All should be processed
        expect(fixture.getVideosByCategory.calls.length, equals(3));
      } finally {
        fixture.dispose();
      }
    });

    test('LearnBloc should emit loading state before categories loaded', () async {
      final fixture = LearnTestFixture.create();
      fixture.getCategories.mockResult = const Right([]);

      try {
        final states = <LearnState>[];
        final subscription = fixture.bloc.stream.listen(states.add);

        fixture.bloc.add(CategoriesRequested());

        await Future.delayed(const Duration(milliseconds: 100));

        // Should have loading state before loaded state
        expect(states.any((s) => s is LearnLoading), isTrue);
        expect(states.any((s) => s is CategoriesLoaded), isTrue);

        await subscription.cancel();
      } finally {
        fixture.dispose();
      }
    });

    test('LearnBloc should emit VideosLoading state before videos loaded', () async {
      final fixture = LearnTestFixture.create();
      fixture.getVideosByCategory.mockResult = const Right([]);

      try {
        final states = <LearnState>[];
        final subscription = fixture.bloc.stream.listen(states.add);

        fixture.bloc.add(const VideosRequested('Test Category'));

        await Future.delayed(const Duration(milliseconds: 100));

        // Should have loading state before loaded state
        expect(states.any((s) => s is VideosLoading), isTrue);
        expect(states.any((s) => s is VideosLoaded), isTrue);

        await subscription.cancel();
      } finally {
        fixture.dispose();
      }
    });

    test('RetryRequested should reload categories when in error state', () async {
      final fixture = LearnTestFixture.create();
      
      // First, cause an error
      fixture.getCategories.mockResult = const Left(ServerFailure('Initial error'));
      fixture.bloc.add(CategoriesRequested());
      await Future.delayed(const Duration(milliseconds: 100));
      
      expect(fixture.bloc.state, isA<LearnError>());
      
      // Now retry with success
      fixture.getCategories.mockResult = const Right([]);
      fixture.bloc.add(RetryRequested());
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should have called getCategories twice (initial + retry)
      expect(fixture.getCategories.calls.length, equals(2));
      
      fixture.dispose();
    });
  });
}
