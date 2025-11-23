import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/widgets/content_card.dart';
import 'package:guardiancare/features/quiz/presentation/pages/quiz_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

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
                    height: MediaQuery.of(context).size.height * 0.73,
                    child: const TabBarView(
                      children: [
                        RecommendedVideos(),
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

class RecommendedVideos extends StatefulWidget {
  const RecommendedVideos({Key? key}) : super(key: key);

  @override
  State<RecommendedVideos> createState() => _RecommendedVideosState();
}

class _RecommendedVideosState extends State<RecommendedVideos> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshRecommendations() async {
    // Force a rebuild by calling setState
    setState(() {});
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshRecommendations,
      color: tPrimaryColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recommendations')
            .where('UID', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshRecommendations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_library_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 24),
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const QuizPage()),
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
                          const SizedBox(height: 16),
                          const Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black38,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final videoSet = <String>{};
          final videos = <QueryDocumentSnapshot>[];

          for (var video in snapshot.data!.docs) {
            final data = video.data() as Map<String, dynamic>;
            if (data['video'] != null && !videoSet.contains(data['video'])) {
              videoSet.add(data['video']);
              videos.add(video);
            }
          }

          if (videos.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(
                    child: Text('No unique videos found'),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final data = video.data() as Map<String, dynamic>;
              return ContentCard(
                imageUrl: data['thumbnail'] ?? '',
                title: data['title'] ?? 'Untitled',
                description: data['video'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}
