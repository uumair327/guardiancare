import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/content_card.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/explore/controllers/explore_controller.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            DefaultTabController(
              length: 1,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Recommended'),
                    ],
                    indicatorColor: tPrimaryColor,
                    labelColor: tPrimaryColor,
                  ),
                  SizedBox(
                    height: 441,
                    child: TabBarView(
                      children: [
                        _RecommendedVideos(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedVideos extends StatelessWidget {
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
