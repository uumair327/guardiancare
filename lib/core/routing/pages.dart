import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

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
      debugPrint("Error fetching consent data: $e");

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
      onForgotKey: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => const ForgotParentalKeyDialog(),
        );

        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You can now use your new parental key'),
              backgroundColor: AppColors.success,
            ),
          );
        }
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Forum Guidelines',
            style: AppTextStyles.dialogTitle,
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
              child: Text(
                'I Agree',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
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
      const Icon(Icons.home, size: 25, color: AppColors.navBarButton),
      const Icon(Icons.explore, size: 25, color: AppColors.navBarButton),
      const Icon(Icons.forum, size: 25, color: AppColors.navBarButton),
    ];

    final screens = <Widget>[
      BlocProvider(
        create: (_) => sl<HomeBloc>()..add(const LoadCarouselItems()),
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
          extendBody: false,
          appBar: AppBar(
            title: Text(
              AppStrings.appName,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
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
                      icon: const Icon(Icons.login, color: AppColors.primary),
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
          backgroundColor: AppColors.surface,
          body: SafeArea(
            bottom: false,
            child: screens[index],
          ),
          bottomNavigationBar: CurvedNavigationBar(
            key: _bottomNavigationKey,
            items: items,
            backgroundColor: Colors.transparent,
            color: AppColors.navBarBackground,
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
              color: AppColors.surface,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
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
                    color: AppColors.overlayDark,
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
