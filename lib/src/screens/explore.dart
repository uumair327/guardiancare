import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/screens/video_player_page.dart';

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
                    height: 440,
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
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recommendations')
          .where('UID', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
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
            return _buildContentCard(
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

  Widget _buildContentCard({
    required String imageUrl,
    required String title,
    required String description,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(videoUrl: description),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14.0,
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
