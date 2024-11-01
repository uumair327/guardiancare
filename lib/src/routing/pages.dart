import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/explore/screens/explore.dart';
import 'package:guardiancare/src/features/forum/screens/forum_page.dart';
import 'package:guardiancare/src/features/home/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0;
  bool hasSeenForumGuidelines = false;

  Future<void> _checkAndShowGuidelines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasSeenForumGuidelines =
        prefs.getBool('has_seen_forum_guidelines') ?? false;

    if (index == 2 && !hasSeenForumGuidelines) {
      await _showGuidelinesDialog();
      await prefs.setBool('has_seen_forum_guidelines', true);
      setState(() {
        hasSeenForumGuidelines = true;
      });
    }
  }

  Future<void> _showGuidelinesDialog() async {
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
      const Icon(
        Icons.home,
        size: 25,
        color: tNavBarColorButton,
      ),
      const Icon(
        Icons.explore,
        size: 25,
        color: tNavBarColorButton,
      ),
      const Icon(
        Icons.forum,
        size: 25,
        color: tNavBarColorButton,
      ),
    ];

    final screens = <Widget>[
      const HomePage(),
      const Explore(),
      const ForumPage(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          "Guardian Care",
          style: TextStyle(
              color: tPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 25,
              fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: screens[index],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        backgroundColor: Colors.transparent,
        color: tNavBarColor,
        height: 55,
        index: index,
        onTap: (newIndex) async {
          setState(() {
            index = newIndex;
          });

          // Check and show guidelines dialog if navigating to forum
          if (newIndex == 2) {
            await _checkAndShowGuidelines();
          }
        },
      ),
    );
  }
}
