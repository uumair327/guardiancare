import 'package:flutter/foundation.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/learn/data/models/category_model.dart';
import 'package:guardiancare/features/learn/data/models/video_model.dart';

/// Remote data source for learn operations
abstract class LearnRemoteDataSource {
  /// Get all learning categories from Firestore
  Future<List<CategoryModel>> getCategories();

  /// Get videos by category from Firestore
  Future<List<VideoModel>> getVideosByCategory(String category);

  /// Get videos by category as a stream for real-time updates
  Stream<List<VideoModel>> getVideosByCategoryStream(String category);
}

/// Implementation of LearnRemoteDataSource using IDataStore abstraction
///
/// Following: DIP (Dependency Inversion Principle)
class LearnRemoteDataSourceImpl implements LearnRemoteDataSource {

  LearnRemoteDataSourceImpl({required IDataStore dataStore})
      : _dataStore = dataStore;
  final IDataStore _dataStore;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final result = await _dataStore.getAll('learn');

      return result.when(
        success: (docs) {
          final List<CategoryModel> categories = [];
          for (final doc in docs) {
            try {
              final category = CategoryModel.fromMap(doc);
              if (category.isValid) {
                categories.add(category);
              }
            } on Object catch (e) {
              debugPrint('LearnDataSource: Error processing category: $e');
            }
          }
          return categories;
        },
        failure: (error) {
          debugPrint(
              'LearnDataSource: Error fetching categories: ${error.message}');
          throw ServerException(ErrorStrings.withDetails(
              ErrorStrings.getCategoriesError, error.message));
        },
      );
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.getCategoriesError, e.toString()));
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      // Try exact match first
      final options = QueryOptions(
        filters: [QueryFilter.equals('category', category)],
      );

      final result = await _dataStore.query('videos', options: options);

      return await result.when(
        success: (docs) async {
          if (docs.isNotEmpty) {
            return _mapVideos(docs);
          }

          // If no exact match, try backend-agnostic "case-insensitive" fallback
          // Note: In a real backend, we'd want a case-insensitive query capability
          // For now, fetching all and filtering (same as previous implementation)
          final allVideosResult = await _dataStore.getAll('videos');

          return allVideosResult.when(
            success: (allDocs) {
              final filteredDocs = allDocs.where((doc) {
                final videoCategory = doc['category'] as String? ?? '';
                return videoCategory.toLowerCase() == category.toLowerCase();
              }).toList();
              return _mapVideos(filteredDocs);
            },
            failure: (error) => [],
          );
        },
        failure: (error) {
          debugPrint(
              'LearnDataSource: Error fetching videos: ${error.message}');
          throw ServerException(ErrorStrings.withDetails(
              ErrorStrings.getVideosByCategoryError, error.message));
        },
      );
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.getVideosByCategoryError, e.toString()));
    }
  }

  @override
  Stream<List<VideoModel>> getVideosByCategoryStream(String category) {
    final options = QueryOptions(
      filters: [QueryFilter.equals('category', category)],
    );

    return _dataStore.streamQuery('videos', options: options).map((result) {
      return result.when(
        success: _mapVideos,
        failure: (error) {
          debugPrint('LearnDataSource: Stream error: ${error.message}');
          return <VideoModel>[];
        },
      );
    });
  }

  List<VideoModel> _mapVideos(List<Map<String, dynamic>> docs) {
    final List<VideoModel> videos = [];
    for (final doc in docs) {
      try {
        final video = VideoModel.fromMap(doc);
        if (video.isValid) {
          videos.add(video);
        }
      } on Object catch (e) {
        debugPrint('LearnDataSource: Error processing video: $e');
      }
    }
    return videos;
  }
}
