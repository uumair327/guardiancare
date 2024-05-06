import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
;

import '../../../screens/video_player_page.dart';

class VideoController extends StatefulWidget {
  @override
  _VideoControllerState createState() => _VideoControllerState();
}

class _VideoControllerState extends State<VideoController> {
  late List<String> categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('videos').get();
    Set<String> categorySet = Set();
    querySnapshot.docs.forEach((doc) {
      final category = doc['category'] as String?;
      if (category != null) {
        categorySet.add(category);
      }
    });
    setState(() {
      categories = categorySet.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return selectedCategory != null
        ? buildVideoList(selectedCategory!)
        : buildCategoryList();
  }

  Widget buildCategoryList() {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category),
          onTap: () {
            setState(() {
              selectedCategory = category;
            });
          },
        );
      },
    );
  }

  Widget buildVideoList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<QueryDocumentSnapshot> videos = snapshot.data!.docs;
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            var video = videos[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(video['title'] ?? 'Untitled'),
              onTap: () {
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
    );
  }
}
