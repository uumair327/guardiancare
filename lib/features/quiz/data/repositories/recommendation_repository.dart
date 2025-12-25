import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';

/// Entity representing a video recommendation for quiz results
/// 
/// Named QuizRecommendation to avoid conflict with explore feature's Recommendation
/// 
/// Requirements: 4.3
class QuizRecommendation extends Equatable {
  final String? id;
  final String title;
  final String videoUrl;
  final String category;
  final String thumbnailUrl;
  final DateTime? timestamp;
  final String userId;

  const QuizRecommendation({
    this.id,
    required this.title,
    required this.videoUrl,
    required this.category,
    required this.thumbnailUrl,
    this.timestamp,
    required this.userId,
  });

  /// Creates a [QuizRecommendation] from Firestore document
  factory QuizRecommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizRecommendation(
      id: doc.id,
      title: data['title'] as String? ?? '',
      videoUrl: data['video'] as String? ?? '',
      category: data['category'] as String? ?? '',
      thumbnailUrl: data['thumbnail'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      userId: data['UID'] as String? ?? '',
    );
  }

  /// Converts [QuizRecommendation] to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'video': videoUrl,
      'category': category,
      'thumbnail': thumbnailUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'UID': userId,
    };
  }

  @override
  List<Object?> get props => [id, title, videoUrl, category, thumbnailUrl, timestamp, userId];
}

/// Repository interface for recommendation persistence operations
/// 
/// This repository handles Firestore operations exclusively for recommendations.
/// 
/// Requirements: 4.3
abstract class RecommendationRepository {
  /// Saves a recommendation to Firestore
  /// 
  /// Returns [Either<Failure, String>] containing:
  /// - [Right] with document ID on success
  /// - [Left] with [ServerFailure] on error
  Future<Either<Failure, String>> saveRecommendation(QuizRecommendation recommendation);

  /// Clears all recommendations for a user
  /// 
  /// Returns [Either<Failure, int>] containing:
  /// - [Right] with count of deleted documents on success
  /// - [Left] with [ServerFailure] on error
  Future<Either<Failure, int>> clearUserRecommendations(String userId);

  /// Gets all recommendations for a user
  /// 
  /// Returns [Either<Failure, List<QuizRecommendation>>] containing:
  /// - [Right] with list of recommendations on success
  /// - [Left] with [ServerFailure] on error
  Future<Either<Failure, List<QuizRecommendation>>> getUserRecommendations(String userId);
}

/// Implementation of [RecommendationRepository] using Firestore
class RecommendationRepositoryImpl implements RecommendationRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'recommendations';

  /// Creates a [RecommendationRepositoryImpl]
  /// 
  /// [firestore] - Firestore instance for database operations
  RecommendationRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, String>> saveRecommendation(QuizRecommendation recommendation) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(recommendation.toFirestore());
      
      return Right(docRef.id);
    } catch (e) {
      return Left(ServerFailure('Failed to save recommendation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> clearUserRecommendations(String userId) async {
    if (userId.isEmpty) {
      return const Left(ServerFailure('User ID cannot be empty'));
    }

    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('UID', isEqualTo: userId)
          .get();

      int deletedCount = 0;
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      return Right(deletedCount);
    } catch (e) {
      return Left(ServerFailure('Failed to clear recommendations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<QuizRecommendation>>> getUserRecommendations(String userId) async {
    if (userId.isEmpty) {
      return const Left(ServerFailure('User ID cannot be empty'));
    }

    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('UID', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final recommendations = querySnapshot.docs
          .map((doc) => QuizRecommendation.fromFirestore(doc))
          .toList();

      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure('Failed to get recommendations: ${e.toString()}'));
    }
  }
}
