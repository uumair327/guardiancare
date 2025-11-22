import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/pages/login_page.dart';
import 'package:guardiancare/features/authentication/presentation/pages/signup_page.dart';
import 'package:guardiancare/features/authentication/presentation/pages/password_reset_page.dart';
import 'package:guardiancare/src/routing/pages.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/core/services/parental_verification_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const guardiancareApp());
}

class guardiancareApp extends StatelessWidget {
  const guardiancareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const guardiancare();
  }
}

class guardiancare extends StatefulWidget {
  const guardiancare({super.key});

  @override
  State<guardiancare> createState() => _guardiancareState();
}

class _guardiancareState extends State<guardiancare> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _verificationService = ParentalVerificationService();
  User? _user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      // Reset verification when user logs out
      if (user == null) {
        _verificationService.resetVerification();
      }
    });
    print("I am the user: $_user");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reset verification when app is paused/closed
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _verificationService.resetVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp(
        title: "Guardian Care",
        home: StreamBuilder<User?>(
          stream: _auth.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text("Error: ${snapshot.error}"),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.active) {
              print("Snapshot Data is: ${snapshot.data ?? 'No data'}");

              if (snapshot.data == null) {
                return const LoginPage();
              } else {
                return const Pages();
              }
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/password-reset': (context) => const PasswordResetPage(),
          '/home': (context) => const Pages(),
        },
        debugShowCheckedModeBanner: false, //debug symbol remove
      ),
    );
  }
}
