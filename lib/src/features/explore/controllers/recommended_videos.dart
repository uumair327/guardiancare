import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/explore/controllers/explore_controller.dart';
import 'package:guardiancare/src/features/learn/common_widgets/content_card.dart';
import 'package:guardiancare/src/features/quiz/screens/quizPage.dart';

class RecommendedVideos extends StatelessWidget {
  final ExploreController controller = ExploreController();

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: controller.getRecommendedVideos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final videoSet = <String>{};
        final videos = <QueryDocumentSnapshot>[];

        for (var video in snapshot.data!.docs) {
          if (!videoSet.contains(video['video'])) {
            videoSet.add(video['video']);
            videos.add(video);
          }
        }

        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'No Recommended Content Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Take a quick quiz to get personalized content recommendations!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(
                        seconds: 2)); // Optional delay for smooth UX
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: tPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Go to Quiz Page',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Based on your quiz score, we will provide personalized recommendations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return ContentCard(
              imageUrl: video['thumbnail'],
              title: video['title'],
              description: video['video'],
              context: context,
            );
          },
        );
      },
    );
  }
}
