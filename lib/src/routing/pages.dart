import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/screens/consent_form.dart';
import 'package:guardiancare/src/features/explore/screens/explore.dart';
import 'package:guardiancare/src/features/forum/screens/forum_page.dart';
import 'package:guardiancare/src/features/home/screens/home_page.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:shared_preferences/shared_preferences.dart';

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0;
  bool hasSeenConsent = false;
  bool hasSeenForumGuidelines = false;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ConsentController _consentController = ConsentController();
  final TextEditingController formController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndShowConsent();
  }

  Future<void> _checkAndShowConsent() async {
    try {
      // Get the current user's ID from FirebaseAuth
      final String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        // If no user is logged in, default `hasSeenConsent` to false
        setState(() {
          hasSeenConsent = false;
        });

        return;
      }

      // Check if the user's document exists in the 'consents' collection
      DocumentSnapshot consentDoc =
          await _firestore.collection('consents').doc(userId).get();

      setState(() {
        hasSeenConsent = consentDoc.exists; // true if the document exists
      });
    } catch (e) {
      print("Error fetching consent data: $e");

      setState(() {
        hasSeenConsent = false; // Default to false if there's an error
      });
    }
  }

  void submitConsent() async {
    setState(() {
      hasSeenConsent = true;
    });
  }

  void _verifyParentalKeyForForum(BuildContext context, int newIndex) async {
    _consentController.verifyParentalKeyWithError(
      context,
      onSuccess: () {
        setState(() {
          index = newIndex;
        });
        _checkAndShowGuidelines();
      },
      onError: () {
        // Reset to previous index on error
        setState(() {
          index = 0; // Reset to home page
        });
        // Force bottom navigation to update
        _bottomNavigationKey.currentState?.setPage(0);
      },
    );
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
      barrierDismissible: false, // Prevent dismissing by tapping outside
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
                Navigator.of(context).pop(); // Close the dialog
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
      const HomePage(),
      const Explore(),
      ForumPage(),
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
                // If ForumPage is selected, verify parental key
                _verifyParentalKeyForForum(context, newIndex);
              } else {
                setState(() {
                  index = newIndex;
                });
              }
            },
          ),
        ),

        // Consent form overlay
        if (!hasSeenConsent)
          Positioned.fill(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                ConsentForm(
                  consentController: _consentController,
                  controller: formController,
                  onSubmit: submitConsent,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
