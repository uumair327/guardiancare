import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPage extends StatefulWidget {
  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Check if the user is authenticated
    User? user = _auth.currentUser;
    if (user == null) {
      // Handle unauthenticated state
    } else {
      // User is authenticated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('videos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Extract videos from the snapshot
          List<QueryDocumentSnapshot> videos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              var video = videos[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(video['title'] ?? 'Untitled'),
                onTap: () {
                  // Navigate to video player page passing the video URL
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerPage(
                        videoUrl: video['videoUrl'] as String? ?? '',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class VideoPlayerPage extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract video ID from the YouTube URL
    String? videoId = YoutubePlayer.convertUrlToId(videoUrl);

    // Check if the video ID is null
    if (videoId == null) {
      // Handle the case where the video ID is null
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Player'),
        ),
        body: const Center(
          child: Text('Invalid YouTube URL'),
        ),
      );
    }

    // Create a YoutubePlayerController
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Implement video player here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.blue,
                  handleColor: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
