import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/constants/text_strings.dart';
import 'package:guardiancare/src/features/explore/screens/explore.dart';
import 'package:guardiancare/src/features/forum/screens/forum_page.dart';
import 'package:guardiancare/src/features/home/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:guardiancare/src/common_widgets/password_dialog.dart'; 

class Pages extends StatefulWidget {
  const Pages({Key? key}) : super(key: key);

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0;
  bool hasSeenForumGuidelines = false;
  
  @override
  void initState() {
    super.initState();
    _loadGuidelinesStatus();
  }

  Future<void> _loadGuidelinesStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasSeenForumGuidelines =
          prefs.getBool('has_seen_forum_guidelines') ?? false;
    });
  }

  Future<void> _checkAndShowPasswordAndGuidelines() async {
    if (index == 2) {
      // Show guidelines dialog if it's the first visit
      if (!hasSeenForumGuidelines) {
        await _showGuidelinesDialog();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_forum_guidelines', true);
        setState(() {
          hasSeenForumGuidelines = true;
        });
      }

      // Always show the password dialog on forum visit
      await _showPasswordDialog();
    }
  }

  Future<void> _showPasswordDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordDialog(
          onSubmit: (password) {
            if (password == tCorrectPassword) {
              Navigator.of(context).pop(); // Close the dialog
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Incorrect password!")),
              );
              setState(() {
                index = 0; // Navigate back to HomePage if password is incorrect
              });
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          onCancel: () {
            setState(() {
              index = 0; // Navigate back to HomePage if password is incorrect
            });
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      },
    );
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
                    'Welcome to the GuardianCare Global Forum. Kindly follow these guidelines:'),
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
      ForumPage(),
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

          // Check and show guidelines and password dialog if navigating to forum
          if (newIndex == 2) {
            await _checkAndShowPasswordAndGuidelines();
          }
        },
      ),
    );
  }
}
