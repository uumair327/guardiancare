import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isVideoUrlValid = false;

  @override
  void initState() {
    super.initState();

    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _isVideoUrlValid = true;
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _isVideoUrlValid
            ? YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.blue,
                  handleColor: Colors.blueAccent,
                ),
                onReady: () {
                  _controller.addListener(() {});
                },
              )
            : const Text(
                'Invalid YouTube URL',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isVideoUrlValid) {
      _controller.dispose();
    }
    super.dispose();
  }
}
