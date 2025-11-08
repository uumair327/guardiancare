import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/consent/screens/enhanced_password_dialog.dart';
import 'package:guardiancare/src/features/consent/screens/enhanced_reset_dialog.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';
import 'package:guardiancare/src/features/consent/services/consent_form_validation_service.dart';
import 'package:guardiancare/src/features/consent/services/consent_error_handler.dart';
import 'package:guardiancare/src/features/consent/services/security_question_validator.dart';

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
  final ConsentFormValidationService _validationService = ConsentFormValidationService.instance;
  final ConsentErrorHandler _errorHandler = ConsentErrorHandler.instance;
  final SecurityQuestionValidator _securityValidator = SecurityQuestionValidator.instance;

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

  /// Enhanced consent form submission with comprehensive validation
  Future<ConsentSubmissionResult> submitConsentFormEnhanced({
    required String parentName,
    required String parentEmail,
    required String childName,
    required String parentalKey,
    required String parentalKeyConfirmation,
    required String securityQuestion,
    required String securityAnswer,
    required bool isChildAbove12,
    required Map<String, bool> consentCheckboxes,
  }) async {
    try {
      // Set submission state
      _validationService.setSubmissionState(true);

      // Validate form data
      final validationResult = _validationService.validateFormForSubmission(
        parentName: parentName,
        parentEmail: parentEmail,
        childName: childName,
        parentalKey: parentalKey,
        parentalKeyConfirmation: parentalKeyConfirmation,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
        checkboxStates: consentCheckboxes,
      );

      if (!validationResult.isValid) {
        _validationService.setSubmissionState(false);
        return ConsentSubmissionResult.validationFailure(
          'Form validation failed',
          validationResult.errors,
          validationResult.fieldErrors,
        );
      }

      // Check user authentication
      User? user = _auth.currentUser;
      if (user == null || user.email == null || user.displayName == null) {
        _validationService.setSubmissionState(false);
        return ConsentSubmissionResult.failure(
          'User is not authenticated or lacks profile details.',
          ConsentSubmissionErrorType.authenticationError,
        );
      }

      // Check for existing consent to prevent duplicates
      final existingConsent = await _firestore
          .collection('consents')
          .doc(user.uid)
          .get();

      if (existingConsent.exists) {
        final existingData = existingConsent.data()!;
        final lastSubmission = existingData['timestamp'] as Timestamp?;
        
        if (lastSubmission != null) {
          final timeSinceLastSubmission = DateTime.now()
              .difference(lastSubmission.toDate());
          
          // Prevent rapid resubmissions (within 5 minutes)
          if (timeSinceLastSubmission.inMinutes < 5) {
            _validationService.setSubmissionState(false);
            return ConsentSubmissionResult.failure(
              'Please wait before resubmitting the consent form.',
              ConsentSubmissionErrorType.rateLimitExceeded,
            );
          }
        }
      }

      // Prepare enhanced form data
      final formData = {
        'parentName': parentName.trim(),
        'parentEmail': parentEmail.trim().toLowerCase(),
        'childName': childName.trim(),
        'isChildAbove12': isChildAbove12,
        'parentalKey': hashParentalKey(parentalKey),
        'securityQuestion': securityQuestion.trim(),
        'securityAnswer': hashSecurityAnswer(securityAnswer),
        'userEmail': user.email,
        'userName': user.displayName,
        'timestamp': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'submissionVersion': '2.0', // Track form version
        'validationPassed': true,
        'ipAddress': 'client-side', // In production, get from server
        'userAgent': 'flutter-app',
        
        // Store consent checkboxes
        'consentCheckboxes': consentCheckboxes,
        'requiredConsentsGiven': _validateRequiredConsents(consentCheckboxes),
        
        // Additional metadata
        'formCompletionTime': DateTime.now().toIso8601String(),
        'validationErrors': [], // No errors if we reach this point
      };

      // Save to Firestore with enhanced error handling
      await _firestore
          .collection('consents')
          .doc(user.uid)
          .set(formData, SetOptions(merge: true));

      // Log successful submission
      _logConsentEvent('consent_form_submitted', user.uid, {
        'parentEmail': parentEmail,
        'childName': childName,
        'isChildAbove12': isChildAbove12,
        'consentCheckboxes': consentCheckboxes,
      });

      // Reset validation state
      _validationService.resetValidation();

      print('Enhanced consent form data saved successfully.');
      
      return ConsentSubmissionResult.success(
        'Consent form submitted successfully',
        formData,
      );

    } catch (e) {
      _validationService.setSubmissionState(false);
      
      // Log error
      final user = _auth.currentUser;
      if (user != null) {
        _logConsentEvent('consent_form_submission_error', user.uid, {
          'error': e.toString(),
          'parentEmail': parentEmail,
        });
      }

      return ConsentSubmissionResult.failure(
        'Error saving consent data: ${e.toString()}',
        ConsentSubmissionErrorType.systemError,
      );
    }
  }

  // Legacy method for backward compatibility
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
    final result = await submitConsentFormEnhanced(
      parentName: parentName,
      parentEmail: parentEmail,
      childName: childName,
      parentalKey: parentalKey,
      parentalKeyConfirmation: parentalKey, // Assume confirmation matches
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer,
      isChildAbove12: isChildAbove12,
      consentCheckboxes: {
        'parentConsentGiven': isParentConsentGiven,
        'termsAccepted': true,
        'privacyPolicyAccepted': true,
        'dataProcessingConsent': true,
      },
    );
    
    return result.success;
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

  /// Enhanced security question verification with comprehensive validation
  Future<SecurityQuestionResult> verifySecurityQuestionSecure(
    String answer, 
    String newPassword
  ) async {
    try {
      // Use the enhanced security validator
      final resetResult = await _securityValidator.resetParentalKeyWithSecurity(
        answer,
        newPassword,
      );

      if (resetResult.success) {
        // Reset attempts after successful password reset
        await _attemptService.recordSuccessfulAttempt();
        return SecurityQuestionResult.success();
      } else {
        return SecurityQuestionResult.failure(resetResult.message);
      }
    } catch (e) {
      return SecurityQuestionResult.failure('Reset error: ${e.toString()}');
    }
  }

  /// Validate security question format and content
  SecurityQuestionValidationResult validateSecurityQuestion(String? question) {
    return _securityValidator.validateSecurityQuestion(question);
  }

  /// Validate security answer format and strength
  SecurityAnswerValidationResult validateSecurityAnswer(
    String? answer, 
    String? question,
  ) {
    return _securityValidator.validateSecurityAnswer(answer, question);
  }

  /// Verify security answer for password reset
  Future<SecurityVerificationResult> verifySecurityAnswerForReset(
    String providedAnswer,
  ) async {
    return await _securityValidator.verifySecurityAnswer(providedAnswer);
  }

  /// Get current user's security question
  Future<String?> getCurrentUserSecurityQuestion() async {
    return await _securityValidator.getCurrentUserSecurityQuestion();
  }

  /// Check if current user has security question setup
  Future<bool> hasSecurityQuestionSetup() async {
    return await _securityValidator.hasSecurityQuestionSetup();
  }

  /// Enhanced security question setup with validation
  Future<SecurityQuestionSetupResult> setupSecurityQuestion(
    String question,
    String answer,
  ) async {
    // Validate question
    final questionValidation = _securityValidator.validateSecurityQuestion(question);
    if (!questionValidation.isValid) {
      return SecurityQuestionSetupResult.failure(
        questionValidation.errorMessage ?? 'Invalid security question',
        SecurityQuestionSetupErrorType.invalidQuestion,
      );
    }

    // Validate answer
    final answerValidation = _securityValidator.validateSecurityAnswer(answer, question);
    if (!answerValidation.isValid) {
      return SecurityQuestionSetupResult.failure(
        answerValidation.errorMessage ?? 'Invalid security answer',
        SecurityQuestionSetupErrorType.invalidAnswer,
      );
    }

    final user = _auth.currentUser;
    if (user == null) {
      return SecurityQuestionSetupResult.failure(
        'User not authenticated',
        SecurityQuestionSetupErrorType.notAuthenticated,
      );
    }

    try {
      // Hash the security answer
      final hashedAnswer = hashSecurityAnswer(answer);

      // Update the security question and answer in Firestore
      await _firestore.collection('consents').doc(user.uid).update({
        'securityQuestion': question.trim(),
        'securityAnswer': hashedAnswer,
        'securityQuestionSetupAt': FieldValue.serverTimestamp(),
      });

      return SecurityQuestionSetupResult.success(
        'Security question setup successfully',
        questionValidation.isWarning ? questionValidation.errorMessage : null,
        answerValidation.isWarning ? answerValidation.errorMessage : null,
      );

    } catch (e) {
      return SecurityQuestionSetupResult.failure(
        'Error setting up security question: ${e.toString()}',
        SecurityQuestionSetupErrorType.systemError,
      );
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

  /// Validate required consents are given
  bool _validateRequiredConsents(Map<String, bool> checkboxes) {
    final requiredConsents = [
      'parentConsentGiven',
      'termsAccepted', 
      'privacyPolicyAccepted',
      'dataProcessingConsent',
    ];
    
    return requiredConsents.every((consent) => checkboxes[consent] == true);
  }

  /// Log consent-related events for audit purposes
  void _logConsentEvent(String event, String userId, Map<String, dynamic> details) {
    final logData = {
      'event': event,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details,
    };
    
    // In production, send to logging service
    print('Consent Event: $logData');
  }

  /// Get validation service instance for external use
  ConsentFormValidationService get validationService => _validationService;

  /// Validate parental key confirmation in real-time
  void validateParentalKeyConfirmation(String? confirmation, String? original) {
    _validationService.validateParentalKeyConfirmation(confirmation, original, realTime: true);
  }

  /// Validate all form fields in real-time
  void validateFormFieldsRealTime({
    String? parentName,
    String? parentEmail,
    String? childName,
    String? parentalKey,
    String? parentalKeyConfirmation,
    String? securityQuestion,
    String? securityAnswer,
  }) {
    if (parentName != null) {
      _validationService.validateParentName(parentName, realTime: true);
    }
    if (parentEmail != null) {
      _validationService.validateParentEmail(parentEmail, realTime: true);
    }
    if (childName != null) {
      _validationService.validateChildName(childName, realTime: true);
    }
    if (parentalKey != null) {
      _validationService.validateParentalKey(parentalKey, realTime: true);
    }
    if (parentalKeyConfirmation != null && parentalKey != null) {
      _validationService.validateParentalKeyConfirmation(
        parentalKeyConfirmation, 
        parentalKey, 
        realTime: true
      );
    }
    if (securityQuestion != null) {
      _validationService.validateSecurityQuestion(securityQuestion, realTime: true);
    }
    if (securityAnswer != null) {
      _validationService.validateSecurityAnswer(securityAnswer, realTime: true);
    }
  }

  /// Get form validation summary
  FormValidationSummary getFormValidationSummary() {
    return _validationService.validationSummary;
  }

  /// Check if form is ready for submission
  bool isFormReadyForSubmission() {
    return _validationService.isFormValid && !_validationService.isSubmitting;
  }

  /// Reset form validation state
  void resetFormValidation() {
    _validationService.resetValidation();
  }

  /// Enhanced consent form submission with comprehensive error handling
  Future<void> submitConsentFormWithErrorHandling(
    BuildContext context, {
    required String parentName,
    required String parentEmail,
    required String childName,
    required String parentalKey,
    required String parentalKeyConfirmation,
    required String securityQuestion,
    required String securityAnswer,
    required bool isChildAbove12,
    required Map<String, bool> consentCheckboxes,
    VoidCallback? onSuccess,
    VoidCallback? onCancel,
  }) async {
    try {
      // Prepare form data for potential preservation
      final formData = {
        'parentName': parentName,
        'parentEmail': parentEmail,
        'childName': childName,
        'parentalKey': parentalKey,
        'parentalKeyConfirmation': parentalKeyConfirmation,
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
        'isChildAbove12': isChildAbove12,
        'consentCheckboxes': consentCheckboxes,
      };

      // Attempt submission
      final result = await submitConsentFormEnhanced(
        parentName: parentName,
        parentEmail: parentEmail,
        childName: childName,
        parentalKey: parentalKey,
        parentalKeyConfirmation: parentalKeyConfirmation,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
        isChildAbove12: isChildAbove12,
        consentCheckboxes: consentCheckboxes,
      );

      if (result.success) {
        // Clear any preserved data on success
        await _errorHandler.clearPreservedFormData();
        
        // Show success message
        _errorHandler.showSuccessMessage(
          context,
          message: result.message,
          onContinue: onSuccess,
        );
      } else {
        // Handle different types of errors
        await _handleSubmissionError(context, result, formData, onCancel);
      }
    } catch (e) {
      // Handle unexpected errors
      final error = ConsentError(
        type: ConsentErrorType.systemError,
        message: 'An unexpected error occurred: ${e.toString()}',
        errorCode: 'UNEXPECTED_ERROR',
        formData: {
          'parentName': parentName,
          'parentEmail': parentEmail,
          'childName': childName,
          // Don't preserve sensitive data in error logs
        },
      );

      await _errorHandler.handleConsentError(
        context,
        error,
        onRetry: () => submitConsentFormWithErrorHandling(
          context,
          parentName: parentName,
          parentEmail: parentEmail,
          childName: childName,
          parentalKey: parentalKey,
          parentalKeyConfirmation: parentalKeyConfirmation,
          securityQuestion: securityQuestion,
          securityAnswer: securityAnswer,
          isChildAbove12: isChildAbove12,
          consentCheckboxes: consentCheckboxes,
          onSuccess: onSuccess,
          onCancel: onCancel,
        ),
        onCancel: onCancel,
      );
    }
  }

  /// Handle submission errors with appropriate error types
  Future<void> _handleSubmissionError(
    BuildContext context,
    ConsentSubmissionResult result,
    Map<String, dynamic> formData,
    VoidCallback? onCancel,
  ) async {
    ConsentError error;

    switch (result.errorType) {
      case ConsentSubmissionErrorType.validationError:
        error = ConsentError.validation(
          message: result.message,
          validationErrors: result.validationErrors,
          fieldErrors: result.fieldErrors,
          formData: formData,
        );
        break;
      case ConsentSubmissionErrorType.authenticationError:
        error = ConsentError(
          type: ConsentErrorType.authenticationError,
          message: result.message,
          formData: formData,
        );
        break;
      case ConsentSubmissionErrorType.rateLimitExceeded:
        error = ConsentError.rateLimit(
          message: result.message,
          retryAfter: const Duration(minutes: 5),
          formData: formData,
        );
        break;
      case ConsentSubmissionErrorType.networkError:
        error = ConsentError.network(
          message: result.message,
          formData: formData,
        );
        break;
      case ConsentSubmissionErrorType.systemError:
      default:
        error = ConsentError(
          type: ConsentErrorType.systemError,
          message: result.message,
          errorCode: 'SUBMISSION_FAILED',
          isTemporary: true,
          formData: formData,
        );
        break;
    }

    await _errorHandler.handleConsentError(
      context,
      error,
      onRetry: () => _retrySubmissionFromError(context, formData, onCancel),
      onCancel: onCancel,
    );
  }

  /// Retry submission from preserved form data
  Future<void> _retrySubmissionFromError(
    BuildContext context,
    Map<String, dynamic> formData,
    VoidCallback? onCancel,
  ) async {
    await submitConsentFormWithErrorHandling(
      context,
      parentName: formData['parentName'] ?? '',
      parentEmail: formData['parentEmail'] ?? '',
      childName: formData['childName'] ?? '',
      parentalKey: formData['parentalKey'] ?? '',
      parentalKeyConfirmation: formData['parentalKeyConfirmation'] ?? '',
      securityQuestion: formData['securityQuestion'] ?? '',
      securityAnswer: formData['securityAnswer'] ?? '',
      isChildAbove12: formData['isChildAbove12'] ?? false,
      consentCheckboxes: Map<String, bool>.from(formData['consentCheckboxes'] ?? {}),
      onCancel: onCancel,
    );
  }

  /// Check for and restore preserved form data
  Future<Map<String, dynamic>?> checkForPreservedFormData() async {
    return await _errorHandler.restoreFormData();
  }

  /// Show form data recovery dialog
  Future<void> showFormDataRecoveryDialog(
    BuildContext context,
    VoidCallback onRestore,
    VoidCallback onStartFresh,
  ) async {
    final hasPreservedData = await _errorHandler.hasPreservedFormData();
    
    if (!hasPreservedData) {
      onStartFresh();
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.restore, color: Colors.blue),
            SizedBox(width: 8),
            Text('Restore Form Data'),
          ],
        ),
        content: const Text(
          'We found previously saved form data. Would you like to restore it or start fresh?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _errorHandler.clearPreservedFormData();
              onStartFresh();
            },
            child: const Text('Start Fresh'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestore();
            },
            child: const Text('Restore Data'),
          ),
        ],
      ),
    );
  }

  /// Get error handler instance for external use
  ConsentErrorHandler get errorHandler => _errorHandler;

  /// Dispose method to clean up resources
  void dispose() {
    // The AttemptLimitingService is a singleton, so we don't dispose it here
    // The ConsentFormValidationService is also a singleton
    // But we could remove any listeners if we had them
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

/// Result of consent form submission
class ConsentSubmissionResult {
  final bool success;
  final String message;
  final ConsentSubmissionErrorType? errorType;
  final List<String>? validationErrors;
  final Map<String, String>? fieldErrors;
  final Map<String, dynamic>? submittedData;

  const ConsentSubmissionResult._({
    required this.success,
    required this.message,
    this.errorType,
    this.validationErrors,
    this.fieldErrors,
    this.submittedData,
  });

  factory ConsentSubmissionResult.success(
    String message,
    Map<String, dynamic> submittedData,
  ) {
    return ConsentSubmissionResult._(
      success: true,
      message: message,
      submittedData: submittedData,
    );
  }

  factory ConsentSubmissionResult.failure(
    String message,
    ConsentSubmissionErrorType errorType,
  ) {
    return ConsentSubmissionResult._(
      success: false,
      message: message,
      errorType: errorType,
    );
  }

  factory ConsentSubmissionResult.validationFailure(
    String message,
    List<String> validationErrors,
    Map<String, String> fieldErrors,
  ) {
    return ConsentSubmissionResult._(
      success: false,
      message: message,
      errorType: ConsentSubmissionErrorType.validationError,
      validationErrors: validationErrors,
      fieldErrors: fieldErrors,
    );
  }

  bool get hasValidationErrors => validationErrors?.isNotEmpty ?? false;
  bool get hasFieldErrors => fieldErrors?.isNotEmpty ?? false;
}

/// Types of consent submission errors
enum ConsentSubmissionErrorType {
  validationError,
  authenticationError,
  rateLimitExceeded,
  systemError,
  networkError,
}

/// Enhanced validation for Parental Key with detailed feedback
class ParentalKeyValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<String> missingRequirements;
  final int strengthScore; // 0-100

  const ParentalKeyValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.missingRequirements = const [],
    this.strengthScore = 0,
  });

  factory ParentalKeyValidationResult.valid(int strengthScore) {
    return ParentalKeyValidationResult._(
      isValid: true,
      strengthScore: strengthScore,
    );
  }

  factory ParentalKeyValidationResult.invalid(
    String errorMessage,
    List<String> missingRequirements,
    int strengthScore,
  ) {
    return ParentalKeyValidationResult._(
      isValid: false,
      errorMessage: errorMessage,
      missingRequirements: missingRequirements,
      strengthScore: strengthScore,
    );
  }

  String get strengthLabel {
    if (strengthScore >= 80) return 'Very Strong';
    if (strengthScore >= 60) return 'Strong';
    if (strengthScore >= 40) return 'Medium';
    if (strengthScore >= 20) return 'Weak';
    return 'Very Weak';
  }
}

/// Enhanced parental key validation function
ParentalKeyValidationResult validateParentalKeyEnhanced(String? key) {
  if (key == null || key.isEmpty) {
    return ParentalKeyValidationResult.invalid(
      'Parental Key is required',
      ['Enter a parental key'],
      0,
    );
  }

  final missingRequirements = <String>[];
  int strengthScore = 0;

  // Length check
  if (key.length < 8) {
    missingRequirements.add('At least 8 characters');
  } else {
    strengthScore += 20;
    if (key.length >= 12) strengthScore += 10;
    if (key.length >= 16) strengthScore += 10;
  }

  // Character type checks
  if (!key.contains(RegExp(r'[A-Z]'))) {
    missingRequirements.add('An uppercase letter');
  } else {
    strengthScore += 15;
  }

  if (!key.contains(RegExp(r'[a-z]'))) {
    missingRequirements.add('A lowercase letter');
  } else {
    strengthScore += 15;
  }

  if (!key.contains(RegExp(r'[0-9]'))) {
    missingRequirements.add('A number');
  } else {
    strengthScore += 15;
  }

  if (!key.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
    missingRequirements.add('A special character');
  } else {
    strengthScore += 15;
  }

  // Additional strength factors
  if (key.length > 12) strengthScore += 5;
  if (RegExp(r'[A-Z].*[A-Z]').hasMatch(key)) strengthScore += 5; // Multiple uppercase
  if (RegExp(r'[0-9].*[0-9]').hasMatch(key)) strengthScore += 5; // Multiple numbers

  if (missingRequirements.isNotEmpty) {
    return ParentalKeyValidationResult.invalid(
      'Parental key must include: ${missingRequirements.join(', ')}',
      missingRequirements,
      strengthScore,
    );
  }

  return ParentalKeyValidationResult.valid(strengthScore);
}

/// Security question setup result
class SecurityQuestionSetupResult {
  final bool success;
  final String message;
  final SecurityQuestionSetupErrorType? errorType;
  final String? questionWarning;
  final String? answerWarning;

  const SecurityQuestionSetupResult._({
    required this.success,
    required this.message,
    this.errorType,
    this.questionWarning,
    this.answerWarning,
  });

  factory SecurityQuestionSetupResult.success(
    String message, [
    String? questionWarning,
    String? answerWarning,
  ]) {
    return SecurityQuestionSetupResult._(
      success: true,
      message: message,
      questionWarning: questionWarning,
      answerWarning: answerWarning,
    );
  }

  factory SecurityQuestionSetupResult.failure(
    String message,
    SecurityQuestionSetupErrorType errorType,
  ) {
    return SecurityQuestionSetupResult._(
      success: false,
      message: message,
      errorType: errorType,
    );
  }

  bool get hasWarnings => questionWarning != null || answerWarning != null;
}

/// Security question setup error types
enum SecurityQuestionSetupErrorType {
  invalidQuestion,
  invalidAnswer,
  notAuthenticated,
  systemError,
}

/// Legacy validation for backward compatibility
String? validateParentalKey(String? key) {
  final result = validateParentalKeyEnhanced(key);
  return result.isValid ? null : result.errorMessage;
}
