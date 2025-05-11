import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/emergency/screens/emergency_contact_page.dart';
import 'package:guardiancare/src/features/home/controllers/home_controller.dart';
import 'package:guardiancare/src/features/home/widgets/circular_button.dart';
import 'package:guardiancare/src/features/home/widgets/home_carousel.dart';
import 'package:guardiancare/src/features/learn/screens/video_page.dart';
import 'package:guardiancare/src/features/profile/screens/account.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_page.dart';
import 'package:guardiancare/src/routing/app_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double carouselHeight;
  List<Map<String, dynamic>> carouselData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConsentController _consentController = ConsentController();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    if (_user != null && !_user!.isAnonymous) {
      final hasConsent = await _consentController.hasUserConsent(_user!.uid);
      if (!hasConsent && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Consent Required'),
            content: const Text('You need to provide consent to use this app.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I Understand'),
              ),
            ],
          ),
        );
      }
    }
    if (mounted) {
      await _fetchCarouselData();
      setState(() => _isLoading = false);
    }
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
          carouselData = List<Map<String, dynamic>>.from(data)
              .where((item) => item['imageUrl'] != null && item['link'] != null)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading carousel data: $e');
    }
  }

  void _showUpgradePrompt() {
    Get.snackbar(
      'Upgrade Required',
      'This feature requires a full account. Please sign up to continue.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          Get.back();
          Get.toNamed(AppRouter.login, arguments: {
            'requireLogin': true,
            'message': 'Sign up to access all features',
          });
        },
        child: const Text(
          'SIGN UP',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  bool _isFeatureAllowed() {
    final authController = Get.find<AuthController>();
    return !authController.isGuest;
  }

  void _navigateToFeature(Widget page, {bool requiresAuth = false}) {
    if (requiresAuth && !_isFeatureAllowed()) {
      _showUpgradePrompt();
      return;
    }
    Get.to(() => page);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final authController = Get.find<AuthController>();
    final isGuest = authController.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Care'),
        actions: [
          if (isGuest)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Chip(
                label: const Text('Guest Mode', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.orange,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (isGuest) {
                _showUpgradePrompt();
              } else {
                Get.to(() => const Account());
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGuest)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are in guest mode. Some features may be limited.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(
                          AppRouter.login,
                          arguments: {
                            'requireLogin': true,
                            'message': 'Sign up to access all features',
                          },
                        );
                      },
                      child: const Text('SIGN UP'),
                    ),
                  ],
                ),
              ),
            Expanded(
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircularButton(
                                iconData: Icons.quiz,
                                label: 'Quiz',
                                onPressed: () => _navigateToFeature(QuizPage(), requiresAuth: true),
                              ),
                              CircularButton(
                                iconData: Icons.video_library,
                                label: 'Learn',
                                onPressed: () => _navigateToFeature(const VideoPage()),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircularButton(
                                iconData: Icons.emergency,
                                label: 'Emergency',
                                onPressed: () => _navigateToFeature(EmergencyContactPage(), requiresAuth: true),
                              ),
                              CircularButton(
                                iconData: Icons.help_outline,
                                label: 'Help',
                                onPressed: () {
                                  final Uri emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'support@guardiancare.com',
                                    query: 'subject=Help Request',
                                  );
                                  launchUrl(emailLaunchUri);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
