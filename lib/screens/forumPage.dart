import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Guardian Care Forum'),
        ),
        body: ListView.builder(
          itemCount: 10, // Replace with the actual number of forum posts
          itemBuilder: (context, index) {
            return ForumPost(
              title: 'Child Safety Tip #$index',
              author: 'Guardian Angel',
              date: 'February 18, 2024',
              content:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              likes: 10,
              comments: 5,
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add functionality to create new forum posts
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ForumPost extends StatelessWidget {
  final String title;
  final String author;
  final String date;
  final String content;
  final int likes;
  final int comments;

  const ForumPost({
    required this.title,
    required this.author,
    required this.date,
    required this.content,
    required this.likes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    '$author on $date',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.thumb_up),
                  Text('$likes'),
                  SizedBox(width: 8.0),
                  Icon(Icons.comment),
                  Text('$comments'),
                ],
              ),
              SizedBox(height: 8.0),
              Text(content),
            ],
          ),
        ),
      ),
    );
  }
}
