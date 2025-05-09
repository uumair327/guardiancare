import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '331315801686-f57icrckmccqe3mu1airrgtpvho4lcva.apps.googleusercontent.com'
        : '331315801686-01tinu5ukqe35u4ivvn3fqo4ju59pp1d.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In process...');

      if (kIsWeb) {
        // For web platform
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Add scopes
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // Sign in with popup
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        print('Firebase Sign In successful: ${userCredential.user?.email}');
        print('Firebase User ID: ${userCredential.user?.uid}');

        // Save user data to Firestore
        await _saveUserData(userCredential.user!);
        print('User data saved to Firestore');

        return userCredential;
      } else {
        // For mobile platforms
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('Google Sign In was canceled by user');
          return null;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        print('Got Google Auth tokens');

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        print('Firebase Sign In successful: ${userCredential.user?.email}');
        print('Firebase User ID: ${userCredential.user?.uid}');

        // Save user data to Firestore
        await _saveUserData(userCredential.user!);
        print('User data saved to Firestore');

        return userCredential;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
        print('Firebase Auth Error Details: ${e.toString()}');
      }
      rethrow;
    }
  }

  // Sign in as guest
  Future<UserCredential?> signInAsGuest() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      await _saveUserData(userCredential.user!, isGuest: true);
      return userCredential;
    } catch (e) {
      print('Error signing in as guest: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User user, {bool isGuest = false}) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'isGuest': isGuest,
        'lastSignInTime': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }
}
