import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/quiz/domain/entities/quiz_recommendation_entity.dart';
import 'package:guardiancare/features/quiz/domain/repositories/recommendation_repository.dart';

/// Model for converting QuizRecommendation to/from DataStore
class QuizRecommendationModel {
  QuizRecommendationModel._();

  /// Creates a [QuizRecommendation] from Map
  static QuizRecommendation fromMap(Map<String, dynamic> data) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is DateTime) return val;
      return null;
    }

    return QuizRecommendation(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      videoUrl: data['video'] as String? ?? '',
      category: data['category'] as String? ?? '',
      thumbnailUrl: data['thumbnail'] as String? ?? '',
      timestamp: parseTimestamp(data['timestamp']),
      userId: data['UID'] as String? ?? '',
    );
  }

  /// Converts [QuizRecommendation] to Map
  static Map<String, dynamic> toMap(QuizRecommendation recommendation) {
    return {
      'title': recommendation.title,
      'video': recommendation.videoUrl,
      'category': recommendation.category,
      'thumbnail': recommendation.thumbnailUrl,
      'timestamp': DateTime.now().toIso8601String(),
      'UID': recommendation.userId,
    };
  }
}

/// Implementation of [RecommendationRepository] using IDataStore
class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl({required IDataStore dataStore})
      : _dataStore = dataStore;
  final IDataStore _dataStore;
  static const String _collection = 'recommendations';

  @override
  Future<Either<Failure, String>> saveRecommendation(
      QuizRecommendation recommendation) async {
    try {
      final result = await _dataStore.add(
          _collection, QuizRecommendationModel.toMap(recommendation));

      return result.when(
        success: Right.new,
        failure: (e) => Left(ServerFailure(e.message)),
      );
    } on Object catch (e) {
      return Left(
          ServerFailure('Failed to save recommendation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> clearUserRecommendations(String userId) async {
    if (userId.isEmpty) {
      return const Left(ServerFailure('User ID cannot be empty'));
    }

    try {
      final options =
          QueryOptions(filters: [QueryFilter.equals('UID', userId)]);
      final queryResult = await _dataStore.query(_collection, options: options);

      return await queryResult.when(
        success: (docs) async {
          int deletedCount = 0;
          for (final doc in docs) {
            final id = doc['id'] as String;
            await _dataStore.delete(_collection, id);
            deletedCount++;
          }
          return Right(deletedCount);
        },
        failure: (e) async => Left(ServerFailure(e.message)),
      );
    } on Object catch (e) {
      return Left(
          ServerFailure('Failed to clear recommendations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<QuizRecommendation>>> getUserRecommendations(
      String userId) async {
    if (userId.isEmpty) {
      return const Left(ServerFailure('User ID cannot be empty'));
    }

    try {
      final options = QueryOptions(
        filters: [QueryFilter.equals('UID', userId)],
        orderBy: [const OrderBy('timestamp', descending: true)],
      );

      final result = await _dataStore.query(_collection, options: options);

      return result.when(
        success: (docs) {
          final recommendations =
              docs.map(QuizRecommendationModel.fromMap).toList();
          return Right(recommendations);
        },
        failure: (e) => Left(ServerFailure(e.message)),
      );
    } on Object catch (e) {
      return Left(
          ServerFailure('Failed to get recommendations: ${e.toString()}'));
    }
  }
}
