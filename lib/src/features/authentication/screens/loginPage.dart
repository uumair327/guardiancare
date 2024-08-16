import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:guardianscare/src/features/authentication/controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 120,
                  ), // Reduce height here
                ],
              ),
            ),
            const SizedBox(
                height: 10), // Adjust space between the first and second text
            const Text(
              'Welcome to Guardians Care',
              style: TextStyle(
                color: Color.fromRGBO(239, 72, 53, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 50,
                width: 250,
                child: SignInButton(
                  Buttons.google,
                  text: "Sign In With Google",
                  onPressed: () async {
                    UserCredential? userCredential = await signInWithGoogle();

                    if (userCredential != null) {
                      print("Signed in: ${userCredential.user?.displayName}");
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
