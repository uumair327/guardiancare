import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/authentication/controllers/video_controller.dart';

class VideoPage extends StatefulWidget {
  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: VideoController(),
    );
  }
}
