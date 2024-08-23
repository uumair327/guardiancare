import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/explore/controllers/recommended_videos.dart';

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
                    height: MediaQuery.of(context).size.height * 0.73,
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
