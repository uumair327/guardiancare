import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/video_player_page.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:video_player/video_player.dart';

class VideoController extends StatefulWidget {
  const VideoController({super.key});

  @override
  _VideoControllerState createState() => _VideoControllerState();
}

class _VideoControllerState extends State<VideoController> {
  List<List<String>>? categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Call fetchCategories in initState
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return const Center(
          child:
              CircularProgressIndicator()); // Return a loading indicator while categories are being fetched
    } else if (selectedCategory != null) {
      return buildVideoList(selectedCategory!);
    } else {
      return buildCategoryList();
    }
  }

  Future<void> fetchCategories() async {
    // QuerySnapshot querySnapshot =
    //     await FirebaseFirestore.instance.collection('videos').get();
    QuerySnapshot thumbnails =
        await FirebaseFirestore.instance.collection('learn').get();
    List<List<String>> categoryList = [];
    for (var doc in thumbnails.docs) {
      final category = doc['name'] as String?;
      final thumbnail = doc['thumbnail'] as String?;
      if (category != null && thumbnail != null) {
        categoryList.add([category, thumbnail]);
      }
    }
    setState(() {
      categories = categoryList;
    });
  }

  Widget buildCategoryList() {
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: tPrimaryColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
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
        List<QueryDocumentSnapshot> videos = snapshot.data!.docs;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            var video = videos[index].data() as Map<String, dynamic>;
            // ignore: unused_local_variable
            VideoPlayerController controller = VideoPlayerController.networkUrl(
              Uri.parse(video['videoUrl'] as String? ?? ''),
            )..initialize().then((_) {
                setState(() {});
              });

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
                    Image.network(
                      video["thumbnailUrl"],
                      fit: BoxFit.cover,
                    ),
                    // AspectRatio(
                    //   aspectRatio: 16 / 9,
                    //   child: VideoPlayer(controller),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        video['title'] ?? 'Untitled',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: tPrimaryColor),
                      ),
                    )
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //   child: Text(
                    //     video['description'] ?? '',
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
