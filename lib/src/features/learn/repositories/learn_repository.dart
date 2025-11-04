import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/video_validation_service.dart';

abstract class LearnRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<VideoModel>> getVideosByCategory(String category);
}

class FirebaseLearnRepository implements LearnRepository {
  final FirebaseFirestore _firestore;
  
  FirebaseLearnRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final QuerySnapshot thumbnails = await _firestore
          .collection('learn')
          .get()
          .timeout(const Duration(seconds: 10));

      final List<CategoryModel> categories = [];
      for (var doc in thumbnails.docs) {
        try {
          final category = CategoryModel.fromFirestore(doc);
          categories.add(category);
        } catch (e) {
          print('LearnRepository: Error processing category ${doc.id}: $e');
        }
      }

      // Use validation service to filter valid categories
      final validCategories = VideoValidationService.filterValidCategories(categories);
      print('LearnRepository: Filtered ${categories.length} to ${validCategories.length} valid categories');
      
      return validCategories;
    } catch (e) {
      throw Exception('Failed to load categories: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      // Try exact match first
      QuerySnapshot videosSnapshot = await _firestore
          .collection('videos')
          .where('category', isEqualTo: category)
          .get()
          .timeout(const Duration(seconds: 15));

      List<QueryDocumentSnapshot> videosDocs = videosSnapshot.docs;

      // If no exact match, try case-insensitive search
      if (videosDocs.isEmpty) {
        QuerySnapshot allVideos = await _firestore
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
          videos.add(video);
        } catch (e) {
          print('LearnRepository: Error processing video ${doc.id}: $e');
        }
      }

      // Use validation service to filter valid videos
      final validVideos = VideoValidationService.filterValidVideos(videos);
      print('LearnRepository: Filtered ${videos.length} to ${validVideos.length} valid videos');
      
      return validVideos;
    } catch (e) {
      throw Exception('Failed to load videos: ${e.toString()}');
    }
  }
}