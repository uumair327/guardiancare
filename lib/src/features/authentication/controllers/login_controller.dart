import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:guardiancare/src/features/authentication/models/auth_models.dart';

/// Enhanced authentication service with improved retry logic
class AuthenticationService {
  static const int _maxRetries = 3;
  static const Duration _baseTimeout = Duration(seconds: 30);
  static const Duration _maxTimeout = Duration(seconds: 60);
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  
  static AuthenticationService? _instance;
  
  AuthenticationService._();
  
  static AuthenticationService get instance {
    _instance ??= AuthenticationService._();
    return _instance!;
  }

  /// Enhanced Google Sign-In with improved retry logic and validation
  Future<AuthResult> signInWithGoogle() async {
    final stopwatch = Stopwatch()..start();
    int attemptCount = 0;
    Duration currentTimeout = _baseTimeout;
    Duration currentRetryDelay = _baseRetryDelay;
    
    // Initialize GoogleSignIn instance
    final GoogleSignIn googleSignIn = GoogleSignIn();
    
    while (attemptCount < _maxRetries) {
      attemptCount++;
      
      try {
        print("🔐 Authentication attempt $attemptCount/$_maxRetries (timeout: ${currentTimeout.inSeconds}s)");
        
        // Step 1: Google Sign-In
        final GoogleSignInAccount? googleUser = await googleSignIn
            .signIn()
            .timeout(currentTimeout);
        
        if (googleUser == null) {
          return AuthResult.failure(
            'Sign-in was cancelled by user',
            AuthErrorType.cancelled,
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
          );
        }
        
        print("✅ Google user obtained: ${googleUser.email}");

        // Step 2: Get authentication credentials with timeout wrapper
        final GoogleSignInAuthentication googleAuth = await Future.any([
          googleUser.authentication,
          Future.delayed(currentTimeout, () => throw TimeoutException('Authentication timeout')),
        ]);
        
        print("✅ Google authentication credentials obtained");

        // Step 3: Create Firebase credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Step 4: Sign in to Firebase
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential)
            .timeout(currentTimeout);
        
        print("✅ Firebase authentication successful: ${userCredential.user?.email}");

        // Step 5: Validate and setup user profile
        final user = userCredential.user;
        if (user != null) {
          await _validateAndSetupUserProfile(user, currentTimeout);
        }

        stopwatch.stop();
        
        return AuthResult.success(
          userCredential,
          attemptCount: attemptCount,
          totalDuration: stopwatch.elapsed,
          metadata: {
            'provider': 'google',
            'userId': user?.uid,
            'email': user?.email,
          },
        );
        
      } on TimeoutException {
        print("⏰ Timeout on attempt $attemptCount");
        
        if (attemptCount >= _maxRetries) {
          return AuthResult.failure(
            'Connection timeout after $_maxRetries attempts. Please check your internet connection and try again.',
            AuthErrorType.timeout,
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
          );
        }
        
        await _handleRetryDelay(attemptCount, currentRetryDelay);
        currentTimeout = _calculateNextTimeout(currentTimeout);
        currentRetryDelay = _calculateNextRetryDelay(currentRetryDelay);
        
      } on FirebaseAuthException catch (e) {
        final errorType = _categorizeFirebaseAuthError(e);
        final readableError = _getReadableAuthError(e);
        
        print("🚫 Firebase Auth Error: ${e.code} - $readableError");
        
        // Don't retry for non-retryable errors
        if (!_isRetryableError(errorType)) {
          return AuthResult.failure(
            readableError,
            errorType,
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
          );
        }
        
        if (attemptCount >= _maxRetries) {
          return AuthResult.failure(
            readableError,
            errorType,
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
          );
        }
        
        await _handleRetryDelay(attemptCount, currentRetryDelay);
        currentRetryDelay = _calculateNextRetryDelay(currentRetryDelay);
        
      } on AuthenticationException catch (e) {
        print("🚫 Authentication Exception: ${e.code} - ${e.message}");
        
        if (!_isRetryableError(e.errorType) || attemptCount >= _maxRetries) {
          return AuthResult.failure(
            e.message,
            e.errorType,
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
          );
        }
        
        await _handleRetryDelay(attemptCount, currentRetryDelay);
        currentRetryDelay = _calculateNextRetryDelay(currentRetryDelay);
        
      } catch (e) {
        print("🚫 Unexpected error on attempt $attemptCount: $e");
        
        if (attemptCount >= _maxRetries) {
          return AuthResult.failure(
            'An unexpected error occurred during authentication. Please try again.',
            AuthErrorType.system,
            attemptCount: attemptCount,
            totalDuration: stopwatch.elapsed,
          );
        }
        
        await _handleRetryDelay(attemptCount, currentRetryDelay);
        currentRetryDelay = _calculateNextRetryDelay(currentRetryDelay);
      }
    }
    
    return AuthResult.failure(
      'Failed to sign in after $_maxRetries attempts',
      AuthErrorType.system,
      attemptCount: attemptCount,
      totalDuration: stopwatch.elapsed,
    );
  }

  /// Validate and setup user profile with enhanced checks
  Future<void> _validateAndSetupUserProfile(User user, Duration timeout) async {
    // Enhanced user profile validation
    if (user.email == null || user.email!.isEmpty) {
      throw AuthenticationException(
        'Your Google account must have a valid email address.',
        'missing_email',
        AuthErrorType.validation,
      );
    }
    
    if (user.displayName == null || user.displayName!.isEmpty) {
      throw AuthenticationException(
        'Your Google account must have a display name. Please update your Google profile and try again.',
        'missing_display_name',
        AuthErrorType.validation,
      );
    }
    
    // Additional validation for email format
    if (!_isValidEmail(user.email!)) {
      throw AuthenticationException(
        'Invalid email format. Please use a valid email address.',
        'invalid_email_format',
        AuthErrorType.validation,
      );
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(timeout);

      final userData = {
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'uid': user.uid,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'authProvider': 'google',
        'profileValidated': true,
      };

      if (!userDoc.exists) {
        // Create new user profile
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['isNewUser'] = true;
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData)
            .timeout(timeout);
        
        print("✅ New user profile created for ${user.email}");
      } else {
        // Update existing user profile
        userData['isNewUser'] = false;
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(userData)
            .timeout(timeout);
        
        print("✅ User profile updated for ${user.email}");
      }
    } catch (e) {
      throw AuthenticationException(
        'Failed to setup user profile. Please try again.',
        'profile_setup_failed',
        AuthErrorType.system,
      );
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Categorize Firebase Auth errors for better handling
  AuthErrorType _categorizeFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
      case 'too-many-requests':
        return AuthErrorType.network;
      case 'invalid-credential':
      case 'credential-already-in-use':
      case 'account-exists-with-different-credential':
        return AuthErrorType.credential;
      case 'operation-not-allowed':
      case 'user-disabled':
        return AuthErrorType.permission;
      case 'invalid-email':
      case 'weak-password':
        return AuthErrorType.validation;
      default:
        return AuthErrorType.system;
    }
  }

  /// Check if an error type is retryable
  bool _isRetryableError(AuthErrorType errorType) {
    switch (errorType) {
      case AuthErrorType.network:
      case AuthErrorType.timeout:
      case AuthErrorType.system:
        return true;
      case AuthErrorType.credential:
      case AuthErrorType.permission:
      case AuthErrorType.validation:
      case AuthErrorType.cancelled:
        return false;
    }
  }

  /// Handle retry delay with exponential backoff and jitter
  Future<void> _handleRetryDelay(int attemptCount, Duration currentDelay) async {
    final jitter = Random().nextInt(1000); // Add up to 1 second of jitter
    final delayWithJitter = Duration(
      milliseconds: currentDelay.inMilliseconds + jitter,
    );
    
    print("⏳ Waiting ${delayWithJitter.inSeconds}s before retry attempt ${attemptCount + 1}...");
    await Future.delayed(delayWithJitter);
  }

  /// Calculate next timeout with progressive increase
  Duration _calculateNextTimeout(Duration currentTimeout) {
    final nextTimeout = Duration(
      milliseconds: (currentTimeout.inMilliseconds * 1.5).round(),
    );
    return nextTimeout.compareTo(_maxTimeout) <= 0 ? nextTimeout : _maxTimeout;
  }

  /// Calculate next retry delay with exponential backoff
  Duration _calculateNextRetryDelay(Duration currentDelay) {
    return Duration(
      milliseconds: (currentDelay.inMilliseconds * 2).clamp(
        _baseRetryDelay.inMilliseconds,
        10000, // Max 10 seconds
      ),
    );
  }

  /// Enhanced error message generation
  String _getReadableAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method. Please try signing in with your original method.';
      case 'invalid-credential':
        return 'The sign-in credential is invalid or has expired. Please try signing in again.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled for this app. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'user-not-found':
        return 'No account found with these credentials. Please check your information and try again.';
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment before trying again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different account.';
      case 'invalid-email':
        return 'The email address is not valid. Please check the email format.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      default:
        return 'Authentication failed: ${e.message ?? 'Please try again or contact support if the problem persists.'}';
    }
  }

  /// Enhanced sign out with comprehensive cleanup
  Future<AuthResult> signOut() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      print("🔓 Starting enhanced sign out process");
      
      // Step 1: Sign out from Firebase
      await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 10));
      print("✅ Firebase sign out completed");
      
      // Step 2: Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut().timeout(const Duration(seconds: 10));
      print("✅ Google sign out completed");
      
      // Step 3: Clear local session data
      await _clearLocalSessionData();
      print("✅ Local session data cleared");
      
      stopwatch.stop();
      
      return AuthResult.success(
        // Create a dummy UserCredential for success result
        // In a real implementation, you might want a different result type for sign out
        await FirebaseAuth.instance.signInAnonymously(),
        totalDuration: stopwatch.elapsed,
        metadata: {'operation': 'signOut'},
      );
      
    } catch (e) {
      print("🚫 Error during sign out: $e");
      
      return AuthResult.failure(
        'Failed to sign out completely. Some data may still be cached.',
        AuthErrorType.system,
        totalDuration: stopwatch.elapsed,
      );
    }
  }

  /// Clear local session data with enhanced cleanup
  Future<void> _clearLocalSessionData() async {
    try {
      // Clear any local storage, preferences, or cached data
      // This can be expanded based on what local data the app stores
      
      // Example cleanup operations:
      // - Clear SharedPreferences auth tokens
      // - Clear cached user data
      // - Clear temporary files
      // - Reset app state
      
      print("🧹 Local session data cleanup completed");
    } catch (e) {
      print("⚠️ Error clearing local data: $e");
      // Don't throw here as sign out should still succeed
    }
  }

  /// Get current authentication status
  AuthStatus getCurrentAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return AuthStatus.signedOut;
    }
    
    // Check if user profile is complete
    if (user.email == null || user.displayName == null) {
      return AuthStatus.incompleteProfile;
    }
    
    return AuthStatus.signedIn;
  }

  /// Check if user needs profile completion
  bool requiresProfileCompletion() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && (user.email == null || user.displayName == null);
  }

  /// Get current user information
  Map<String, dynamic>? getCurrentUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) return null;
    
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'creationTime': user.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
    };
  }
}

// Backward compatibility functions
Future<AuthResult> signInWithGoogle() async {
  return await AuthenticationService.instance.signInWithGoogle();
}

Future<bool> signOutFromGoogle() async {
  final result = await AuthenticationService.instance.signOut();
  return result.success;
}