import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/authentication/screens/loginPage.dart';
import 'package:guardiancare/src/routing/Pages.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const GuardianCareApp());
}

class GuardianCareApp extends StatelessWidget {
  const GuardianCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GuardianCare();
  }
}

class GuardianCare extends StatefulWidget {
  const GuardianCare({super.key});

  @override
  State<GuardianCare> createState() => _GuardianCareState();
}

class _GuardianCareState extends State<GuardianCare> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Children of India",
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
      debugShowCheckedModeBanner: false, //debug symbol remove
    );
  }
}
