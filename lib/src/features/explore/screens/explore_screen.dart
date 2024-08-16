import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:guardianscare/src/features/explore/controllers/recommended_videos.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DefaultTabController(
              length: 1,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
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
