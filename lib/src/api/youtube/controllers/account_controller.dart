import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/api/youtube/repositories/recommendations_repository.dart';
import 'package:guardiancare/src/api/youtube/services/youtube_service.dart';

class AccountController {
  final YoutubeService _youtubeService = YoutubeService();
  final RecommendationsRepository _recommendationsRepository;

  AccountController()
      : _recommendationsRepository = RecommendationsRepository(
          FirebaseFirestore.instance,
          FirebaseAuth.instance.currentUser,
        );

  Future<void> fetchAndSaveVideos(List<String> searchTerms) async {
    for (String term in searchTerms) {
      final videoData = await _youtubeService.fetchVideo(term);
      if (videoData != null) {
        await _recommendationsRepository.saveRecommendation(videoData, term);
      }
    }
  }
}
