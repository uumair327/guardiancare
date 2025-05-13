import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_service.dart';
import '../exceptions/auth_exception.dart';

class LoginController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();
  
  // Get current user
  User? getCurrentUser() => _authService.getCurrentUser();
  
  // Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;
  
  // Check if user is not authenticated
  bool get isNotAuthenticated => _authService.isNotAuthenticated;
  
  // Check if loading
  bool get isLoading => _authService.isLoading;
  
  // Stream of auth state changes
  Stream<User?> get userStream => _authService.authStateChanges;
  
  @override
  void onInit() {
    super.onInit();
  }
  
  // Check if user is logged in with email/password
  bool get isEmailUser => getCurrentUser()?.providerData.any((userInfo) => userInfo.providerId == 'password') ?? false;
  
  // Check if user is logged in with Google
  bool get isGoogleUser => getCurrentUser()?.providerData.any((userInfo) => userInfo.providerId == 'google.com') ?? false;
  
  // Upgrade guest to full account
  Future<UserCredential> upgradeGuestToFullAccount({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.linkWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.toAuthException();
    } on SocketException {
      throw AuthException.networkError();
    } on AuthException {
      rethrow;
    } catch (e) {
      developer.log('Upgrade guest account error', error: e);
      throw AuthException('An unexpected error occurred', code: 'unexpected-error');
    }
  }
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.toAuthException();
    } on SocketException {
      throw AuthException.networkError();
    } on AuthException {
      rethrow;
    } catch (e) {
      developer.log('Email sign in error', error: e);
      throw AuthException('An unexpected error occurred', code: 'unexpected-error');
    }
  }
  
  // Sign up with email and password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _authService.signUpWithEmail(
        email: email.trim(),
        password: password,
        displayName: displayName,
      );
      
      // Update user data in Firestore
      if (credential.user != null) {
        await _updateUserData(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e.toAuthException();
    } on SocketException {
      throw AuthException.networkError();
    } on AuthException {
      rethrow;
    } catch (e) {
      developer.log('Email sign up error', error: e);
      throw AuthException('An unexpected error occurred', code: 'unexpected-error');
    }
  }
  
  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      
      // Update user data in Firestore
      if (credential.user != null) {
        await _updateUserData(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e.toAuthException();
    } on SocketException {
      throw AuthException.networkError();
    } on AuthException {
      rethrow;
    } catch (e) {
      developer.log('Google sign in error', error: e);
      throw AuthException('An unexpected error occurred', code: 'unexpected-error');
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw e.toAuthException();
    } on SocketException {
      throw AuthException.networkError();
    } on AuthException {
      rethrow;
    } catch (e) {
      developer.log('Password reset error', error: e);
      throw AuthException('An unexpected error occurred', code: 'unexpected-error');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      developer.log('Sign out error', error: e);
      rethrow;
    }
  }
  
  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete the user account
        await user.delete();
      }
    } on FirebaseException catch (e) {
      throw AuthException(_getErrorMessage(e.code ?? ''), code: e.code);
    } on SocketException {
      throw AuthException.networkError();
    } on AuthException {
      rethrow;
    } catch (e) {
      developer.log('Delete account error', error: e);
      throw AuthException('An unexpected error occurred', code: 'unexpected-error');
    }
  }
  
  // Update user data in Firestore
  Future<void> _updateUserData(User user) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
        'emailVerified': user.emailVerified,
        'isAnonymous': user.isAnonymous,
        'metadata': {
          'creationTime': user.metadata.creationTime?.toIso8601String(),
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        },
        'providerData': user.providerData
            .map((info) => ({
                  'providerId': info.providerId,
                  'uid': info.uid,
                  'displayName': info.displayName,
                  'email': info.email,
                  'phoneNumber': info.phoneNumber,
                  'photoURL': info.photoURL,
                }))
            .toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(
            userData,
            SetOptions(merge: true),
          );
    } catch (e) {
      developer.log('Error updating user data', error: e);
      // Don't throw, as this is a non-critical operation
    }
  }
  
  // Get user-friendly error message from error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Please log in again.';
      case 'network-request-failed':
      case 'network_error':
        return 'A network error occurred. Please check your internet connection and try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'sign_in_cancelled':
        return 'Sign in was cancelled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
