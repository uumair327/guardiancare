import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_recommendation_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/recommendation_repository.dart';

/// Model for converting QuizRecommendation to/from Firestore
///
/// This class handles the Firestore-specific serialization/deserialization
/// of QuizRecommendation entities.
class QuizRecommendationModel {
  /// Creates a [QuizRecommendation] from Firestore document
  static QuizRecommendation fromFirestore(DocumentSnapshot doc) {
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
  static Map<String, dynamic> toFirestore(QuizRecommendation recommendation) {
    return {
      'title': recommendation.title,
      'video': recommendation.videoUrl,
      'category': recommendation.category,
      'thumbnail': recommendation.thumbnailUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'UID': recommendation.userId,
    };
  }
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
          .add(QuizRecommendationModel.toFirestore(recommendation));
      
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
          .map((doc) => QuizRecommendationModel.fromFirestore(doc))
          .toList();

      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure('Failed to get recommendations: ${e.toString()}'));
    }
  }
}
