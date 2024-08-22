import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardianscare/src/common_widgets/WebViewPage.dart';
import 'package:guardianscare/src/features/emergency/screens/emergencyContactPage.dart';
import 'package:guardianscare/src/features/home/controllers/home_controller.dart';
import 'package:guardianscare/src/features/home/widgets/circular_button.dart';
import 'package:guardianscare/src/features/home/widgets/home_carousel.dart';
import 'package:guardianscare/src/features/learn/screens/video_page.dart';
import 'package:guardianscare/src/features/profile/screens/account.dart';
import 'package:guardianscare/src/features/quiz/screens/quizPage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double carouselHeight;
  List<Map<String, dynamic>> carouselData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

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
    List<Map<String, dynamic>> data =
        await HomeController().fetchCarouselData();
    setState(() {
      carouselData = data;
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
            const SizedBox(height: 5.0),
            HomeCarousel(
              carouselData: carouselData,
              carouselHeight: carouselHeight,
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Card(
                  elevation: 20.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircularButton(
                              iconData: Icons.quiz,
                              label: 'Quiz',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QuizPage()),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.video_library,
                              label: 'Learn',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const VideoPage()),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.emergency,
                              label: 'Emergency',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EmergencyContactPage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircularButton(
                              iconData: Icons.person,
                              label: 'Profile',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Account(user: _user)),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: CupertinoIcons.globe,
                              label: 'Website',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewPage(
                                        url: "https://childrenofindia.in/"),
                                  ),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.email,
                              label: 'Mail Us',
                              onPressed: () async {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'hello@childrenofindia.in',
                                );
                                if (await canLaunch(
                                    emailLaunchUri.toString())) {
                                  await launch(emailLaunchUri.toString());
                                } else {
                                  throw "Could not launch $emailLaunchUri";
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15.0),
          ],
        ),
      ),
    );
  }
}
