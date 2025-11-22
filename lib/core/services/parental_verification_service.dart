import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service to manage parental verification state for the current session
class ParentalVerificationService {
  static final ParentalVerificationService _instance = ParentalVerificationService._internal();
  factory ParentalVerificationService() => _instance;
  ParentalVerificationService._internal();

  // Session state - resets when app closes
  bool _isVerifiedForSession = false;

  /// Check if parental key has been verified in this session
  bool get isVerifiedForSession => _isVerifiedForSession;

  /// Verify parental key against Firestore
  Future<bool> verifyParentalKey(String enteredKey) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final doc = await FirebaseFirestore.instance
          .collection('consents')
          .doc(user.uid)
          .get();

      if (!doc.exists) return false;

      final storedHash = doc.data()?['parentalKey'] as String?;
      if (storedHash == null) return false;

      final enteredHash = _hashString(enteredKey);

      if (storedHash == enteredHash) {
        // Mark as verified for this session
        _isVerifiedForSession = true;
        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying parental key: $e');
      return false;
    }
  }

  /// Reset verification state (called when app closes or user logs out)
  void resetVerification() {
    _isVerifiedForSession = false;
  }

  /// Hash string using SHA-256
  String _hashString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }
}
