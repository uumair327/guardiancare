import 'package:flutter/material.dart';

class LearnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Learn"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ContentField(
            title: "Road Safety",
            theme: "Stay Safe on the Road",
            videos: [
              "Video 1",
              "Video 2",
              "Video 3",
              // Add more videos as needed
            ],
          ),
          ContentField(
            title: "Child Abuse",
            theme: "Protecting Our Children",
            videos: [
              "Video 1",
              "Video 2",
              "Video 3",
              // Add more videos as needed
            ],
          ),
          ContentField(
            title: "Sexual Harassment",
            theme: "Creating Safe Environments",
            videos: [
              "Video 1",
              "Video 2",
              "Video 3",
              // Add more videos as needed
            ],
          ),
          // Add more content fields as needed
        ],
      ),
    );
  }
}

class ContentField extends StatelessWidget {
  final String title;
  final String theme;
  final List<String> videos;

  const ContentField({
    required this.title,
    required this.theme,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPage(videos: videos),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.category, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                theme,
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
        Divider(), // Add a divider between content fields
      ],
    );
  }
}

class VideoPage extends StatelessWidget {
  final List<String> videos;

  const VideoPage({Key? key, required this.videos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(videos[index]),
            onTap: () {
              // Add functionality to play the video
            },
          );
        },
      ),
    );
  }
}
