import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:guardiancare/core/core.dart';

class RecommendationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final YoutubeService _youtubeService = YoutubeService();

  /// Generate recommendations based on quiz categories using Gemini AI and YouTube API
  static Future<void> generateRecommendations(List<String> categories) async {
    print('========================================');
    print('RECOMMENDATION SERVICE CALLED');
    print('Categories received: $categories');
    print('========================================');
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ ERROR: No user logged in, cannot generate recommendations');
      return;
    }
    
    print('✅ User authenticated: ${user.uid}');
    print('✅ User email: ${user.email}');

    try {
      print('📝 Starting recommendation generation for categories: $categories');
      
      // Initialize Gemini with v1 API (flutter_gemini 3.0.0)
      print('🔧 Initializing Gemini API...');
      print('🔑 API Key (first 10 chars): ${kGeminiApiKey.substring(0, 10)}...');
      
      try {
        Gemini.init(apiKey: kGeminiApiKey);
        print('✅ Gemini initialized successfully');
      } catch (e) {
        print('⚠️ Gemini init error (might be already initialized): $e');
      }
      
      final gemini = Gemini.instance;
      print('✅ Gemini instance obtained');

      // Clear existing recommendations for this user
      print('🗑️ Clearing old recommendations for user: ${user.uid}');
      final existingDocs = await _firestore
          .collection('recommendations')
          .where('UID', isEqualTo: user.uid)
          .get();

      print('📊 Found ${existingDocs.docs.length} existing recommendations');
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
        print('  ❌ Deleted: ${doc.id}');
      }
      print('✅ Cleared ${existingDocs.docs.length} old recommendations');

      // Process each category
      print('\n🔄 Processing ${categories.length} categories...\n');
      
      for (int i = 0; i < categories.length; i++) {
        String category = categories[i];
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📂 Category ${i + 1}/${categories.length}: $category');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        try {
          // Use Gemini to generate YouTube search terms
          List<String> searchTerms = [];
          
          try {
            print('🤖 Calling Gemini API for category: $category');
            final prompt = "Summarize the subtopics under the main topic '$category' for child safety and parenting into a single search term for YouTube. The term should effectively encompass the topic, consisting of 4-5 words, to yield highly relevant and accurate search results. Only provide 2 YouTube search terms, each separated by a new line, and nothing else. Search terms must not be in bullet point format. The search term should be highly relevant with child safety, parenting, and $category!";
            print('📤 Prompt length: ${prompt.length} characters');
            
            final response = await gemini.text(prompt);
            print('📥 Gemini API response received');
            print('📝 Response type: ${response.runtimeType}');
            print('📝 Response output: ${response?.output}');

            if (response != null && response.output != null) {
              searchTerms = response.output!
                  .split('\n')
                  .where((term) => term.trim().isNotEmpty)
                  .map((term) => term.trim())
                  .toList();
              
              print('✅ Gemini generated ${searchTerms.length} search terms for $category:');
              for (int j = 0; j < searchTerms.length; j++) {
                print('  ${j + 1}. "${searchTerms[j]}"');
              }
            }
          } catch (geminiError) {
            print('⚠️ Gemini API failed: $geminiError');
            print('🔄 Using fallback search terms for category: $category');
            
            // Fallback: Generate search terms directly from category
            searchTerms = [
              'child safety $category parenting tips',
              'parenting guide $category children',
            ];
            print('✅ Generated ${searchTerms.length} fallback search terms:');
            for (int j = 0; j < searchTerms.length; j++) {
              print('  ${j + 1}. "${searchTerms[j]}"');
            }
          }

          if (searchTerms.isNotEmpty) {

          // Fetch and save videos for each search term
          print('\n🎥 Fetching YouTube videos for ${searchTerms.length} search terms...');
            
            for (int k = 0; k < searchTerms.length; k++) {
              String term = searchTerms[k];
              
              if (term.isEmpty || term.startsWith('-')) {
                print('  ⏭️ Skipping invalid term: "$term"');
                continue;
              }

              print('\n  🔍 Search term ${k + 1}/${searchTerms.length}: "$term"');
              print('  📡 Calling YouTube API...');
              
              try {
                final videoData = await _youtubeService.fetchVideo(term);
                print('  📥 YouTube API response received');

                if (videoData != null) {
                  print('  ✅ Video data found');
                  final snippet = videoData['snippet'];
                  final videoId = videoData['id']['videoId'];
                  final title = snippet['title'];
                  final thumbnail = snippet['thumbnails']['high']['url'];
                  final videoUrl = "https://youtu.be/$videoId";

                  print('  📹 Video ID: $videoId');
                  print('  📝 Title: $title');
                  print('  🖼️ Thumbnail: ${thumbnail.length > 50 ? thumbnail.substring(0, 50) + "..." : thumbnail}');
                  print('  🔗 URL: $videoUrl');
                  
                  print('  💾 Saving to Firestore...');
                  final docRef = await _firestore.collection('recommendations').add({
                    'title': title,
                    'video': videoUrl,
                    'category': category,
                    'thumbnail': thumbnail,
                    'timestamp': FieldValue.serverTimestamp(),
                    'UID': user.uid,
                  });
                  
                  print('  ✅ Saved with ID: ${docRef.id}');
                } else {
                  print('  ❌ No video data returned for term: $term');
                }
              } catch (e) {
                print('  ❌ Error fetching video for "$term": $e');
              }
            }
          } else {
            print('❌ No search terms generated for category: $category');
          }
        } catch (e, stackTrace) {
          print('❌ Error processing category $category: $e');
          print('   Stack trace: $stackTrace');
          // Continue with next category even if one fails
        }
      }

      print('\n========================================');
      print('✅ RECOMMENDATION GENERATION COMPLETE');
      print('   Processed ${categories.length} categories');
      print('========================================\n');
    } catch (e, stackTrace) {
      print('\n========================================');
      print('❌ FATAL ERROR in generateRecommendations');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      print('========================================\n');
    }
  }

  /// Generate default recommendations if no quiz taken
  static Future<void> generateDefaultRecommendations() async {
    await generateRecommendations(['safety', 'health', 'education']);
  }
}
