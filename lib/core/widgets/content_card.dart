import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ContentCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const ContentCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/video-player', extra: description),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
