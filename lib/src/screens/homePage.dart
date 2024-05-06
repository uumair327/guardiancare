import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/authentication/controllers/home_controller.dart';
import 'package:guardiancare/src/screens/account.dart';
import 'package:guardiancare/src/screens/emergencyContactPage.dart';
import 'package:guardiancare/src/screens/searchPage.dart';
import 'package:guardiancare/src/screens/video_page.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/sizes.dart';
import 'quizPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> videoData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchVideoData();
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
            const SizedBox(height: tDefaultSize), // Used constant for height
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height / 2,
                  aspectRatio: 5 / 4,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  scrollDirection: Axis.horizontal,
                ),
                items: videoData.isEmpty
                    ? _buildShimmerItems()
                    : videoData.map((video) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                // Navigate to WebViewPage
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    tDefaultSize), // Used constant for border radius
                                child: Stack(
                                  children: [
                                    Image.network(
                                      video['thumbnailUrl'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
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
            const SizedBox(height: tDefaultSize), // Used constant for height
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: tDefaultSize), // Used constant for padding
              child: Card(
                elevation: tDefaultSize, // Used constant for elevation
                color: tCardBgColor, // Used constant for color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      tDefaultSize), // Used constant for border radius
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      tDefaultSize), // Used constant for padding
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
                      const SizedBox(
                          height: tDefaultSize), // Used constant for height
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
            const SizedBox(height: tDefaultSize), // Used constant for height
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
                MaterialPageRoute(
                  builder: (context) => EmergencyContactPage(),
                ),
              );
            } else if (label == 'Search') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            } else if (label == 'Profile') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Account(user: _user),
                ),
              );
            } else if (label == 'Learn') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPage(),
                ),
              );
            } else {
              // Handle other button presses
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.cyan,
            backgroundColor: Colors.green,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(tHomePageButtonSize),
          ),
          child: Icon(iconData, color: tWhiteColor),
        ),
        const SizedBox(height: tHeight),
        Text(label),
      ],
    );
  }

  List<Widget> _buildShimmerItems() {
    return List.generate(5, (index) => _buildShimmerItem());
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: tCardBgColor,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: tCardBgColor,
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 2,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
