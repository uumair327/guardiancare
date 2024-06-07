import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/routing/Pages.dart';
import 'package:guardiancare/src/routing/app_router.dart';
import 'package:guardiancare/src/screens/loginPage.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GuardianCare());
}

class guardiancare extends StatefulWidget {
  const guardiancare({super.key});

  @override
  State<guardiancare> createState() => _guardiancareState();
}

class _guardiancareState extends State<guardiancare> {
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

    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Children of India",
      home: _user != null ? const Pages() : const LoginPage(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
