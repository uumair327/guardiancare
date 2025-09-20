import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/common_widgets/web_view_page.dart';
import 'package:guardiancare/src/features/consent/consent.dart';
import 'package:guardiancare/src/features/emergency/screens/emergency_contact_page.dart';
import 'package:guardiancare/src/features/home/home.dart';
import 'package:guardiancare/src/features/home/widgets/circular_button.dart';
import 'package:guardiancare/src/features/home/widgets/home_carousel.dart';
import 'package:guardiancare/src/features/learn/screens/video_page.dart';
import 'package:guardiancare/src/features/profile/screens/account.dart';
import 'package:guardiancare/src/features/quiz/screens/quiz_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double carouselHeight;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    // Request carousel data through BLoC
    context.read<HomeBloc>().add(const HomeCarouselRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carouselHeight = MediaQuery.of(context).size.height / 3;
  }

  void _verifyParentalKeyAndNavigate(VoidCallback onSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: context.read<ConsentBloc>(),
          child: BlocListener<ConsentBloc, ConsentState>(
            listener: (context, state) {
              if (state is ParentalKeyVerified) {
                Navigator.of(context).pop();
                onSuccess();
              } else if (state is ParentalKeyVerificationFailed) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Parental Verification Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please enter your parental key to continue:'),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Parental Key',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<ConsentBloc>().add(
                          ParentalKeyVerificationRequested(value),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(const HomeCarouselRefreshRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 5.0),
                BlocBuilder<HomeBloc, HomeState>(
                  buildWhen: (previous, current) {
                    // Only rebuild when state type changes or data changes
                    return previous.runtimeType != current.runtimeType ||
                           (current is HomeCarouselLoaded && previous is HomeCarouselLoaded &&
                            current.carouselItems != previous.carouselItems);
                  },
                  builder: (context, state) {
                    if (state is HomeLoading) {
                      return SizedBox(
                        height: carouselHeight,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is HomeCarouselLoaded) {
                      // Convert CarouselItem objects to the format expected by HomeCarousel
                      final carouselData = state.carouselItems
                          .where((item) => item.imageUrl != null && item.link != null)
                          .map((item) => {
                                'type': item.type,
                                'imageUrl': item.imageUrl,
                                'link': item.link,
                                'thumbnailUrl': item.thumbnailUrl,
                                'content': item.content,
                              })
                          .toList();
                      
                      return HomeCarousel(
                        carouselData: carouselData,
                        carouselHeight: carouselHeight,
                      );
                    } else if (state is HomeCarouselEmpty) {
                      return SizedBox(
                        height: carouselHeight,
                        child: const Center(
                          child: Text(
                            'No carousel items available',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    } else if (state is HomeError) {
                      return SizedBox(
                        height: carouselHeight,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: ${state.message}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<HomeBloc>().add(
                                    const HomeCarouselRequested(),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Default case
                    return SizedBox(
                      height: carouselHeight,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
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
                              label: 'Quiz',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizPage(),
                                  ),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.video_library,
                              label: 'Learn',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const VideoPage(),
                                  ),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.emergency,
                              label: 'Emergency',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EmergencyContactPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircularButton(
                              iconData: Icons.person,
                              label: 'Profile',
                              onPressed: () {
                                _verifyParentalKeyAndNavigate(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Account(user: _user),
                                    ),
                                  );
                                });
                              },
                            ),
                            CircularButton(
                              iconData: CupertinoIcons.globe,
                              label: 'Website',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WebViewPage(
                                        url: "https://childrenofindia.in/"),
                                  ),
                                );
                              },
                            ),
                            CircularButton(
                              iconData: Icons.email,
                              label: 'Mail Us',
                              onPressed: () {
                                _verifyParentalKeyAndNavigate(() async {
                                  final Uri emailLaunchUri = Uri(
                                    scheme: 'mailto',
                                    path: 'hello@childrenofindia.in',
                                  );
                                  // ignore: deprecated_member_use
                                  if (await canLaunch(emailLaunchUri.toString())) {
                                    // ignore: deprecated_member_use
                                    await launch(emailLaunchUri.toString());
                                  } else {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Could not launch email client"),
                                      ),
                                    );
                                  }
                                });
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
      ),
    );
  }
}
