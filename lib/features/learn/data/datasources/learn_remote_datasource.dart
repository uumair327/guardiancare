import 'package:cloud_firestore/cloud_firestore.dart';
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

class LearnRemoteDataSourceImpl implements LearnRemoteDataSource {
  final FirebaseFirestore firestore;

  LearnRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final QuerySnapshot thumbnails = await firestore
          .collection('learn')
          .get()
          .timeout(const Duration(seconds: 10));

      final List<CategoryModel> categories = [];
      for (var doc in thumbnails.docs) {
        try {
          final category = CategoryModel.fromFirestore(doc);
          if (category.isValid) {
            categories.add(category);
          }
        } catch (e) {
          print('LearnDataSource: Error processing category ${doc.id}: $e');
        }
      }

      return categories;
    } catch (e) {
      throw ServerException('Failed to load categories: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      // Try exact match first
      QuerySnapshot videosSnapshot = await firestore
          .collection('videos')
          .where('category', isEqualTo: category)
          .get()
          .timeout(const Duration(seconds: 15));

      List<QueryDocumentSnapshot> videosDocs = videosSnapshot.docs;

      // If no exact match, try case-insensitive search
      if (videosDocs.isEmpty) {
        QuerySnapshot allVideos = await firestore
            .collection('videos')
            .get()
            .timeout(const Duration(seconds: 15));

        videosDocs = allVideos.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final videoCategory = data['category'] as String? ?? '';
          return videoCategory.toLowerCase() == category.toLowerCase();
        }).toList();
      }

      final List<VideoModel> videos = [];
      for (var doc in videosDocs) {
        try {
          final video = VideoModel.fromFirestore(doc);
          if (video.isValid) {
            videos.add(video);
          }
        } catch (e) {
          print('LearnDataSource: Error processing video ${doc.id}: $e');
        }
      }

      return videos;
    } catch (e) {
      throw ServerException('Failed to load videos: ${e.toString()}');
    }
  }

  @override
  Stream<List<VideoModel>> getVideosByCategoryStream(String category) {
    return firestore
        .collection('videos')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      List<VideoModel> videos = [];

      for (var doc in snapshot.docs) {
        try {
          final video = VideoModel.fromFirestore(doc);
          if (video.isValid) {
            videos.add(video);
          }
        } catch (e) {
          print('LearnDataSource: Error processing video ${doc.id}: $e');
        }
      }

      return videos;
    });
  }
}
