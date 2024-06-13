import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((event) {
      setState(() {});
    });
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithProvider(googleAuthProvider);
      final User? user = userCredential.user;
      if (user != null) {
        // Update state with the signed-in user
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/logo/logo_CIF.jpg', // Replace with your logo image path
                width: 150,
              ),
            ),
            // Title
            const Text(
              'Welcome to Children of India',
              style: TextStyle(
                color: Color.fromRGBO(239, 72, 53, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Sign in with Google button
            SizedBox(
              height: 50,
              width: 250,
              child: SignInButton(
                Buttons.google,
                text: "Sign In With Google",
                onPressed: _handleGoogleSignIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
