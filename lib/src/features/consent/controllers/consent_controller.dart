import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/consent/screens/password_dialog.dart';
import 'package:guardiancare/src/features/consent/screens/reset_parental_key.dart';

class ConsentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hash the parental key using SHA-256
  String hashParentalKey(String keyPhrase) {
    final bytes = utf8.encode(keyPhrase); // Convert string to bytes
    final hash = sha256.convert(bytes); // Perform SHA-256 hashing
    return hash.toString();
  }

  String hashSecurityAnswer(String answer) {
    final bytes = utf8.encode(answer.toLowerCase());
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Submit consent form data to Firestore
  Future<bool> submitConsentForm({
    required String parentName,
    required String parentEmail,
    required String childName,
    required String parentalKey,
    required String securityQuestion,
    required String securityAnswer,
    required bool isChildAbove12,
    required bool isParentConsentGiven,
  }) async {
    try {
      User? user = _auth.currentUser;

      // Ensure user is authenticated
      if (user == null || user.email == null || user.displayName == null) {
        throw Exception('User is not authenticated or lacks profile details.');
      }

      // Prepare the data to be saved in Firestore
      final formData = {
        'parentName': parentName,
        'parentEmail': parentEmail,
        'childName': childName,
        'isChildAbove12': isChildAbove12,
        'isParentConsentGiven': isParentConsentGiven,
        'parentalKey': hashParentalKey(parentalKey),
        'securityQuestion': securityQuestion,
        'securityAnswer': hashSecurityAnswer(securityAnswer),
        'userEmail': user.email, // Include the current user's email
        'userName': user.displayName,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // print(formData);

      // Save the data to Firestore
      await _firestore
          .collection('consents')
          .doc(user.uid)
          .set(formData, SetOptions(merge: true));
      print('Consent form data saved successfully.');

      return true;
    } catch (e) {
      throw Exception('Error saving consent data: $e');
    }
  }

  // Fetch and verify the parental key from Firestore
  Future<bool> matchParentalKey(String enteredKey) async {
    try {
      User? user = _auth.currentUser;

      // Ensure user is authenticated
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      final consentDoc =
          await _firestore.collection('consents').doc(user.uid).get();

      if (!consentDoc.exists) {
        throw Exception('No consent data found for the user.');
      }

      // Get the hashed parental key from Firestore
      final storedHash = consentDoc.get('parentalKey');

      // Hash the entered key and compare
      final enteredHash = hashParentalKey(enteredKey);
      return storedHash == enteredHash;
    } catch (e) {
      throw Exception('Error verifying parental key: $e');
    }
  }

  // Verify parental key and execute callback on success
  Future<void> verifyParentalKey(
      BuildContext context, VoidCallback onSuccess) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordDialog(
          onSubmit: (password) async {
            try {
              // Match the entered password with the stored hash
              bool isMatch = await matchParentalKey(password);

              if (isMatch) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Close the dialog
                onSuccess(); // Execute the callback if the password is correct
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect password!")),
                );
                Navigator.of(context).pop(); // Close the dialog
              }
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.toString()}")),
              );
              Navigator.of(context).pop(); // Close the dialog
            }
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          onForgotPassword: () {
            // Close PasswordDialog and show ResetPasswordDialog
            Navigator.of(context).pop();
            _showResetParentalKeyDialog(context);
          },
        );
      },
    );
  }

  // Show the Reset Password dialog
  void _showResetParentalKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ResetPasswordDialog(
          onSubmit: (answer, newPassword) async {
            // Implement logic to verify security question and answer and update password
            await resetParentalKey(answer, newPassword);

            // ignore: use_build_context_synchronously
            Navigator.of(context).pop(); // Close dialog

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password reset successfully!")),
            );
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  // Logic to handle password reset (verify security question and update password)
  Future<void> resetParentalKey(String answer, String newPassword) async {
    try {
      // Ensure the user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      final consentDocRef = _firestore.collection('consents').doc(user.uid);
      final consentDoc = await consentDocRef.get();

      if (!consentDoc.exists) {
        throw Exception('No consent data found for the user.');
      }

      String storedAnswerHash = consentDoc.get('securityAnswer');
      String enteredAnswerHash = hashSecurityAnswer(answer);

      if (storedAnswerHash != enteredAnswerHash) {
        throw Exception('The provided answer does not match the stored security answer.');
      }

      // Hash the new parental key
      String hashedNewPassword = hashParentalKey(newPassword);

      // Update the parental key in Firestore
      await consentDocRef.update({
        'parentalKey': hashedNewPassword,
      });

      print('Parental key updated successfully.');
    } catch (e) {
      throw Exception('Error resetting parental key: $e');
    }
  }

  Future<void> verifyParentalKeyWithError(
    BuildContext context, {
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordDialog(
          onSubmit: (password) async {
            try {
              bool isMatch = await matchParentalKey(password);

              if (isMatch) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Close the dialog
                onSuccess();
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect password!")),
                );
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // Close the dialog
                onError(); // Call error callback
              }
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.toString()}")),
              );
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(); // Close the dialog
              onError(); // Call error callback
            }
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close the dialog
            onError(); // Call error callback on cancel
          },
          onForgotPassword: () {
            Navigator.of(context).pop();
            _showResetParentalKeyDialog(context);
            onError(); // Call error callback when showing reset dialog
          },
        );
      },
    );
  }
}

/// Validation for Parental Key
String? validateParentalKey(String? key) {
  if (key == null || key.isEmpty) return 'Parental Key is required';
  if (key.length < 8) return 'Key must be at least 8 characters long';

  List<String> errors = [];
  if (!key.contains(RegExp(r'[A-Z]'))) errors.add('an uppercase letter');
  if (!key.contains(RegExp(r'[a-z]'))) errors.add('a lowercase letter');
  if (!key.contains(RegExp(r'[0-9]'))) errors.add('a number');
  if (!key.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:]'))) errors.add('a special character');

  if (errors.isNotEmpty) {
    return 'Key must include ${errors.join(', ')}.';
  }
  return null;
}
