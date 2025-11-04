import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Custom exception classes for better error handling
class AuthenticationException implements Exception {
  final String message;
  final String code;
  
  AuthenticationException(this.message, this.code);
  
  @override
  String toString() => message;
}

class AuthResult {
  final bool success;
  final String? error;
  final UserCredential? userCredential;
  
  AuthResult.success(this.userCredential) : success = true, error = null;
  AuthResult.failure(this.error) : success = false, userCredential = null;
}

Future<AuthResult> signInWithGoogle() async {
  const int maxRetries = 3;
  const Duration timeout = Duration(seconds: 30);
  
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      print("Authentication attempt $attempt/$maxRetries");
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn()
          .signIn()
          .timeout(timeout);
      
      if (googleUser == null) {
        return AuthResult.failure('Sign-in was cancelled by user');
      }
      
      print("Google user obtained: ${googleUser.email}");

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication.timeout(timeout);
      
      if (googleAuth == null) {
        return AuthResult.failure('Failed to get authentication credentials');
      }
      
      print("Google authentication obtained");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential)
          .timeout(timeout);
      
      print("Firebase authentication successful: ${userCredential.user?.email}");

      final user = userCredential.user;
      if (user != null) {
        // Validate user profile completeness
        if (user.email == null || user.displayName == null) {
          throw AuthenticationException(
            'Incomplete user profile. Please ensure your Google account has a name and email.',
            'incomplete_profile'
          );
        }

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(timeout);

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          }).timeout(timeout);
          
          print("New user profile created");
        } else {
          // Update last login time
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'lastLoginAt': FieldValue.serverTimestamp(),
          }).timeout(timeout);
          
          print("User login time updated");
        }
      }

      return AuthResult.success(userCredential);
      
    } on TimeoutException {
      if (attempt == maxRetries) {
        return AuthResult.failure('Connection timeout. Please check your internet connection and try again.');
      }
      print("Timeout on attempt $attempt, retrying...");
      await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
      
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getReadableAuthError(e));
      
    } on AuthenticationException catch (e) {
      return AuthResult.failure(e.message);
      
    } catch (e) {
      if (attempt == maxRetries) {
        print("Error signing in with Google: $e");
        return AuthResult.failure('An unexpected error occurred. Please try again.');
      }
      print("Error on attempt $attempt: $e, retrying...");
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  
  return AuthResult.failure('Failed to sign in after $maxRetries attempts');
}

String _getReadableAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'account-exists-with-different-credential':
      return 'An account already exists with a different sign-in method.';
    case 'invalid-credential':
      return 'The credential is invalid or has expired.';
    case 'operation-not-allowed':
      return 'Google sign-in is not enabled. Please contact support.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'user-not-found':
      return 'No account found. Please sign up first.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'network-request-failed':
      return 'Network error. Please check your connection and try again.';
    default:
      return 'Authentication failed: ${e.message ?? 'Unknown error'}';
  }
}

Future<bool> signOutFromGoogle() async {
  try {
    print("Starting sign out process");
    
    // Clear all authentication providers
    await Future.wait([
      FirebaseAuth.instance.signOut(),
      GoogleSignIn().signOut(),
    ], eagerError: false);
    
    // Clear any cached data (if needed)
    await _clearLocalSessionData();
    
    print("Sign out completed successfully");
    return true;
    
  } catch (e) {
    print("Error signing out: $e");
    return false;
  }
}

Future<void> _clearLocalSessionData() async {
  // Clear any local storage, preferences, or cached data
  // This can be expanded based on what local data the app stores
  try {
    // Add any local data clearing logic here
    print("Local session data cleared");
  } catch (e) {
    print("Error clearing local data: $e");
  }
}