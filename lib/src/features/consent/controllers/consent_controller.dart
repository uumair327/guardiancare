import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

class ConsentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String hashParentalKey(String keyPhrase) {
    final bytes = utf8.encode(keyPhrase); // Convert string to bytes
    final hash = sha256.convert(bytes); // Perform SHA-256 hashing
    return hash.toString();
  }

  // Method to submit consent form data to Firestore
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
      // Ensure user is authenticated
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated.');
      }

      parentalKey = hashParentalKey(parentalKey);

      // Prepare the data to be saved in Firestore
      final formData = {
        'parentName': parentName,
        'parentEmail': parentEmail,
        'childName': childName,
        'isChildAbove12': isChildAbove12,
        'isParentConsentGiven': isParentConsentGiven,
        'parentalKey': parentalKey,
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
        'userEmail': user.email, // Include the current user's email
        '_Id': user.uid, // Associate the form with the current user
        'timestamp': FieldValue.serverTimestamp(),
      };

      print(formData);

      // Save the data to Firestore
      await _firestore.collection('consents').add(formData);
      print('Consent form data saved successfully.');

      return true;
    } catch (e) {
      throw Exception('Error saving consent data: $e');
    }
  }
}
