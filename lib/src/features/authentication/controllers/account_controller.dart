// controllers/account_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/screens/loginPage.dart';

class AccountController {
  static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out. Please try again.'),
          ),
        );
      }
    } catch (error) {
      print(error);
    }
  }
}
