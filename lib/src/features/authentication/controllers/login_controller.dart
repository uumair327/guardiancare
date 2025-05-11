import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, {this.code = 'unknown'});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Show the account picker and get the selected account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Sign in was cancelled by user', code: 'sign_in_cancelled');
      }

      // Get the authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      
      if (user == null) {
        throw AuthException('Failed to sign in with Google', code: 'sign_in_failed');
      }

      // Check if user exists in Firestore, if not create a new document
      await _updateUserData(user, googleUser);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), code: e.code);
    } on SocketException {
      throw AuthException('No internet connection', code: 'network_error');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  // Update user data in Firestore
  Future<void> _updateUserData(User user, GoogleSignInAccount? googleUser) async {
    if (user.email == null) return;

    final userData = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? googleUser?.displayName ?? 'User',
      'photoURL': user.photoURL ?? googleUser?.photoUrl,
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
      'creationTime': user.metadata.creationTime?.toIso8601String(),
      'isAnonymous': user.isAnonymous,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userData, SetOptions(merge: true));
  }

  // Get user-friendly error message from error code
  String _getErrorMessage(String code) {
    switch (code) {
      // User related errors
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'invalid-email':
        return 'The email address is invalid';
      case 'email-already-in-use':
        return 'This email is already in use';
      case 'weak-password':
        return 'The password is too weak';
      case 'requires-recent-login':
        return 'Please log in again before retrying this operation';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential is malformed or has expired.';
      default:
        return 'An error occurred. Please try again';
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return true;
    } catch (e) {
      debugPrint('Error signing out: $e');
      return false;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in as guest
  Future<UserCredential> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await _updateUserData(userCredential.user!, null);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), code: e.code);
    } on SocketException {
      throw AuthException('No internet connection', code: 'network_error');
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  // Check if current user is a guest
  bool isGuestUser() {
    final user = _auth.currentUser;
    return user != null && user.isAnonymous;
  }

  // Upgrade guest to full account
  Future<UserCredential> upgradeGuestToFullAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || !user.isAnonymous) {
        throw AuthException('No guest user found');
      }

      // Create credential for the new account
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Link the credential to the anonymous account and return the UserCredential
      final userCredential = await user.linkWithCredential(credential);
      
      // Update user data in Firestore if needed
      if (userCredential.user?.email != null) {
        await _updateUserData(userCredential.user!, null);
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getErrorMessage(e.code), code: e.code);
    } catch (e) {
      throw AuthException('Failed to upgrade account: $e');
    }
  }
}