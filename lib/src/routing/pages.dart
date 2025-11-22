import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_bloc.dart';
import 'package:guardiancare/features/consent/presentation/pages/enhanced_consent_form_page.dart';
import 'package:guardiancare/features/consent/presentation/widgets/forgot_parental_key_dialog.dart';
import 'package:guardiancare/core/widgets/parental_verification_dialog.dart';
import 'package:guardiancare/core/services/parental_verification_service.dart';
import 'package:guardiancare/features/explore/presentation/bloc/explore_bloc.dart';
import 'package:guardiancare/features/explore/presentation/pages/explore_page.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/forum/presentation/pages/forum_page.dart';
import 'package:guardiancare/features/home/presentation/bloc/home_bloc.dart';
import 'package:guardiancare/features/home/presentation/pages/home_page.dart';
import 'dart:ui'; // For BackdropFilter
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
  bool isCheckingConsent = true; // Add loading state
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
  }

  Future<void> _checkAndShowConsent() async {
    try {
      // Get the current user's ID from FirebaseAuth
      final String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        // If no user is logged in, default `hasSeenConsent` to false
        setState(() {
          hasSeenConsent = false;
          isCheckingConsent = false;
        });

        return;
      }

      // Check if the user's document exists in the 'consents' collection
      DocumentSnapshot consentDoc =
          await _firestore.collection('consents').doc(userId).get();

      setState(() {
        hasSeenConsent = consentDoc.exists; // true if the document exists
        isCheckingConsent = false; // Done checking
      });
    } catch (e) {
      print("Error fetching consent data: $e");

      setState(() {
        hasSeenConsent = false; // Default to false if there's an error
        isCheckingConsent = false;
      });
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
  
  void _verifyParentalKeyForForumOld(BuildContext context, int newIndex) async {
    // Show dialog to verify parental key
    final TextEditingController keyController = TextEditingController();
    bool obscureKey = true;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.lock, color: tPrimaryColor),
              SizedBox(width: 12),
              Text('Parental Verification'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your parental key to access the forum',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  labelText: 'Parental Key',
                  hintText: 'Enter your key',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key, color: tPrimaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(obscureKey ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setDialogState(() {
                        obscureKey = !obscureKey;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.text,
                obscureText: obscureKey,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (context) => const ForgotParentalKeyDialog(),
                    );
                    if (result == true) {
                      // Key was reset successfully
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You can now use your new parental key'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Forgot Key?',
                    style: TextStyle(color: tPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                setState(() {
                  index = 0;
                });
                _bottomNavigationKey.currentState?.setPage(0);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = keyController.text;
                if (key.length >= 4) {
                  // Verify key from Firestore
                  try {
                    final user = _auth.currentUser;
                    if (user != null) {
                      final doc = await _firestore
                          .collection('consents')
                          .doc(user.uid)
                          .get();
                      
                      if (doc.exists) {
                        final storedHash = doc.data()?['parentalKey'] as String?;
                        final enteredHash = _hashKey(key);
                        
                        if (storedHash == enteredHash) {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            index = newIndex;
                          });
                          _checkAndShowGuidelines();
                        } else {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid parental key'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          setState(() {
                            index = 0;
                          });
                          _bottomNavigationKey.currentState?.setPage(0);
                        }
                      }
                    }
                  } catch (e) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() {
                      index = 0;
                    });
                    _bottomNavigationKey.currentState?.setPage(0);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Key must be at least 4 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimaryColor,
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
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
      BlocProvider(
        create: (_) => sl<HomeBloc>(),
        child: const HomePage(),
      ),
      BlocProvider(
        create: (_) => sl<ExploreBloc>(),
        child: const ExplorePage(),
      ),
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

        // Loading indicator while checking consent
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

        // Consent form overlay
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
