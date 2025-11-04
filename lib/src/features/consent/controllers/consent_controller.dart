import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/consent/screens/enhanced_password_dialog.dart';
import 'package:guardiancare/src/features/consent/screens/enhanced_reset_dialog.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

// Custom exception for parental control errors
class ParentalControlException implements Exception {
  final String message;
  final String code;
  
  ParentalControlException(this.message, this.code);
  
  @override
  String toString() => message;
}

/// Result of parental key verification with detailed error information
class ParentalVerificationResult {
  final bool success;
  final String? errorMessage;
  final ParentalVerificationErrorType? errorType;
  final int? failedAttempts;
  final int? attemptsRemaining;
  final Duration? remainingLockoutTime;

  const ParentalVerificationResult._({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.failedAttempts,
    this.attemptsRemaining,
    this.remainingLockoutTime,
  });

  factory ParentalVerificationResult.success() {
    return const ParentalVerificationResult._(success: true);
  }

  factory ParentalVerificationResult.failure(
    String message,
    ParentalVerificationErrorType errorType, {
    int? failedAttempts,
    int? attemptsRemaining,
    Duration? remainingLockoutTime,
  }) {
    return ParentalVerificationResult._(
      success: false,
      errorMessage: message,
      errorType: errorType,
      failedAttempts: failedAttempts,
      attemptsRemaining: attemptsRemaining,
      remainingLockoutTime: remainingLockoutTime,
    );
  }

  bool get isLockedOut => errorType == ParentalVerificationErrorType.lockedOut;
  bool get hasWarning => failedAttempts != null && failedAttempts! > 0 && !isLockedOut;
}

/// Types of parental verification errors
enum ParentalVerificationErrorType {
  incorrectKey,
  lockedOut,
  authenticationError,
  systemError,
}

/// Result of security question verification
class SecurityQuestionResult {
  final bool success;
  final String? errorMessage;

  const SecurityQuestionResult._({
    required this.success,
    this.errorMessage,
  });

  factory SecurityQuestionResult.success() {
    return const SecurityQuestionResult._(success: true);
  }

  factory SecurityQuestionResult.failure(String message) {
    return SecurityQuestionResult._(
      success: false,
      errorMessage: message,
    );
  }
}

class ConsentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AttemptLimitingService _attemptService = AttemptLimitingService.instance;

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
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    // Check if user is locked out
    if (await _attemptService.isLockedOut()) {
      final remainingTime = await _attemptService.getRemainingLockoutTimeFormatted();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account is locked. Please wait $remainingTime before trying again.')),
      );
      return;
    }

    final attemptStatus = await _attemptService.getAttemptStatus();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedPasswordDialog(
          attemptStatus: attemptStatus,
          onSubmit: (password) async {
            await _handlePasswordSubmission(
              context, 
              password, 
              user.uid, 
              onSuccess, 
              null
            );
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

  // Show the Enhanced Reset Password dialog
  void _showResetParentalKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedResetDialog(
          onSubmit: (answer, newPassword) async {
            try {
              final result = await verifySecurityQuestionSecure(answer, newPassword);
              
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(); // Close dialog

              if (result.success) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Parental key reset successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.errorMessage ?? "Reset failed"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(); // Close dialog
              
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${e.toString()}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onCancel: () {
            Navigator.of(context).pop(); // Close dialog
          },
        );
      },
    );
  }

  /// Handle password submission with attempt limiting
  Future<void> _handlePasswordSubmission(
    BuildContext context,
    String password,
    String userId,
    VoidCallback onSuccess,
    VoidCallback? onError,
  ) async {
    try {
      // Check if user can still attempt (double-check)
      if (await _attemptService.isLockedOut()) {
        final remainingTime = await _attemptService.getRemainingLockoutTimeFormatted();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account is locked. Please wait $remainingTime before trying again.')),
        );
        Navigator.of(context).pop();
        onError?.call();
        return;
      }

      // Verify the password
      bool isMatch = await matchParentalKey(password);

      if (isMatch) {
        // Success - reset attempts and execute callback
        await _attemptService.recordSuccessfulAttempt();
        Navigator.of(context).pop();
        onSuccess();
      } else {
        // Failed attempt - record it
        final result = await _attemptService.recordFailedAttempt();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isLockedOut ? Colors.red : Colors.orange,
          ),
        );
        Navigator.of(context).pop();
        onError?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      Navigator.of(context).pop();
      onError?.call();
    }
  }

  /// Get appropriate color for snackbar based on attempt status
  Color _getSnackBarColor(bool isError, bool isWarning) {
    if (isError) return Colors.red;
    if (isWarning) return Colors.orange;
    return Colors.blue;
  }

  /// Get current attempt status for the authenticated user
  Future<AttemptStatus?> getCurrentUserAttemptStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _attemptService.getAttemptStatus();
  }

  /// Check if current user can attempt verification
  Future<bool> canCurrentUserAttemptVerification() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return await _attemptService.canAttempt();
  }

  /// Get failed attempt count for current user
  Future<int> getCurrentUserFailedAttempts() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    return await _attemptService.getFailedAttempts();
  }

  /// Get remaining lockout time for current user
  Future<int> getCurrentUserRemainingLockoutTime() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    return await _attemptService.getRemainingLockoutTime();
  }

  /// Check if current user is locked out
  Future<bool> isCurrentUserLockedOut() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    return await _attemptService.isLockedOut();
  }

  /// Reset attempts for current user (admin function)
  Future<void> resetCurrentUserAttempts() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _attemptService.resetAllData();
  }

  /// Verify parental key with enhanced error handling and logging
  Future<ParentalVerificationResult> verifyParentalKeySecure(String enteredKey) async {
    final user = _auth.currentUser;
    if (user == null) {
      return ParentalVerificationResult.failure(
        'User not authenticated',
        ParentalVerificationErrorType.authenticationError
      );
    }

    // Check lockout status first
    if (await _attemptService.isLockedOut()) {
      final remainingTime = await _attemptService.getRemainingLockoutTime();
      final formattedTime = await _attemptService.getRemainingLockoutTimeFormatted();
      return ParentalVerificationResult.failure(
        'Account is locked. Please wait $formattedTime before trying again.',
        ParentalVerificationErrorType.lockedOut,
        remainingLockoutTime: Duration(seconds: remainingTime),
      );
    }

    try {
      // Verify the key
      bool isMatch = await matchParentalKey(enteredKey);

      if (isMatch) {
        await _attemptService.recordSuccessfulAttempt();
        return ParentalVerificationResult.success();
      } else {
        final result = await _attemptService.recordFailedAttempt();
        
        return ParentalVerificationResult.failure(
          result.message,
          result.isLockedOut 
            ? ParentalVerificationErrorType.lockedOut 
            : ParentalVerificationErrorType.incorrectKey,
          failedAttempts: await _attemptService.getFailedAttempts(),
          attemptsRemaining: result.remainingAttempts,
          remainingLockoutTime: Duration(seconds: result.remainingLockoutTime),
        );
      }
    } catch (e) {
      return ParentalVerificationResult.failure(
        'Verification error: ${e.toString()}',
        ParentalVerificationErrorType.systemError
      );
    }
  }

  /// Enhanced security question verification with attempt limiting
  Future<SecurityQuestionResult> verifySecurityQuestionSecure(
    String answer, 
    String newPassword
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      return SecurityQuestionResult.failure('User not authenticated');
    }

    try {
      final consentDocRef = _firestore.collection('consents').doc(user.uid);
      final consentDoc = await consentDocRef.get();

      if (!consentDoc.exists) {
        return SecurityQuestionResult.failure('No consent data found');
      }

      String storedAnswerHash = consentDoc.get('securityAnswer');
      String enteredAnswerHash = hashSecurityAnswer(answer);

      if (storedAnswerHash != enteredAnswerHash) {
        return SecurityQuestionResult.failure('Incorrect security answer');
      }

      // Hash the new parental key
      String hashedNewPassword = hashParentalKey(newPassword);

      // Update the parental key in Firestore
      await consentDocRef.update({
        'parentalKey': hashedNewPassword,
        'lastPasswordReset': FieldValue.serverTimestamp(),
      });

      // Reset attempts after successful password reset
      await _attemptService.recordSuccessfulAttempt();

      return SecurityQuestionResult.success();
    } catch (e) {
      return SecurityQuestionResult.failure('Reset error: ${e.toString()}');
    }
  }

  /// Get security statistics for current user
  Future<Map<String, dynamic>> getCurrentUserSecurityStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'authenticated': false,
        'canAttempt': false,
        'failedAttempts': 0,
        'isLockedOut': false,
        'remainingLockoutTime': Duration.zero,
      };
    }

    final status = await _attemptService.getAttemptStatus();
    
    return {
      'authenticated': true,
      'canAttempt': status.canAttempt,
      'failedAttempts': status.failedAttempts,
      'attemptsRemaining': status.remainingAttempts,
      'isLockedOut': status.isLockedOut,
      'remainingLockoutTime': Duration(seconds: status.remainingLockoutTime),
      'maxAttempts': status.maxAttempts,
      'lockoutDurationMinutes': status.lockoutDurationMinutes,
    };
  }

  /// Log security events for audit purposes
  void _logSecurityEvent(String event, String userId, {Map<String, dynamic>? details}) {
    final logData = {
      'event': event,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details ?? {},
    };
    
    // In a production app, you might want to send this to a logging service
    print('Security Event: $logData');
  }

  /// Enhanced verification with comprehensive logging
  Future<ParentalVerificationResult> verifyParentalKeyWithLogging(
    String enteredKey,
    {String? context}
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      _logSecurityEvent('verification_attempt_unauthenticated', 'unknown', 
        details: {'context': context});
      return ParentalVerificationResult.failure(
        'User not authenticated',
        ParentalVerificationErrorType.authenticationError
      );
    }

    _logSecurityEvent('verification_attempt_started', user.uid, 
      details: {'context': context});

    final result = await verifyParentalKeySecure(enteredKey);
    
    if (result.success) {
      _logSecurityEvent('verification_successful', user.uid, 
        details: {'context': context});
    } else {
      _logSecurityEvent('verification_failed', user.uid, 
        details: {
          'context': context,
          'errorType': result.errorType.toString(),
          'failedAttempts': result.failedAttempts,
          'isLockedOut': result.isLockedOut,
        });
    }

    return result;
  }

  /// Dispose method to clean up resources
  void dispose() {
    // The AttemptLimitingService is a singleton, so we don't dispose it here
    // But we could remove any listeners if we had them
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

      // Reset attempts after successful password reset
      await _attemptService.recordSuccessfulAttempt();

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
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      onError();
      return;
    }

    // Check if user is locked out
    if (await _attemptService.isLockedOut()) {
      final remainingTime = await _attemptService.getRemainingLockoutTimeFormatted();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account is locked. Please wait $remainingTime before trying again.')),
      );
      onError();
      return;
    }

    final attemptStatus = await _attemptService.getAttemptStatus();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedPasswordDialog(
          attemptStatus: attemptStatus,
          onSubmit: (password) async {
            await _handlePasswordSubmission(
              context, 
              password, 
              user.uid, 
              onSuccess, 
              onError
            );
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
  // if (key.length < 8) return 'Key must be at least 8 characters long';

  List<String> errors = [];
  // if (!key.contains(RegExp(r'[A-Z]'))) errors.add('an uppercase letter');
  // if (!key.contains(RegExp(r'[a-z]'))) errors.add('a lowercase letter');
  // if (!key.contains(RegExp(r'[0-9]'))) errors.add('a number');
  // if (!key.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:]'))) errors.add('a special character');

  // if (errors.isNotEmpty) {
  //    return 'Key must include ${errors.join(', ')}.';
  // }
  return null;
}
