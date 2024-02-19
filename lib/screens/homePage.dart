import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/quizPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                ),
                items: [
                  // Replace the URLs with your image URLs
                  'assets/images/image.png',
                  'assets/images/image.png',
                  'assets/images/image.png',
                  'assets/images/image.png',
                  'assets/images/image.png',
                ].map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          // Replace the YouTube link with your actual YouTube link
                          _launchYouTubeLink(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage(
                                  imageUrl), // Use AssetImage for local assets
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.blue[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularButton(
                              Icons.quiz, 'Quiz', context), // Changed here
                          _buildCircularButton(Icons.search, 'Search', context),
                          _buildCircularButton(
                              Icons.person, 'Profile', context),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCircularButton(
                              Icons.favorite, 'Favorites', context),
                          _buildCircularButton(
                              Icons.settings, 'Settings', context),
                          _buildCircularButton(
                              Icons.notifications, 'Notifications', context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Home Page",
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchYouTubeLink(BuildContext context) {
    // Replace 'https://www.youtube.com/' with your actual YouTube link
    final String youtubeLink = 'https://www.youtube.com/';
    // Use any method to open the link, here we use Navigator to push a WebView page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(url: youtubeLink),
      ),
    );
  }
}

Widget _buildCircularButton(
    IconData iconData, String label, BuildContext context) {
  return Column(
    children: [
      ElevatedButton(
        onPressed: () {
          if (label == 'Quiz') {
            // Navigate to the quiz page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      QuizPage()), // Replace QuizPage with your actual quiz page
            );
          } else {
            // Handle other button presses
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.cyan,
          backgroundColor: Colors.green,
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
        ),
        child: Icon(iconData, color: Colors.white),
      ),
      SizedBox(height: 8),
      Text(label),
    ],
  );
}

// WebViewPage is a placeholder for a web view to display the YouTube link
class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube Video')),
      body: Center(
        child: Text('WebView to display YouTube video'),
      ),
    );
  }
}

// QuizPage is a placeholder for the quiz page
// class QuizPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Quiz Page'),
//       ),
//       body: Center(
//         child: Text('This is the quiz page'),
//       ),
//     );
//   }
// }
