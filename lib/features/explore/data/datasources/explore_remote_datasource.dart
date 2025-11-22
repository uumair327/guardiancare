import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/explore/data/models/resource_model.dart';
import 'package:guardiancare/features/explore/data/models/video_model.dart';

/// Remote data source for explore operations
abstract class ExploreRemoteDataSource {
  /// Get recommended videos for a user
  Stream<List<VideoModel>> getRecommendedVideos(String uid);

  /// Get recommended resources
  Stream<List<ResourceModel>> getRecommendedResources();

  /// Search resources by query
  Future<List<ResourceModel>> searchResources(String query);
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final FirebaseFirestore firestore;

  ExploreRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<VideoModel>> getRecommendedVideos(String uid) {
    return firestore
        .collection('recommendations')
        .where('UID', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(8)
        .snapshots()
        .map((snapshot) {
      List<VideoModel> videos = [];

      for (var doc in snapshot.docs) {
        try {
          final video = VideoModel.fromFirestore(doc.data());
          if (video.isValid) {
            videos.add(video);
          }
        } catch (e) {
          print('ExploreDataSource: Error processing video ${doc.id}: $e');
        }
      }

      return videos;
    });
  }

  @override
  Stream<List<ResourceModel>> getRecommendedResources() {
    return firestore
        .collection('resources')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      List<ResourceModel> resources = [];

      for (var doc in snapshot.docs) {
        try {
          final resource = ResourceModel.fromFirestore(doc.data());
          if (resource.isValid) {
            resources.add(resource);
          }
        } catch (e) {
          print('ExploreDataSource: Error processing resource ${doc.id}: $e');
        }
      }

      return resources;
    });
  }

  @override
  Future<List<ResourceModel>> searchResources(String query) async {
    try {
      final queryLower = query.toLowerCase();

      // Get all resources and filter client-side
      // Note: Firestore doesn't support full-text search natively
      final snapshot = await firestore
          .collection('resources')
          .orderBy('timestamp', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      List<ResourceModel> resources = [];

      for (var doc in snapshot.docs) {
        try {
          final resource = ResourceModel.fromFirestore(doc.data());

          // Search in title and type
          if (resource.isValid &&
              (resource.title.toLowerCase().contains(queryLower) ||
                  resource.type.toLowerCase().contains(queryLower))) {
            resources.add(resource);
          }
        } catch (e) {
          print('ExploreDataSource: Error processing resource ${doc.id}: $e');
        }
      }

      return resources;
    } catch (e) {
      throw ServerException('Failed to search resources: ${e.toString()}');
    }
  }
}
