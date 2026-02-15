import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_recommendation_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/recommendation_repository.dart';
import 'package:guardiancare/features/quiz/domain/services/gemini_ai_service.dart';
import 'package:guardiancare/features/quiz/domain/services/youtube_search_service.dart';

/// Parameters for the RecommendationUseCase
///
/// Requirements: 4.4
class RecommendationUseCaseParams extends Equatable {
  const RecommendationUseCaseParams({
    required this.categories,
    required this.userId,
  });
  final List<String> categories;
  final String userId;

  @override
  List<Object> get props => [categories, userId];
}

/// Result of the recommendation generation process
class RecommendationResult extends Equatable {
  const RecommendationResult({
    required this.savedCount,
    required this.failedCount,
    this.errors = const [],
  });
  final int savedCount;
  final int failedCount;
  final List<String> errors;

  @override
  List<Object> get props => [savedCount, failedCount, errors];
}

/// Use case that orchestrates recommendation generation
///
/// This use case coordinates between:
/// - [GeminiAIService] for generating search terms
/// - [YoutubeSearchService] for fetching video data
/// - [RecommendationRepository] for persisting recommendations
///
/// It contains no implementation details, only coordination logic.
///
/// Requirements: 4.4
class RecommendationUseCase
    implements UseCase<RecommendationResult, RecommendationUseCaseParams> {
  /// Creates a [RecommendationUseCase]
  ///
  /// All services are injected to maintain single responsibility.
  RecommendationUseCase({
    required GeminiAIService geminiService,
    required YoutubeSearchService youtubeService,
    required RecommendationRepository repository,
  })  : _geminiService = geminiService,
        _youtubeService = youtubeService,
        _repository = repository;
  final GeminiAIService _geminiService;
  final YoutubeSearchService _youtubeService;
  final RecommendationRepository _repository;

  @override
  Future<Either<Failure, RecommendationResult>> call(
      RecommendationUseCaseParams params) async {
    Log.d('========================================');
    Log.d('🎯 RECOMMENDATION USE CASE STARTED');
    Log.d('   Categories: ${params.categories}');
    Log.d('   User ID: ${params.userId}');
    Log.d('========================================');

    if (params.categories.isEmpty) {
      Log.e('❌ Error: Categories list is empty');
      return const Left(ValidationFailure('Categories list cannot be empty'));
    }

    if (params.userId.isEmpty) {
      Log.e('❌ Error: User ID is empty');
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    try {
      // Step 1: Clear existing recommendations for the user
      Log.d('🗑️ Step 1: Clearing old recommendations...');
      final clearResult =
          await _repository.clearUserRecommendations(params.userId);
      clearResult.fold(
        (failure) => Log.w(
            '⚠️ Warning: Failed to clear old recommendations: ${failure.message}'),
        (count) => Log.d('✅ Cleared $count old recommendations'),
      );

      int savedCount = 0;
      int failedCount = 0;
      final errors = <String>[];

      // Step 2: Process each category
      Log.d('🔄 Step 2: Processing ${params.categories.length} categories...');

      for (int i = 0; i < params.categories.length; i++) {
        final category = params.categories[i];
        Log.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Log.d('📂 Category ${i + 1}/${params.categories.length}: $category');
        Log.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // Step 2a: Generate search terms using Gemini AI
        Log.d('🤖 Generating search terms with Gemini AI...');
        final searchTermsResult =
            await _geminiService.generateSearchTerms(category);

        final searchTerms = searchTermsResult.fold(
          (failure) {
            final errorMsg = 'Gemini failed for $category: ${failure.message}';
            Log.e('❌ $errorMsg');
            errors.add(errorMsg);
            return <String>[];
          },
          (terms) {
            Log.d('✅ Generated ${terms.length} search terms: $terms');
            return terms;
          },
        );

        if (searchTerms.isEmpty) {
          Log.w('⚠️ No search terms for category: $category');
          failedCount++;
          continue;
        }

        // Step 2b: Fetch videos for each search term
        Log.d(
            '🎥 Fetching YouTube videos for ${searchTerms.length} search terms...');

        for (int j = 0; j < searchTerms.length; j++) {
          final term = searchTerms[j];
          Log.d('  🔍 Search term ${j + 1}/${searchTerms.length}: "$term"');

          final videoResult = await _youtubeService.searchVideo(term);

          await videoResult.fold(
            (failure) async {
              final errorMsg = 'YouTube failed for "$term": ${failure.message}';
              Log.e('  ❌ $errorMsg');
              errors.add(errorMsg);
              failedCount++;
            },
            (videoData) async {
              Log.d('  ✅ Found video: "${videoData.title}"');

              // Step 2c: Save recommendation to repository
              final recommendation = QuizRecommendation(
                title: videoData.title,
                videoUrl: videoData.videoUrl,
                category: category,
                thumbnailUrl: videoData.thumbnailUrl,
                userId: params.userId,
              );

              Log.d('  💾 Saving to Firestore...');
              final saveResult =
                  await _repository.saveRecommendation(recommendation);
              saveResult.fold(
                (failure) {
                  final errorMsg =
                      'Save failed for "${videoData.title}": ${failure.message}';
                  Log.e('  ❌ $errorMsg');
                  errors.add(errorMsg);
                  failedCount++;
                },
                (docId) {
                  Log.d('  ✅ Saved with ID: $docId');
                  savedCount++;
                },
              );
            },
          );
        }
      }

      Log.d('========================================');
      Log.d('✅ RECOMMENDATION GENERATION COMPLETE');
      Log.d('   Saved: $savedCount');
      Log.d('   Failed: $failedCount');
      if (errors.isNotEmpty) {
        Log.w('   Errors: ${errors.length}');
      }
      Log.d('========================================');

      return Right(RecommendationResult(
        savedCount: savedCount,
        failedCount: failedCount,
        errors: errors,
      ));
    } on Exception catch (e, stackTrace) {
      Log.e('========================================');
      Log.e('❌ FATAL ERROR in RecommendationUseCase');
      Log.e('   Error: $e');
      Log.e('   Stack trace: $stackTrace');
      Log.e('========================================');
      return Left(
          ServerFailure('Recommendation generation failed: ${e.toString()}'));
    }
  }
}
