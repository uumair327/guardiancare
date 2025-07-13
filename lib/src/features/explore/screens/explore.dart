import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/explore/controllers/recommended_videos.dart';
import 'package:guardiancare/src/features/explore/controllers/recommended_resources.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Videos, PDFs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Videos'),
              Tab(text: 'Resources'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First Tab
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RecommendedVideos(),
            ),
            // Second Tab
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RecommendedResources(),
            ),
          ],
        ),
      ),
    );
  }
}
