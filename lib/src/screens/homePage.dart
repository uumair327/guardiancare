import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/screens/WebViewPage.dart';
import 'package:guardiancare/src/screens/account.dart';
import 'package:guardiancare/src/screens/emergencyContactPage.dart';
import 'package:guardiancare/src/screens/quizPage.dart';
import 'package:guardiancare/src/screens/searchPage.dart';
import 'package:guardiancare/src/screens/video_page.dart';
import 'package:shimmer/shimmer.dart';

import '../features/authentication/controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double carouselHeight;
  List<Map<String, dynamic>> videoData = [
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/Screenshot%202024-06-05%20222416.png?alt=media&token=0a380226-50fb-4b18-ac53-36a3ab28d81c',
      'link': 'https://childrenofindia.in/'
    },
    {
      'imageUrl':
          'https://www.volunteerforever.com/wp-content/uploads/2019/06/VF_TeachIndia.jpg',
      'link': 'https://childrenofindia.in/'
    },
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/Screenshot%202024-06-05%20222416.png?alt=media&token=0a380226-50fb-4b18-ac53-36a3ab28d81c',
      'link': 'https://childrenofindia.in/'
    },
    {
      'imageUrl':
          'https://www.volunteerforever.com/wp-content/uploads/2019/06/VF_TeachIndia.jpg',
      'link': 'https://childrenofindia.in/'
    },
    {
      'imageUrl':
          'https://firebasestorage.googleapis.com/v0/b/guardiancare-a210f.appspot.com/o/Screenshot%202024-06-05%20222416.png?alt=media&token=0a380226-50fb-4b18-ac53-36a3ab28d81c',
      'link': 'https://childrenofindia.in/'
    },
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  final GlobalKey<CarouselSliderState> _carouselKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchVideoData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carouselHeight = MediaQuery.of(context).size.height / 2;
  }

  Future<void> _fetchVideoData() async {
    final data = await HomeController.fetchVideoData();
    setState(() {
      videoData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CarouselSlider(
                key: _carouselKey,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height / 2,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                  scrollDirection: Axis.horizontal,
                ),
                items: videoData.isEmpty
                    ? _buildShimmerItems()
                    : videoData.map((video) {
                        final type = video['type'];
                        final imageUrl = video['imageUrl'];
                        final link = video['link'];
                        final thumbnailUrl = video['thumbnailUrl'];

                        if (imageUrl == null || link == null) {
                          return _buildShimmerItem(carouselHeight);
                        }

                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                if (type == 'video') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          WebViewPage(url: link),
                                    ),
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: type == 'video'
                                          ? thumbnailUrl
                                          : imageUrl,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    if (type == 'video')
                                      Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 50.0,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 20.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularButton(Icons.quiz, 'Quiz', context),
                          _buildCircularButton(Icons.search, 'Search', context),
                          _buildCircularButton(
                              Icons.person, 'Profile', context),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularButton(
                              Icons.favorite, 'Favorites', context),
                          _buildCircularButton(
                              Icons.emergency, 'Emergency', context),
                          _buildCircularButton(
                              Icons.video_library, 'Learn', context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(
      IconData iconData, String label, BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (label == 'Quiz') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizPage()),
              );
            } else if (label == 'Emergency') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyContactPage()),
              );
            } else if (label == 'Search') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            } else if (label == 'Profile') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Account(user: _user)),
              );
            } else if (label == 'Learn') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VideoPage()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.cyan,
            backgroundColor: const Color.fromARGB(255, 239, 73, 52),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20.0),
          ),
          child: Icon(iconData, color: Colors.white),
        ),
        const SizedBox(height: 10.0),
        Text(label),
      ],
    );
  }

  Widget _buildShimmerItem(double carouselHeight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(
          width: double.infinity,
          height: carouselHeight,
        ),
      ),
    );
  }

  // Helper method to build shimmer items when data is empty
  List<Widget> _buildShimmerItems() {
    return List.generate(5, (index) => _buildShimmerItem(carouselHeight));
  }
}
