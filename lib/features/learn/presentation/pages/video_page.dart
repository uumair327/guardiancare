import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/video_player_page.dart';
import 'package:guardiancare/src/constants/colors.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<List<String>>? categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot thumbnails =
          await FirebaseFirestore.instance.collection('learn').get();
      List<List<String>> categoryList = [];
      for (var doc in thumbnails.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['name'] as String?;
        final thumbnail = data['thumbnail'] as String?;
        if (category != null && thumbnail != null) {
          categoryList.add([category, thumbnail]);
        }
      }
      if (mounted) {
        setState(() {
          categories = categoryList;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          categories = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory ?? 'Learn'),
        backgroundColor: tPrimaryColor,
        foregroundColor: Colors.white,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                  });
                },
              )
            : null,
      ),
      body: categories == null
          ? const Center(child: CircularProgressIndicator())
          : selectedCategory != null
              ? buildVideoList(selectedCategory!)
              : buildCategoryList(),
    );
  }

  Widget buildCategoryList() {
    if (categories!.isEmpty) {
      return const Center(
        child: Text('No categories available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: categories!.length,
        itemBuilder: (context, index) {
          final category = categories![index][0];
          final thumbnail = categories![index][1];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      width: 300,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library, size: 48),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: tPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
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

  Widget buildVideoList(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No videos available'));
        }

        List<QueryDocumentSnapshot> videos = snapshot.data!.docs;
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
              var video = videos[index].data() as Map<String, dynamic>;
              return GestureDetector(
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
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Image.network(
                          video["thumbnailUrl"] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.play_circle_outline,
                                  size: 48),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          video['title'] ?? 'Untitled',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: tPrimaryColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
