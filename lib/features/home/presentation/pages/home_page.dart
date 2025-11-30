import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/features/home/presentation/widgets/circular_button.dart';
import 'package:guardiancare/features/home/presentation/widgets/simple_carousel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guardiancare/core/widgets/parental_verification_dialog.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
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
                              label: l10n.quiz,
                              onPressed: () => context.push('/quiz'),
                            ),
                            CircularButton(
                              iconData: Icons.video_library,
                              label: l10n.learn,
                              onPressed: () => context.push('/video'),
                            ),
                            CircularButton(
                              iconData: Icons.emergency,
                              label: l10n.emergency,
                              onPressed: () => context.push('/emergency'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircularButton(
                              iconData: Icons.person,
                              label: l10n.profile,
                              onPressed: () {
                                showParentalVerification(
                                  context,
                                  l10n.profile,
                                  () => context.push('/account'),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: CupertinoIcons.globe,
                              label: l10n.website,
                              onPressed: () => context.push('/webview', 
                                extra: "https://childrenofindia.in/"),
                            ),
                            CircularButton(
                              iconData: Icons.email,
                              label: l10n.mailUs,
                              onPressed: () {
                                showParentalVerification(
                                  context,
                                  l10n.mailUs,
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
