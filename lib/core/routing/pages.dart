import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_bloc.dart';
import 'package:guardiancare/features/consent/presentation/pages/enhanced_consent_form_page.dart';
import 'package:guardiancare/features/consent/presentation/widgets/forgot_parental_key_dialog.dart';
import 'package:guardiancare/core/widgets/parental_verification_dialog.dart';
import 'package:guardiancare/core/services/parental_verification_service.dart';
import 'package:guardiancare/features/explore/presentation/pages/explore_page.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/forum/presentation/pages/forum_page.dart';
import 'package:guardiancare/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardiancare/features/home/presentation/pages/home_page.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0;
  bool hasSeenConsent = false;
  bool isCheckingConsent = true;
  bool hasSeenForumGuidelines = false;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController formController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndShowConsent();
    
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _checkAndShowConsent();
      }
    });
  }

  Future<void> _checkAndShowConsent() async {
    try {
      final String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        if (mounted) {
          setState(() {
            hasSeenConsent = true;
            isCheckingConsent = false;
          });
        }
        return;
      }

      DocumentSnapshot consentDoc =
          await _firestore.collection('consents').doc(userId).get();

      if (mounted) {
        setState(() {
          hasSeenConsent = consentDoc.exists;
          isCheckingConsent = false;
        });
      }
    } catch (e) {
      print("Error fetching consent data: $e");

      if (mounted) {
        setState(() {
          hasSeenConsent = false;
          isCheckingConsent = false;
        });
      }
    }
  }

  void submitConsent() async {
    setState(() {
      hasSeenConsent = true;
    });
  }

  void _verifyParentalKeyForForum(BuildContext context, int newIndex) async {
    showParentalVerification(
      context,
      'Forum',
      () {
        setState(() {
          index = newIndex;
        });
        _checkAndShowGuidelines();
      },
    );
  }
  
  String _hashKey(String key) {
    return sha256.convert(utf8.encode(key)).toString();
  }
  
  void _checkAndShowGuidelines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasSeenForumGuidelines =
        prefs.getBool('has_seen_forum_guidelines') ?? false;

    if (index == 2 && !hasSeenForumGuidelines) {
      _showGuidelinesDialog();
      await prefs.setBool('has_seen_forum_guidelines', true);
      setState(() {
        hasSeenForumGuidelines = true;
      });
    }
  }

  void _showGuidelinesDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Forum Guidelines',
            style: TextStyle(
              color: tPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Welcome to the guardiancare Global Forum. Kindly follow these guidelines:'),
                SizedBox(height: 10),
                Text('• Be respectful and courteous to all members.'),
                Text(
                    '• Do not use any language that is abusive, harassing, or harmful.'),
                Text(
                    '• Avoid sharing content that is inappropriate or harmful, especially related to children.'),
                Text(
                    '• Remember that this is a space for constructive discussions on child safety.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'I Agree',
                style: TextStyle(color: tPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home, size: 25, color: tNavBarColorButton),
      const Icon(Icons.explore, size: 25, color: tNavBarColorButton),
      const Icon(Icons.forum, size: 25, color: tNavBarColorButton),
    ];

    final screens = <Widget>[
      BlocProvider(
        create: (_) => sl<HomeBloc>(),
        child: const HomePage(),
      ),
      const ExplorePage(),
      BlocProvider(
        create: (_) => sl<ForumBloc>(),
        child: const ForumPage(),
      ),
    ];

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text(
              "Guardian Care",
              style: TextStyle(
                color: tPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25,
                fontStyle: FontStyle.italic,
              ),
            ),
            centerTitle: true,
            actions: [
              StreamBuilder<User?>(
                stream: _auth.authStateChanges(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  if (user == null) {
                    // User not signed in - show sign in button
                    return IconButton(
                      icon: const Icon(Icons.login, color: tPrimaryColor),
                      tooltip: 'Sign In',
                      onPressed: () {
                        context.go('/login');
                      },
                    );
                  }
                  // User is signed in - no action needed
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: screens[index],
          bottomNavigationBar: CurvedNavigationBar(
            key: _bottomNavigationKey,
            items: items,
            backgroundColor: Colors.transparent,
            color: tNavBarColor,
            height: 55,
            index: index,
            onTap: (newIndex) {
              if (newIndex == 2) {
                _verifyParentalKeyForForum(context, newIndex);
              } else {
                setState(() {
                  index = newIndex;
                });
              }
            },
          ),
        ),

        if (isCheckingConsent)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  color: tPrimaryColor,
                ),
              ),
            ),
          ),

        if (!hasSeenConsent && !isCheckingConsent)
          Positioned.fill(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                BlocProvider(
                  create: (_) => sl<ConsentBloc>(),
                  child: EnhancedConsentFormPage(
                    onSubmit: submitConsent,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
