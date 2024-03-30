import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/screens/account/account.dart';
import 'package:guardiancare/screens/emergency contact page/emergencyContactPage.dart';
import 'package:guardiancare/screens/learn/learn.dart';
import 'package:guardiancare/screens/quizpage/quizPage.dart';
import 'package:guardiancare/screens/pages/searchpage/searchPage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _videoData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final CarouselController _carouselController = CarouselController();
  final List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchVideoData();
  }

  Future<void> _fetchVideoData() async {
    final videoUrls = [
      'https://www.youtube.com/watch?v=d5dCN66PokQ',
      'https://www.youtube.com/watch?v=_MXD-eL4z_M',
      'https://www.youtube.com/watch?v=sehKCzxIblQ',
      'https://www.youtube.com/watch?v=qRLqkqWBJPE',
      'https://www.youtube.com/watch?v=3SzazN2OrsQ',
    ];

    final videoDataFutures = videoUrls.map((videoUrl) async {
      final videoId = _extractVideoId(videoUrl);
      final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
      precacheImage(NetworkImage(thumbnailUrl), context);

      final videoPlayerController = VideoPlayerController.networkUrl(videoUrl as Uri);
      await videoPlayerController.initialize();
      final duration = videoPlayerController.value.duration;
      final videoTitle = _extractVideoTitle(duration.inMilliseconds as Duration);

      _videoControllers.add(videoPlayerController);

      return {
        'url': videoUrl,
        'title': videoTitle,
        'thumbnailUrl': thumbnailUrl,
        'controller': videoPlayerController,
      };
    });

    final videoData = await Future.wait(videoDataFutures);
    _videoData.addAll(videoData.whereType<Map<String, dynamic>>());
    setState(() {});
  }

  String _extractVideoTitle(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height / 3,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.9,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(milliseconds: 1),
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: _videoData.isEmpty
                      ? _buildShimmerItems()
                      : _videoData.take(5).map((video) {
                    return GestureDetector(
                      onTap: () {
                        showVideoPage(context, video['controller']);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Stack(
                          children: [
                            _buildVideoThumbnail(video['thumbnailUrl']),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    video['title'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Card(
                  elevation: 8,
                  color: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircularButton(
                                Icons.quiz, 'Quiz', context, Colors.orange),
                            _buildCircularButton(
                                Icons.search, 'Search', context, Colors.green),
                            _buildCircularButton(Icons.person, 'Profile',
                                context, Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircularButton(Icons.favorite, 'Favorites',
                                context, Colors.pink),
                            _buildCircularButton(Icons.emergency, 'Emergency',
                                context, Colors.red),
                            _buildCircularButton(Icons.video_library, 'Learn',
                                context, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(String thumbnailUrl) {
    return SizedBox(
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl,
        placeholder: (context, url) =>
        const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  Widget _buildCircularButton(
      IconData iconData,
      String label,
      BuildContext context,
      Color color,
      ) {
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
            foregroundColor: Colors.white,
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(iconData, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildShimmerItems() {
    return List.generate(5, (index) => _buildShimmerItem());
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey[300],
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 3,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _extractVideoId(String url) {
    final regExp = RegExp(
        r"(?:https:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|www\.youtube\.com\/\S*?[?&]v=)?([a-zA-Z0-9_-]{11})");
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  void showVideoPage(BuildContext context, VideoPlayerController controller) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('YouTube Video')),
          body: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );
  }
}