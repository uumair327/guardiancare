import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:guardiancare/src/constants/keys.dart';
import 'package:guardiancare/src/api/youtube/services/youtube_service.dart';

class RecommendationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final YoutubeService _youtubeService = YoutubeService();

  /// Generate recommendations based on quiz categories using Gemini AI and YouTube API
  static Future<void> generateRecommendations(List<String> categories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in, cannot generate recommendations');
      return;
    }

    try {
      print('Starting recommendation generation for categories: $categories');
      
      // Initialize Gemini with v1 API (flutter_gemini 3.0.0)
      Gemini.init(apiKey: kGeminiApiKey);
      final gemini = Gemini.instance;

      // Clear existing recommendations for this user
      print('Clearing old recommendations for user: ${user.uid}');
      final existingDocs = await _firestore
          .collection('recommendations')
          .where('UID', isEqualTo: user.uid)
          .get();

      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }
      print('Cleared ${existingDocs.docs.length} old recommendations');

      // Process each category
      for (String category in categories) {
        print('Processing category: $category');
        
        try {
          // Use Gemini to generate YouTube search terms
          print('Calling Gemini API for category: $category');
          final response = await gemini.text(
            "Summarize the subtopics under the main topic '$category' for child safety and parenting into a single search term for YouTube. The term should effectively encompass the topic, consisting of 4-5 words, to yield highly relevant and accurate search results. Only provide 2 YouTube search terms, each separated by a new line, and nothing else. Search terms must not be in bullet point format. The search term should be highly relevant with child safety, parenting, and $category!",
          );
          print('Gemini API response received');

          if (response != null && response.output != null) {
            List<String> searchTerms = response.output!
                .split('\n')
                .where((term) => term.trim().isNotEmpty)
                .toList();
            
            print('Gemini generated ${searchTerms.length} search terms for $category: $searchTerms');

            // Fetch and save videos for each search term
            for (String term in searchTerms) {
              if (term.isEmpty || term.startsWith('-')) continue;

              print('Fetching YouTube video for term: $term');
              final videoData = await _youtubeService.fetchVideo(term);

              if (videoData != null) {
                final snippet = videoData['snippet'];
                final videoId = videoData['id']['videoId'];

                await _firestore.collection('recommendations').add({
                  'title': snippet['title'],
                  'video': "https://youtu.be/$videoId",
                  'category': category,
                  'thumbnail': snippet['thumbnails']['high']['url'],
                  'timestamp': FieldValue.serverTimestamp(),
                  'UID': user.uid,
                });
                
                print('Saved recommendation: ${snippet['title']}');
              } else {
                print('No video data returned for term: $term');
              }
            }
          } else {
            print('Empty response from Gemini API for category: $category');
          }
        } catch (e) {
          print('Error processing category $category: $e');
          // Continue with next category even if one fails
        }
      }

      print('Successfully generated recommendations for ${categories.length} categories');
    } catch (e) {
      print('Error generating recommendations: $e');
    }
  }

  /// Generate default recommendations if no quiz taken
  static Future<void> generateDefaultRecommendations() async {
    await generateRecommendations(['safety', 'health', 'education']);
  }
}
