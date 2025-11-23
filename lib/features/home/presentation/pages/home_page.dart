import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/widgets/web_view_page.dart';
import 'package:guardiancare/features/emergency/presentation/pages/emergency_contact_page.dart';
import 'package:guardiancare/features/profile/presentation/pages/account_page.dart';
import 'package:guardiancare/features/home/presentation/widgets/circular_button.dart';
import 'package:guardiancare/features/home/presentation/widgets/simple_carousel.dart';
import 'package:guardiancare/features/quiz/presentation/pages/quiz_page.dart';
import 'package:guardiancare/features/learn/presentation/pages/video_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guardiancare/core/widgets/parental_verification_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
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
    _fetchCarouselData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carouselHeight = MediaQuery.of(context).size.height / 3;
  }

  Future<void> _fetchCarouselData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carousel_items')
          .get();
      
      if (mounted) {
        setState(() {
          carouselData = snapshot.docs
              .map((doc) {
                final data = doc.data();
                return {
                  'type': data['type'] ?? 'image',
                  'imageUrl': data['imageUrl'],
                  'link': data['link'],
                  'thumbnailUrl': data['thumbnailUrl'] ?? '',
                  'content': data['content'] ?? {},
                };
              })
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
              SimpleCarousel(
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
                                    builder: (context) => const QuizPage(),
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
                                showParentalVerification(
                                  context,
                                  'Profile',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AccountPage(user: _user),
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
                                showParentalVerification(
                                  context,
                                  'Mail Us',
                                  () async {
                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: 'hello@childrenofindia.in',
                                      queryParameters: {
                                        'subject': 'Guardian Care App Inquiry',
                                      },
                                    );
                                    
                                    try {
                                      final bool launched = await launchUrl(
                                        emailLaunchUri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                      
                                      if (!launched && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Could not launch email client"),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Error launching email: $e"),
                                          ),
                                        );
                                      }
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
