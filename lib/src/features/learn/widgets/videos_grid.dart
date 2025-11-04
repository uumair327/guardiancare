import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/models.dart';
import 'package:guardiancare/src/common_widgets/video_player_page.dart';
import 'package:guardiancare/src/constants/colors.dart';

class VideosGrid extends StatelessWidget {
  final List<VideoModel> videos;
  final String categoryName;

  const VideosGrid({
    super.key,
    required this.videos,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos available in "$categoryName" category',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<LearnBloc>().add(BackToCategories());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Categories'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          
          print('VideosGrid: Rendering video ${index + 1}: "${video.title}"');
          
          return GestureDetector(
            onTap: () {
              print('VideosGrid: Video tapped: "${video.title}" with URL: "${video.videoUrl}"');
              
              if (video.videoUrl.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      videoUrl: video.videoUrl,
                    ),
                  ),
                );
              } else {
                print('VideosGrid: Empty video URL for "${video.title}"');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Video URL not available for "${video.title}"'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12.0),
                      ),
                      child: video.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                print('VideosGrid: Error loading thumbnail for "${video.title}": $error');
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.video_library_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.video_library_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: tPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}