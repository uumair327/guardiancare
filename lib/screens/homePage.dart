import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/screens/account.dart';
import 'package:guardiancare/screens/emergencyContactPage.dart';
import 'package:guardiancare/screens/learn.dart';
import 'package:guardiancare/screens/quizPage.dart';
import 'package:guardiancare/screens/searchPage.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> videoData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    fetchVideoTitles();
  }

  Future<void> fetchVideoTitles() async {
    final videoUrls = [
      'https://www.youtube.com/watch?v=d5dCN66PokQ',
      'https://www.youtube.com/watch?v=_MXD-eL4z_M',
      'https://www.youtube.com/watch?v=sehKCzxIblQ',
      'https://www.youtube.com/watch?v=qRLqkqWBJPE',
      'https://www.youtube.com/watch?v=3SzazN2OrsQ',
    ];

    for (final videoUrl in videoUrls) {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final videoTitle = _extractVideoTitle(response.body);
        final thumbnailUrl = await _getThumbnailUrl(videoUrl);
        videoData.add({
          'url': videoUrl,
          'title': videoTitle,
          'thumbnailUrl': thumbnailUrl
        });
      } else {
        print('Failed to fetch video title for $videoUrl');
      }
    }
    setState(() {});
  }

  String _extractVideoTitle(String html) {
    final regExp =
    RegExp(r'<title>(?:\S+\s*\|)?\s*(?<title>[\S\s]+?) - YouTube</title>');
    final match = regExp.firstMatch(html);
    return match?.namedGroup('title') ?? '';
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
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: videoData.isEmpty
                      ? _buildShimmerItems()
                      : videoData.map((video) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewPage(url: video['url']),
                          ),
                        );
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
                                      color: Colors.white,
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
                            _buildCircularButton(Icons.quiz, 'Quiz', context, Colors.orange),
                            _buildCircularButton(Icons.search, 'Search', context, Colors.green),
                            _buildCircularButton(Icons.person, 'Profile', context, Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircularButton(Icons.favorite, 'Favorites', context, Colors.pink),
                            _buildCircularButton(Icons.emergency, 'Emergency', context, Colors.red),
                            _buildCircularButton(Icons.video_library, 'Learn', context, Colors.blue),
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
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
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
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<String> _getThumbnailUrl(String videoUrl) async {
    final videoId = _extractVideoId(videoUrl);
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  String _extractVideoId(String url) {
    final regExp = RegExp(
        r"(?:https:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/|www\.youtube\.com\/\S*?[?&]v=)?([a-zA-Z0-9_-]{11})");
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }
}

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Video')),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}