import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/screens/pages/Pages.dart';
import 'package:guardiancare/screens/loginpage/loginPage.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GuardianCare());
}

class guardiancare extends StatelessWidget {
  const guardiancare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GuardianCare();
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
      title: "Gurdian Care",
      home: _user != null ? const Pages() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
