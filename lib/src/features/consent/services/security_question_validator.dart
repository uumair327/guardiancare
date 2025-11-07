import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Enhanced security question validation service with secure hashing and validation
class SecurityQuestionValidator {
  static SecurityQuestionValidator? _instance;
  
  SecurityQuestionValidator._();
  
  static SecurityQuestionValidator get instance {
    _instance ??= SecurityQuestionValidator._();
    return _instance!;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Validate security question format and content
  SecurityQuestionValidationResult validateSecurityQuestion(String? question) {
    if (question == null || question.trim().isEmpty) {
      return SecurityQuestionValidationResult.invalid(
        'Security question is required',
        SecurityQuestionErrorType.required,
      );
    }

    final trimmedQuestion = question.trim();

    // Length validation
    if (trimmedQuestion.length < 10) {
      return SecurityQuestionValidationResult.invalid(
        'Security question must be at least 10 characters long',
        SecurityQuestionErrorType.tooShort,
      );
    }

    if (trimmedQuestion.length > 200) {
      return SecurityQuestionValidationResult.invalid(
        'Security question must be less than 200 characters',
        SecurityQuestionErrorType.tooLong,
      );
    }

    // Format validation
    if (!trimmedQuestion.endsWith('?')) {
      return SecurityQuestionValidationResult.invalid(
        'Security question must end with a question mark',
        SecurityQuestionErrorType.invalidFormat,
      );
    }

    // Content validation
    if (_isCommonQuestion(trimmedQuestion)) {
      return SecurityQuestionValidationResult.warning(
        'Consider using a more unique security question',
        SecurityQuestionErrorType.tooCommon,
      );
    }

    if (_containsPersonalInfo(trimmedQuestion)) {
      return SecurityQuestionValidationResult.warning(
        'Avoid including personal information in the question',
        SecurityQuestionErrorType.containsPersonalInfo,
      );
    }

    // Check for question words
    if (!_containsQuestionWords(trimmedQuestion)) {
      return SecurityQuestionValidationResult.invalid(
        'Security question should contain question words (what, when, where, who, how, etc.)',
        SecurityQuestionErrorType.noQuestionWords,
      );
    }

    return SecurityQuestionValidationResult.valid();
  }

  /// Validate security answer format and strength
  SecurityAnswerValidationResult validateSecurityAnswer(
    String? answer, 
    String? question,
  ) {
    if (answer == null || answer.trim().isEmpty) {
      return SecurityAnswerValidationResult.invalid(
        'Security answer is required',
        SecurityAnswerErrorType.required,
      );
    }

    final trimmedAnswer = answer.trim();

    // Length validation
    if (trimmedAnswer.length < 2) {
      return SecurityAnswerValidationResult.invalid(
        'Security answer must be at least 2 characters long',
        SecurityAnswerErrorType.tooShort,
      );
    }

    if (trimmedAnswer.length > 100) {
      return SecurityAnswerValidationResult.invalid(
        'Security answer must be less than 100 characters',
        SecurityAnswerErrorType.tooLong,
      );
    }

    // Content validation
    if (_isSimpleAnswer(trimmedAnswer)) {
      return SecurityAnswerValidationResult.invalid(
        'Please provide a more specific security answer',
        SecurityAnswerErrorType.tooSimple,
      );
    }

    if (_isNumericOnly(trimmedAnswer)) {
      return SecurityAnswerValidationResult.warning(
        'Consider using a mix of letters and numbers for better security',
        SecurityAnswerErrorType.numericOnly,
      );
    }

    // Check if answer is too similar to question
    if (question != null && _isAnswerTooSimilarToQuestion(trimmedAnswer, question)) {
      return SecurityAnswerValidationResult.invalid(
        'Answer should not be too similar to the question',
        SecurityAnswerErrorType.similarToQuestion,
      );
    }

    // Calculate answer strength
    final strength = _calculateAnswerStrength(trimmedAnswer);
    
    if (strength < 30) {
      return SecurityAnswerValidationResult.warning(
        'Consider using a longer or more complex answer',
        SecurityAnswerErrorType.weakStrength,
      );
    }

    return SecurityAnswerValidationResult.valid(strength);
  }

  /// Enhanced security answer verification with secure hashing
  Future<SecurityVerificationResult> verifySecurityAnswer(
    String providedAnswer,
    {int maxAttempts = 3}
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      return SecurityVerificationResult.failure(
        'User not authenticated',
        SecurityVerificationErrorType.notAuthenticated,
      );
    }

    try {
      // Get stored security data
      final consentDoc = await _firestore
          .collection('consents')
          .doc(user.uid)
          .get();

      if (!consentDoc.exists) {
        return SecurityVerificationResult.failure(
          'No security question found for this user',
          SecurityVerificationErrorType.noSecurityQuestion,
        );
      }

      final data = consentDoc.data()!;
      final storedAnswerHash = data['securityAnswer'] as String?;
      final storedQuestion = data['securityQuestion'] as String?;

      if (storedAnswerHash == null || storedQuestion == null) {
        return SecurityVerificationResult.failure(
          'Security question data is incomplete',
          SecurityVerificationErrorType.incompleteData,
        );
      }

      // Hash the provided answer using the same method
      final providedAnswerHash = _hashSecurityAnswer(providedAnswer);

      // Verify the hash
      final isMatch = storedAnswerHash == providedAnswerHash;

      if (isMatch) {
        // Log successful verification
        await _logSecurityEvent('security_answer_verified', user.uid, {
          'success': true,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return SecurityVerificationResult.success(
          'Security answer verified successfully',
        );
      } else {
        // Log failed verification
        await _logSecurityEvent('security_answer_failed', user.uid, {
          'success': false,
          'timestamp': DateTime.now().toIso8601String(),
        });

        return SecurityVerificationResult.failure(
          'Security answer is incorrect',
          SecurityVerificationErrorType.incorrectAnswer,
        );
      }

    } catch (e) {
      // Log error
      await _logSecurityEvent('security_verification_error', user?.uid ?? 'unknown', {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return SecurityVerificationResult.failure(
        'Error verifying security answer: ${e.toString()}',
        SecurityVerificationErrorType.systemError,
      );
    }
  }

  /// Reset parental key using verified security answer
  Future<SecurityResetResult> resetParentalKeyWithSecurity(
    String securityAnswer,
    String newParentalKey,
  ) async {
    // First verify the security answer
    final verificationResult = await verifySecurityAnswer(securityAnswer);
    
    if (!verificationResult.success) {
      return SecurityResetResult.failure(
        verificationResult.errorMessage,
        SecurityResetErrorType.verificationFailed,
      );
    }

    final user = _auth.currentUser;
    if (user == null) {
      return SecurityResetResult.failure(
        'User not authenticated',
        SecurityResetErrorType.notAuthenticated,
      );
    }

    try {
      // Hash the new parental key
      final hashedNewKey = _hashParentalKey(newParentalKey);

      // Update the parental key in Firestore
      await _firestore
          .collection('consents')
          .doc(user.uid)
          .update({
        'parentalKey': hashedNewKey,
        'lastPasswordReset': FieldValue.serverTimestamp(),
        'resetMethod': 'security_question',
        'resetTimestamp': FieldValue.serverTimestamp(),
      });

      // Log successful reset
      await _logSecurityEvent('parental_key_reset', user.uid, {
        'method': 'security_question',
        'timestamp': DateTime.now().toIso8601String(),
      });

      return SecurityResetResult.success(
        'Parental key has been reset successfully',
      );

    } catch (e) {
      // Log error
      await _logSecurityEvent('parental_key_reset_error', user.uid, {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return SecurityResetResult.failure(
        'Error resetting parental key: ${e.toString()}',
        SecurityResetErrorType.systemError,
      );
    }
  }

  /// Get security question for current user
  Future<String?> getCurrentUserSecurityQuestion() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final consentDoc = await _firestore
          .collection('consents')
          .doc(user.uid)
          .get();

      if (!consentDoc.exists) return null;

      return consentDoc.data()?['securityQuestion'] as String?;
    } catch (e) {
      print('SecurityQuestionValidator: Error getting security question: $e');
      return null;
    }
  }

  /// Check if user has security question set up
  Future<bool> hasSecurityQuestionSetup() async {
    final question = await getCurrentUserSecurityQuestion();
    return question != null && question.isNotEmpty;
  }

  /// Hash security answer using SHA-256 with salt
  String _hashSecurityAnswer(String answer) {
    // Normalize the answer (lowercase, trim)
    final normalizedAnswer = answer.toLowerCase().trim();
    
    // Add salt for additional security
    final saltedAnswer = 'security_salt_$normalizedAnswer';
    
    final bytes = utf8.encode(saltedAnswer);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Hash parental key using SHA-256
  String _hashParentalKey(String key) {
    final bytes = utf8.encode(key);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Check if question is too common
  bool _isCommonQuestion(String question) {
    final commonQuestions = [
      'what is your favorite color?',
      'what is your pet\'s name?',
      'what is your mother\'s maiden name?',
      'what city were you born in?',
      'what is your favorite food?',
      'what is your favorite movie?',
      'what school did you attend?',
    ];

    final lowerQuestion = question.toLowerCase();
    return commonQuestions.any((common) => 
        lowerQuestion.contains(common) || 
        _calculateSimilarity(lowerQuestion, common) > 0.8
    );
  }

  /// Check if question contains personal information
  bool _containsPersonalInfo(String question) {
    final personalInfoPatterns = [
      RegExp(r'\b\d{4}\b'), // Years
      RegExp(r'\b\d{2,4}[-/]\d{2}[-/]\d{2,4}\b'), // Dates
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Emails
      RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b'), // Phone numbers
    ];

    return personalInfoPatterns.any((pattern) => pattern.hasMatch(question));
  }

  /// Check if question contains question words
  bool _containsQuestionWords(String question) {
    final questionWords = [
      'what', 'when', 'where', 'who', 'why', 'how', 'which', 'whose'
    ];

    final lowerQuestion = question.toLowerCase();
    return questionWords.any((word) => lowerQuestion.contains(word));
  }

  /// Check if answer is too simple
  bool _isSimpleAnswer(String answer) {
    final simpleAnswers = [
      'yes', 'no', 'maybe', 'ok', 'fine', 'good', 'bad', 'none', 'n/a',
      'idk', 'dunno', 'nothing', 'everything', 'something'
    ];

    final lowerAnswer = answer.toLowerCase().trim();
    return simpleAnswers.contains(lowerAnswer) || answer.length < 3;
  }

  /// Check if answer is numeric only
  bool _isNumericOnly(String answer) {
    return RegExp(r'^\d+$').hasMatch(answer.trim());
  }

  /// Check if answer is too similar to question
  bool _isAnswerTooSimilarToQuestion(String answer, String question) {
    final similarity = _calculateSimilarity(
      answer.toLowerCase(), 
      question.toLowerCase()
    );
    return similarity > 0.7;
  }

  /// Calculate answer strength (0-100)
  int _calculateAnswerStrength(String answer) {
    int strength = 0;

    // Length bonus
    if (answer.length >= 5) strength += 20;
    if (answer.length >= 10) strength += 20;
    if (answer.length >= 15) strength += 10;

    // Character variety bonus
    if (RegExp(r'[a-z]').hasMatch(answer)) strength += 10;
    if (RegExp(r'[A-Z]').hasMatch(answer)) strength += 10;
    if (RegExp(r'[0-9]').hasMatch(answer)) strength += 10;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(answer)) strength += 10;

    // Word count bonus
    final wordCount = answer.split(RegExp(r'\s+')).length;
    if (wordCount >= 2) strength += 10;
    if (wordCount >= 4) strength += 10;

    return strength.clamp(0, 100);
  }

  /// Calculate similarity between two strings (0.0 to 1.0)
  double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;

    if (longer.length == 0) return 1.0;

    final editDistance = _calculateEditDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  /// Calculate edit distance between two strings
  int _calculateEditDistance(String a, String b) {
    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  /// Log security events for audit purposes
  Future<void> _logSecurityEvent(
    String event, 
    String userId, 
    Map<String, dynamic> details,
  ) async {
    try {
      await _firestore.collection('security_logs').add({
        'event': event,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'details': details,
      });
    } catch (e) {
      print('SecurityQuestionValidator: Failed to log security event: $e');
    }
  }
}

/// Security question validation result
class SecurityQuestionValidationResult {
  final bool isValid;
  final String? errorMessage;
  final SecurityQuestionErrorType? errorType;
  final bool isWarning;

  const SecurityQuestionValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.errorType,
    this.isWarning = false,
  });

  factory SecurityQuestionValidationResult.valid() {
    return const SecurityQuestionValidationResult._(isValid: true);
  }

  factory SecurityQuestionValidationResult.invalid(
    String message,
    SecurityQuestionErrorType errorType,
  ) {
    return SecurityQuestionValidationResult._(
      isValid: false,
      errorMessage: message,
      errorType: errorType,
    );
  }

  factory SecurityQuestionValidationResult.warning(
    String message,
    SecurityQuestionErrorType errorType,
  ) {
    return SecurityQuestionValidationResult._(
      isValid: true,
      errorMessage: message,
      errorType: errorType,
      isWarning: true,
    );
  }
}

/// Security answer validation result
class SecurityAnswerValidationResult {
  final bool isValid;
  final String? errorMessage;
  final SecurityAnswerErrorType? errorType;
  final bool isWarning;
  final int strengthScore;

  const SecurityAnswerValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.errorType,
    this.isWarning = false,
    this.strengthScore = 0,
  });

  factory SecurityAnswerValidationResult.valid(int strengthScore) {
    return SecurityAnswerValidationResult._(
      isValid: true,
      strengthScore: strengthScore,
    );
  }

  factory SecurityAnswerValidationResult.invalid(
    String message,
    SecurityAnswerErrorType errorType,
  ) {
    return SecurityAnswerValidationResult._(
      isValid: false,
      errorMessage: message,
      errorType: errorType,
    );
  }

  factory SecurityAnswerValidationResult.warning(
    String message,
    SecurityAnswerErrorType errorType,
  ) {
    return SecurityAnswerValidationResult._(
      isValid: true,
      errorMessage: message,
      errorType: errorType,
      isWarning: true,
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

/// Security verification result
class SecurityVerificationResult {
  final bool success;
  final String message;
  final SecurityVerificationErrorType? errorType;
  final DateTime timestamp;

  SecurityVerificationResult._({
    required this.success,
    required this.message,
    this.errorType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityVerificationResult.success(String message) {
    return SecurityVerificationResult._(
      success: true,
      message: message,
    );
  }

  factory SecurityVerificationResult.failure(
    String message,
    SecurityVerificationErrorType errorType,
  ) {
    return SecurityVerificationResult._(
      success: false,
      message: message,
      errorType: errorType,
    );
  }

  String get errorMessage => message;
}

/// Security reset result
class SecurityResetResult {
  final bool success;
  final String message;
  final SecurityResetErrorType? errorType;
  final DateTime timestamp;

  SecurityResetResult._({
    required this.success,
    required this.message,
    this.errorType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityResetResult.success(String message) {
    return SecurityResetResult._(
      success: true,
      message: message,
    );
  }

  factory SecurityResetResult.failure(
    String message,
    SecurityResetErrorType errorType,
  ) {
    return SecurityResetResult._(
      success: false,
      message: message,
      errorType: errorType,
    );
  }
}

/// Security question error types
enum SecurityQuestionErrorType {
  required,
  tooShort,
  tooLong,
  invalidFormat,
  tooCommon,
  containsPersonalInfo,
  noQuestionWords,
}

/// Security answer error types
enum SecurityAnswerErrorType {
  required,
  tooShort,
  tooLong,
  tooSimple,
  numericOnly,
  similarToQuestion,
  weakStrength,
}

/// Security verification error types
enum SecurityVerificationErrorType {
  notAuthenticated,
  noSecurityQuestion,
  incompleteData,
  incorrectAnswer,
  systemError,
}

/// Security reset error types
enum SecurityResetErrorType {
  verificationFailed,
  notAuthenticated,
  systemError,
}