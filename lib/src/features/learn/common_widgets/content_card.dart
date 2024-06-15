import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/video_player_page.dart';

class ContentCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final BuildContext context;

  ContentCard({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 3.0),
                  // Text(
                  //   description,
                  //   style: const TextStyle(
                  //     fontSize: 14.0,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
