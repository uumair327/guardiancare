import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/web_view_page.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/emergency/screens/emergency_contact_page.dart';
import 'package:guardiancare/src/features/home/controllers/home_controller.dart';
import 'package:guardiancare/src/features/home/widgets/circular_button.dart';
import 'package:guardiancare/src/features/home/widgets/home_carousel.dart';
import 'package:guardiancare/src/features/learn/screens/video_page.dart';
import 'package:guardiancare/src/features/profile/screens/account.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_page.dart';
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
  final ConsentController _consentController = ConsentController();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchCarouselData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carouselHeight = MediaQuery.of(context).size.height / 3;
  }

  Future<void> _fetchCarouselData() async {
    try {
      final data = await HomeController().fetchCarouselData();
      if (mounted) {
        setState(() {
          carouselData = data
              .where((item) => item['imageUrl'] != null && item['link'] != null)
              .toList();
        });
      }
    } catch (e) {
      print('Error loading carousel data: $e');
    }
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
              const SizedBox(height: 5.0),
              HomeCarousel(
                carouselData: carouselData,
                carouselHeight: carouselHeight,
              ),
              const SizedBox(height: 40.0),
              Padding(
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
                                    builder: (context) => QuizPage(),
                                  ),
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
                                    builder: (context) => const VideoPage(),
                                  ),
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
                                        const EmergencyContactPage(),
                                  ),
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
                                _consentController.verifyParentalKey(
                                  context,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Account(user: _user),
                                      ),
                                    );
                                  },
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
                                    builder: (context) => const WebViewPage(
                                        url: "https://childrenofindia.in/"),
                                  ),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.email,
                              label: 'Mail Us',
                              onPressed: () {
                                _consentController.verifyParentalKey(
                                  context,
                                  () async {
                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: 'hello@childrenofindia.in',
                                    );
                                    // ignore: deprecated_member_use
                                    if (await canLaunch(
                                        emailLaunchUri.toString())) {
                                      // ignore: deprecated_member_use
                                      await launch(emailLaunchUri.toString());
                                    } else {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Could not launch email client"),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}
