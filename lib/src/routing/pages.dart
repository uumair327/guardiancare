import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/screens/consent_form.dart';
import 'package:guardiancare/src/features/explore/screens/explore.dart';
import 'package:guardiancare/src/features/forum/screens/forum_page.dart';
import 'package:guardiancare/src/features/home/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // For BackdropFilter

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  int index = 0;
  bool hasSeenConsent = false;
  bool isConsentFormVisible = true;

  final ConsentController _consentController = ConsentController();
  final TextEditingController formController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndShowConsent();
  }

  Future<void> _checkAndShowConsent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasSeenConsent = prefs.getBool('has_seen_consent') ?? false;

    if (!hasSeenConsent) {
      setState(() {
        isConsentFormVisible = !hasSeenConsent;
      });
    }
  }

  void submitConsent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('has_seen_consent', true);

    setState(() {
      isConsentFormVisible = false;
    });
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
            items: items,
            backgroundColor: Colors.transparent,
            color: tNavBarColor,
            height: 55,
            index: index,
            onTap: (newIndex) async {
              setState(() {
                index = newIndex;
              });
            },
          ),
        ),

        // Consent form overlay
        if (isConsentFormVisible)
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
                  onSubmit:
                      submitConsent, // This just hides the form, the logic is handled inside ConsentForm
                ),
              ],
            ),
          ),
      ],
    );
  }
}
