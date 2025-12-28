import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_recommendation_entity.dart';

/// Abstract interface for recommendation persistence operations
///
/// This interface defines the contract for recommendation data persistence.
/// The domain layer depends only on this abstraction, following clean
/// architecture principles where the domain layer has no knowledge of
/// implementation details such as Firestore or other databases.
///
/// Implementations of this interface should handle:
/// - Saving recommendations to persistent storage
/// - Clearing user recommendations
/// - Retrieving user recommendations
///
/// Requirements: 4.3
abstract class RecommendationRepository {
  /// Saves a recommendation to persistent storage
  ///
  /// Takes a [recommendation] entity to be persisted.
  ///
  /// Returns [Either<Failure, String>] containing:
  /// - [Right] with document/record ID on success
  /// - [Left] with [ServerFailure] on error
  Future<Either<Failure, String>> saveRecommendation(QuizRecommendation recommendation);

  /// Clears all recommendations for a user
  ///
  /// Takes a [userId] identifying the user whose recommendations should be cleared.
  ///
  /// Returns [Either<Failure, int>] containing:
  /// - [Right] with count of deleted records on success
  /// - [Left] with [ServerFailure] on error
  Future<Either<Failure, int>> clearUserRecommendations(String userId);

  /// Gets all recommendations for a user
  ///
  /// Takes a [userId] identifying the user whose recommendations should be retrieved.
  ///
  /// Returns [Either<Failure, List<QuizRecommendation>>] containing:
  /// - [Right] with list of recommendations on success
  /// - [Left] with [ServerFailure] on error
  Future<Either<Failure, List<QuizRecommendation>>> getUserRecommendations(String userId);
}
