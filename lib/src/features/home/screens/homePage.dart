import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/WebViewPage.dart';
import 'package:guardiancare/src/features/emergency/screens/emergencyContactPage.dart';
import 'package:guardiancare/src/features/learn/screens/video_page.dart';
import 'package:guardiancare/src/features/profile/screens/account.dart';
import 'package:guardiancare/src/features/quiz/screens/quizPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double carouselHeight;
  List<Map<String, dynamic>> carouselData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final GlobalKey<CarouselSliderState> _carouselKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    fetchCarouselData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carouselHeight = MediaQuery.of(context).size.height / 3;
  }

  Future<void> fetchCarouselData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('carousel_items').get();
      setState(() {
        carouselData = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching carousel data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              child: CarouselSlider(
                key: _carouselKey,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height / 3,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  scrollDirection: Axis.horizontal,
                ),
                items: carouselData.isEmpty
                    ? _buildShimmerItems()
                    : carouselData.map((item) {
                        final type = item['type'] ?? 'image';
                        final imageUrl = item['imageUrl'];
                        final link = item['link'];
                        final thumbnailUrl = item['thumbnailUrl'] ?? '';

                        if (imageUrl == null || link == null) {
                          return _buildShimmerItem(carouselHeight);
                        }

                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WebViewPage(url: link),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: type == 'video'
                                          ? thumbnailUrl
                                          : imageUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                    if (type == 'video')
                                      const Center(
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
                          _buildCircularButton(
                              Icons.video_library, 'Learn', context),
                          _buildCircularButton(
                              Icons.emergency, 'Emergency', context),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularButton(
                              Icons.person, 'Profile', context),
                          _buildCircularButton(
                              CupertinoIcons.globe, 'Website', context),
                          _buildCircularButton(Icons.email, 'Mail Us', context)
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SingleChildScrollView(
            child: ElevatedButton(
              onPressed: () async {
                if (label == 'Quiz') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizPage()),
                  );
                } else if (label == 'Emergency') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EmergencyContactPage()),
                  );
                } else if (label == 'Website') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            WebViewPage(url: "https://childrenofindia.in/")),
                  );
                } else if (label == 'Profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Account(user: _user)),
                  );
                } else if (label == 'Learn') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VideoPage()),
                  );
                } else {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'hello@childrenofindia.in',
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  } else {
                    throw "Could not launch $emailLaunchUri";
                  }
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
          ),
          const SizedBox(height: 10.0),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildShimmerItem(double carouselHeight) {
    return SingleChildScrollView(
      child: Container(
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
      ),
    );
  }

  List<Widget> _buildShimmerItems() {
    return List.generate(5, (index) => _buildShimmerItem(carouselHeight));
  }
}
