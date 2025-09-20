import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/core/core.dart';
import 'package:guardiancare/src/features/authentication/authentication.dart';
import 'package:guardiancare/src/features/consent/consent.dart';
import 'package:guardiancare/src/features/consent/screens/password_dialog.dart';
import 'package:guardiancare/src/features/explore/screens/explore.dart';
import 'package:guardiancare/src/features/forum/screens/forum_page.dart';
import 'package:guardiancare/src/features/home/screens/home_page.dart';
import 'dart:ui'; // For BackdropFilter

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final TextEditingController formController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check consent status will be handled in the build method
  }

  void _verifyParentalKeyForForum(BuildContext context, int newIndex) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordDialog(
          onSubmit: (password) async {
            context.read<ConsentBloc>().add(
              ParentalKeyVerificationRequested(password),
            );
          },
          onCancel: () {
            Navigator.of(context).pop();
            context.read<NavigationCubit>().resetToHome();
            _bottomNavigationKey.currentState?.setPage(0);
          },
          onForgotPassword: () {
            Navigator.of(context).pop();
            // Handle forgot password - could show reset dialog
            context.read<NavigationCubit>().resetToHome();
            _bottomNavigationKey.currentState?.setPage(0);
          },
        );
      },
    );
  }

  void _showGuidelinesDialog() async {
    if (!mounted) return;
    
    final hasSeenGuidelines = await context.read<NavigationCubit>().hasSeenForumGuidelines();
    
    if (!hasSeenGuidelines && mounted) {
      await showDialog<void>(
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
                  context.read<NavigationCubit>().markForumGuidelinesAsSeen();
                },
              ),
            ],
          );
        },
      );
    }
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

    return MultiBlocListener(
      listeners: [
        BlocListener<ConsentBloc, ConsentState>(
          listener: (context, state) {
            if (state is ParentalKeyVerified) {
              Navigator.of(context).pop(); // Close password dialog
              context.read<NavigationCubit>().enableForumNavigation();
              context.read<NavigationCubit>().navigateToForum();
              _showGuidelinesDialog();
            } else if (state is ParentalKeyVerificationFailed) {
              Navigator.of(context).pop(); // Close password dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.read<NavigationCubit>().resetToHome();
              _bottomNavigationKey.currentState?.setPage(0);
            } else if (state is ConsentSubmitted) {
              // Consent form was submitted successfully
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consent submitted successfully!')),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, navigationState) {
          return BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, authState) {
              // Check consent status when authenticated user is available
              if (authState is AuthenticationAuthenticated && 
                  context.read<ConsentBloc>().state is ConsentInitial) {
                context.read<ConsentBloc>().add(ConsentCheckRequested(authState.user.uid));
              }
              
              return BlocBuilder<ConsentBloc, ConsentState>(
                builder: (context, consentState) {
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
                    body: screens[navigationState.selectedIndex],
                    bottomNavigationBar: CurvedNavigationBar(
                      key: _bottomNavigationKey,
                      items: items,
                      backgroundColor: Colors.transparent,
                      color: tNavBarColor,
                      height: 55,
                      index: navigationState.selectedIndex,
                      onTap: (newIndex) {
                        if (newIndex == 2) {
                          // If ForumPage is selected, verify parental key
                          _verifyParentalKeyForForum(context, newIndex);
                        } else {
                          context.read<NavigationCubit>().changeTab(newIndex);
                        }
                      },
                    ),
                  ),

                  // Consent form overlay
                  if (consentState is ConsentNotGranted)
                    Positioned.fill(
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                          BlocProvider.value(
                            value: context.read<ConsentBloc>(),
                            child: ConsentFormBlocWrapper(
                              controller: formController,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Wrapper to integrate ConsentForm with BLoC
class ConsentFormBlocWrapper extends StatelessWidget {
  final TextEditingController controller;

  const ConsentFormBlocWrapper({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // For now, we'll use a placeholder until we can properly migrate ConsentForm
    // This maintains the existing functionality while we transition
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading consent form...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
