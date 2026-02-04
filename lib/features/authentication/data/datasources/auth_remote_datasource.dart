import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/authentication/data/models/user_model.dart';

/// Abstract class defining authentication remote data source operations
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String role,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateUserProfile({String? displayName, String? photoURL});
}

/// Implementation of AuthRemoteDataSource using Firebase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException(ErrorStrings.withDetails(ErrorStrings.signInFailed, ErrorStrings.noUserReturned));
      }

      // Check if email is verified
      if (!credential.user!.emailVerified) {
        throw AuthException(
          ErrorStrings.emailNotVerified,
          code: 'email-not-verified',
        );
      }

      // Get user role from Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      final role = userDoc.data()?['role'] as String?;

      // Update email verified status in Firestore
      await firestore.collection('users').doc(credential.user!.uid).update({
        'emailVerified': true,
      });

      return UserModel.fromFirebaseUser(credential.user!, role: role);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.signInFailed, e.toString()));
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String role,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException(ErrorStrings.withDetails(ErrorStrings.signUpFailed, ErrorStrings.noUserReturned));
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Store user data in Firestore
      await firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'photoURL': null,
        'emailVerified': false,
      });

      return UserModel.fromFirebaseUser(credential.user!, role: role);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.signUpFailed, e.toString()));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(ErrorStrings.googleSignInCancelled);
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthException(ErrorStrings.withDetails(ErrorStrings.googleSignInFailed, ErrorStrings.noUserReturned));
      }

      // Check if user exists in Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      String? role;
      if (!userDoc.exists) {
        // New user - create Firestore document
        role = 'parent'; // Default role for Google sign in
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        role = userDoc.data()?['role'] as String?;
      }

      return UserModel.fromFirebaseUser(userCredential.user!, role: role);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } on PlatformException catch (e) {
      // Handle Google Sign-In specific errors
      if (e.code == 'sign_in_failed') {
        throw AuthException(
          'Google Sign-In failed. Please ensure:\n'
          '1. SHA-1 certificate is added to Firebase Console\n'
          '2. Google Sign-In is enabled in Firebase Authentication\n'
          '3. You have internet connection',
          code: e.code,
        );
      }
      throw AuthException(
        ErrorStrings.withDetails(ErrorStrings.googleSignInFailed, e.message ?? e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.googleSignInFailed, e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.signOutFailed, e.toString()));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      // Get user role from Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'] as String?;

      return UserModel.fromFirebaseUser(user, role: role);
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.getCurrentUserError, e.toString()));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.sendPasswordResetError, e.toString()));
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException(ErrorStrings.noUserSignedIn);
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Update Firestore
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;

      if (updates.isNotEmpty) {
        await firestore.collection('users').doc(user.uid).update(updates);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(ErrorStrings.withDetails(ErrorStrings.updateProfileError, e.toString()));
    }
  }

  /// Get user-friendly error messages for Firebase Auth error codes
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'email-not-verified':
        return 'Please verify your email address before signing in';
      default:
        return 'Authentication failed: $code';
    }
  }
}
