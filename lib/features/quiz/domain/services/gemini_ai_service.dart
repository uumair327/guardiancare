import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Abstract interface for Gemini AI service operations
///
/// This interface defines the contract for generating search terms
/// using AI. The domain layer depends only on this abstraction,
/// following clean architecture principles where the domain layer
/// has no knowledge of implementation details.
///
/// Implementations of this interface should handle:
/// - API communication with Gemini AI
/// - Response parsing and validation
/// - Error handling and fallback mechanisms
///
/// Requirements: 1.3, 2.2
// ignore: one_member_abstracts
abstract class GeminiAIService {
  /// Generates YouTube search terms for a given category
  ///
  /// Takes a [category] string representing the topic area for which
  /// to generate search terms (e.g., "online safety", "cyberbullying").
  ///
  /// Returns [Either<Failure, List<String>>] containing:
  /// - [Right] with a list of search terms on success
  /// - [Left] with [GeminiApiFailure] on error
  ///
  /// The returned search terms are optimized for YouTube video searches
  /// related to child safety and parenting topics.
  Future<Either<Failure, List<String>>> generateSearchTerms(String category);
}
