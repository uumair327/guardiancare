import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/quiz/data/repositories/recommendation_repository.dart';
import 'package:guardiancare/features/quiz/services/gemini_ai_service.dart';
import 'package:guardiancare/features/quiz/services/youtube_search_service.dart';

/// Parameters for the RecommendationUseCase
/// 
/// Requirements: 4.4
class RecommendationUseCaseParams extends Equatable {
  final List<String> categories;
  final String userId;

  const RecommendationUseCaseParams({
    required this.categories,
    required this.userId,
  });

  @override
  List<Object> get props => [categories, userId];
}

/// Result of the recommendation generation process
class RecommendationResult extends Equatable {
  final int savedCount;
  final int failedCount;
  final List<String> errors;

  const RecommendationResult({
    required this.savedCount,
    required this.failedCount,
    this.errors = const [],
  });

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
class RecommendationUseCase implements UseCase<RecommendationResult, RecommendationUseCaseParams> {
  final GeminiAIService _geminiService;
  final YoutubeSearchService _youtubeService;
  final RecommendationRepository _repository;

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

  @override
  Future<Either<Failure, RecommendationResult>> call(RecommendationUseCaseParams params) async {
    if (params.categories.isEmpty) {
      return const Left(ValidationFailure('Categories list cannot be empty'));
    }

    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    try {
      // Step 1: Clear existing recommendations for the user
      final clearResult = await _repository.clearUserRecommendations(params.userId);
      clearResult.fold(
        (failure) => debugPrint('Warning: Failed to clear old recommendations: ${failure.message}'),
        (count) => debugPrint('Cleared $count old recommendations'),
      );

      int savedCount = 0;
      int failedCount = 0;
      final errors = <String>[];

      // Step 2: Process each category
      for (final category in params.categories) {
        // Step 2a: Generate search terms using Gemini AI
        final searchTermsResult = await _geminiService.generateSearchTerms(category);

        final searchTerms = searchTermsResult.fold(
          (failure) {
            errors.add('Gemini failed for $category: ${failure.message}');
            return <String>[];
          },
          (terms) => terms,
        );

        if (searchTerms.isEmpty) {
          failedCount++;
          continue;
        }

        // Step 2b: Fetch videos for each search term
        for (final term in searchTerms) {
          final videoResult = await _youtubeService.searchVideo(term);

          await videoResult.fold(
            (failure) async {
              errors.add('YouTube failed for "$term": ${failure.message}');
              failedCount++;
            },
            (videoData) async {
              // Step 2c: Save recommendation to repository
              final recommendation = QuizRecommendation(
                title: videoData.title,
                videoUrl: videoData.videoUrl,
                category: category,
                thumbnailUrl: videoData.thumbnailUrl,
                userId: params.userId,
              );

              final saveResult = await _repository.saveRecommendation(recommendation);
              saveResult.fold(
                (failure) {
                  errors.add('Save failed for "${videoData.title}": ${failure.message}');
                  failedCount++;
                },
                (_) => savedCount++,
              );
            },
          );
        }
      }

      return Right(RecommendationResult(
        savedCount: savedCount,
        failedCount: failedCount,
        errors: errors,
      ));
    } catch (e) {
      return Left(ServerFailure('Recommendation generation failed: ${e.toString()}'));
    }
  }
}
