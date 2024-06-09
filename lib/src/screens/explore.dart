import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';

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
                    height: 400,
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
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('recommendations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final videos = snapshot.data!.docs;

        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildContentCard(
              imageUrl: video['thumbnail'],
              title: video['title'],
              description: video['video'],
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
  }) {
    return SingleChildScrollView(
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
