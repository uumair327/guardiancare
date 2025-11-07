import 'dart:async';
import 'package:flutter/foundation.dart';

/// Enhanced consent form validation service with real-time validation
class ConsentFormValidationService extends ChangeNotifier {
  static ConsentFormValidationService? _instance;
  
  ConsentFormValidationService._();
  
  static ConsentFormValidationService get instance {
    _instance ??= ConsentFormValidationService._();
    return _instance!;
  }

  // Validation state for each field
  final Map<String, ValidationResult> _fieldValidations = {};
  final Map<String, bool> _requiredCheckboxes = {};
  
  // Real-time validation timers
  final Map<String, Timer> _validationTimers = {};
  
  // Form submission state
  bool _isSubmitting = false;
  bool _hasAttemptedSubmission = false;

  /// Get validation result for a specific field
  ValidationResult? getFieldValidation(String fieldName) {
    return _fieldValidations[fieldName];
  }

  /// Check if form is valid for submission
  bool get isFormValid {
    // Check all field validations
    final hasInvalidFields = _fieldValidations.values
        .any((validation) => !validation.isValid);
    
    // Check required checkboxes
    final hasUncheckedRequired = _requiredCheckboxes.values
        .any((isChecked) => !isChecked);
    
    return !hasInvalidFields && !hasUncheckedRequired;
  }

  /// Check if form has been attempted for submission
  bool get hasAttemptedSubmission => _hasAttemptedSubmission;

  /// Check if form is currently being submitted
  bool get isSubmitting => _isSubmitting;

  /// Get overall form validation summary
  FormValidationSummary get validationSummary {
    final invalidFields = _fieldValidations.entries
        .where((entry) => !entry.value.isValid)
        .map((entry) => entry.key)
        .toList();
    
    final uncheckedRequired = _requiredCheckboxes.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    return FormValidationSummary(
      isValid: isFormValid,
      invalidFields: invalidFields,
      uncheckedRequiredCheckboxes: uncheckedRequired,
      totalErrors: invalidFields.length + uncheckedRequired.length,
    );
  }

  /// Validate parent name field
  void validateParentName(String? value, {bool realTime = false}) {
    _validateWithDelay('parentName', () {
      if (value == null || value.trim().isEmpty) {
        return ValidationResult.invalid('Parent name is required');
      }
      
      if (value.trim().length < 2) {
        return ValidationResult.invalid('Parent name must be at least 2 characters');
      }
      
      if (value.trim().length > 50) {
        return ValidationResult.invalid('Parent name must be less than 50 characters');
      }
      
      // Check for valid name format (letters, spaces, hyphens, apostrophes)
      if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
        return ValidationResult.invalid('Parent name contains invalid characters');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Validate parent email field
  void validateParentEmail(String? value, {bool realTime = false}) {
    _validateWithDelay('parentEmail', () {
      if (value == null || value.trim().isEmpty) {
        return ValidationResult.invalid('Parent email is required');
      }
      
      // Enhanced email validation
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      );
      
      if (!emailRegex.hasMatch(value.trim())) {
        return ValidationResult.invalid('Please enter a valid email address');
      }
      
      // Check for common email format issues
      if (value.contains('..') || value.startsWith('.') || value.endsWith('.')) {
        return ValidationResult.invalid('Email format is invalid');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Validate child name field
  void validateChildName(String? value, {bool realTime = false}) {
    _validateWithDelay('childName', () {
      if (value == null || value.trim().isEmpty) {
        return ValidationResult.invalid('Child name is required');
      }
      
      if (value.trim().length < 2) {
        return ValidationResult.invalid('Child name must be at least 2 characters');
      }
      
      if (value.trim().length > 50) {
        return ValidationResult.invalid('Child name must be less than 50 characters');
      }
      
      // Check for valid name format
      if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(value.trim())) {
        return ValidationResult.invalid('Child name contains invalid characters');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Validate parental key field with enhanced security requirements
  void validateParentalKey(String? value, {bool realTime = false}) {
    _validateWithDelay('parentalKey', () {
      if (value == null || value.isEmpty) {
        return ValidationResult.invalid('Parental key is required');
      }
      
      if (value.length < 8) {
        return ValidationResult.invalid('Parental key must be at least 8 characters');
      }
      
      if (value.length > 128) {
        return ValidationResult.invalid('Parental key must be less than 128 characters');
      }
      
      // Check for complexity requirements
      final hasUppercase = value.contains(RegExp(r'[A-Z]'));
      final hasLowercase = value.contains(RegExp(r'[a-z]'));
      final hasDigits = value.contains(RegExp(r'[0-9]'));
      final hasSpecialChars = value.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'));
      
      final missingRequirements = <String>[];
      if (!hasUppercase) missingRequirements.add('uppercase letter');
      if (!hasLowercase) missingRequirements.add('lowercase letter');
      if (!hasDigits) missingRequirements.add('number');
      if (!hasSpecialChars) missingRequirements.add('special character');
      
      if (missingRequirements.isNotEmpty) {
        return ValidationResult.invalid(
          'Parental key must include: ${missingRequirements.join(', ')}'
        );
      }
      
      // Check for common weak patterns
      if (_isWeakPassword(value)) {
        return ValidationResult.invalid('Parental key is too common or predictable');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Validate parental key confirmation
  void validateParentalKeyConfirmation(
    String? value, 
    String? originalKey, 
    {bool realTime = false}
  ) {
    _validateWithDelay('parentalKeyConfirmation', () {
      if (value == null || value.isEmpty) {
        return ValidationResult.invalid('Please confirm your parental key');
      }
      
      if (originalKey == null || originalKey.isEmpty) {
        return ValidationResult.invalid('Please enter the original parental key first');
      }
      
      if (value != originalKey) {
        return ValidationResult.invalid('Parental keys do not match');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Validate security question field
  void validateSecurityQuestion(String? value, {bool realTime = false}) {
    _validateWithDelay('securityQuestion', () {
      if (value == null || value.trim().isEmpty) {
        return ValidationResult.invalid('Security question is required');
      }
      
      if (value.trim().length < 10) {
        return ValidationResult.invalid('Security question must be at least 10 characters');
      }
      
      if (value.trim().length > 200) {
        return ValidationResult.invalid('Security question must be less than 200 characters');
      }
      
      // Check if it's actually a question
      if (!value.trim().endsWith('?')) {
        return ValidationResult.invalid('Security question should end with a question mark');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Validate security answer field
  void validateSecurityAnswer(String? value, {bool realTime = false}) {
    _validateWithDelay('securityAnswer', () {
      if (value == null || value.trim().isEmpty) {
        return ValidationResult.invalid('Security answer is required');
      }
      
      if (value.trim().length < 2) {
        return ValidationResult.invalid('Security answer must be at least 2 characters');
      }
      
      if (value.trim().length > 100) {
        return ValidationResult.invalid('Security answer must be less than 100 characters');
      }
      
      // Check for overly simple answers
      if (_isSimpleAnswer(value.trim())) {
        return ValidationResult.invalid('Please provide a more specific security answer');
      }
      
      return ValidationResult.valid();
    }, realTime);
  }

  /// Set checkbox validation state
  void setCheckboxValidation(String checkboxName, bool isChecked, {required bool isRequired}) {
    if (isRequired) {
      _requiredCheckboxes[checkboxName] = isChecked;
    }
    
    if (!isChecked && isRequired) {
      _fieldValidations[checkboxName] = ValidationResult.invalid(
        '${_formatFieldName(checkboxName)} is required'
      );
    } else {
      _fieldValidations[checkboxName] = ValidationResult.valid();
    }
    
    notifyListeners();
  }

  /// Validate all required checkboxes
  void validateRequiredCheckboxes(Map<String, bool> checkboxStates) {
    final requiredCheckboxes = {
      'parentConsentGiven': 'Parent consent',
      'termsAccepted': 'Terms and conditions',
      'privacyPolicyAccepted': 'Privacy policy',
      'dataProcessingConsent': 'Data processing consent',
    };

    for (final entry in requiredCheckboxes.entries) {
      final checkboxName = entry.key;
      final displayName = entry.value;
      final isChecked = checkboxStates[checkboxName] ?? false;
      
      _requiredCheckboxes[checkboxName] = isChecked;
      
      if (!isChecked) {
        _fieldValidations[checkboxName] = ValidationResult.invalid(
          '$displayName must be accepted'
        );
      } else {
        _fieldValidations[checkboxName] = ValidationResult.valid();
      }
    }
    
    notifyListeners();
  }

  /// Validate entire form before submission
  FormValidationResult validateFormForSubmission({
    required String parentName,
    required String parentEmail,
    required String childName,
    required String parentalKey,
    required String parentalKeyConfirmation,
    required String securityQuestion,
    required String securityAnswer,
    required Map<String, bool> checkboxStates,
  }) {
    _hasAttemptedSubmission = true;
    
    // Validate all fields
    validateParentName(parentName);
    validateParentEmail(parentEmail);
    validateChildName(childName);
    validateParentalKey(parentalKey);
    validateParentalKeyConfirmation(parentalKeyConfirmation, parentalKey);
    validateSecurityQuestion(securityQuestion);
    validateSecurityAnswer(securityAnswer);
    validateRequiredCheckboxes(checkboxStates);
    
    final summary = validationSummary;
    
    return FormValidationResult(
      isValid: summary.isValid,
      errors: _collectAllErrors(),
      fieldErrors: Map.fromEntries(
        _fieldValidations.entries
            .where((entry) => !entry.value.isValid)
            .map((entry) => MapEntry(entry.key, entry.value.errorMessage!))
      ),
    );
  }

  /// Set form submission state
  void setSubmissionState(bool isSubmitting) {
    _isSubmitting = isSubmitting;
    notifyListeners();
  }

  /// Reset form validation state
  void resetValidation() {
    _fieldValidations.clear();
    _requiredCheckboxes.clear();
    _hasAttemptedSubmission = false;
    _isSubmitting = false;
    
    // Cancel all pending validation timers
    for (final timer in _validationTimers.values) {
      timer.cancel();
    }
    _validationTimers.clear();
    
    notifyListeners();
  }

  /// Clear validation for a specific field
  void clearFieldValidation(String fieldName) {
    _fieldValidations.remove(fieldName);
    _validationTimers[fieldName]?.cancel();
    _validationTimers.remove(fieldName);
    notifyListeners();
  }

  /// Validate with debouncing for real-time validation
  void _validateWithDelay(
    String fieldName, 
    ValidationResult Function() validator,
    bool realTime,
  ) {
    if (realTime) {
      // Cancel existing timer for this field
      _validationTimers[fieldName]?.cancel();
      
      // Set new timer with debouncing
      _validationTimers[fieldName] = Timer(const Duration(milliseconds: 500), () {
        final result = validator();
        _fieldValidations[fieldName] = result;
        notifyListeners();
      });
    } else {
      // Immediate validation
      final result = validator();
      _fieldValidations[fieldName] = result;
      notifyListeners();
    }
  }

  /// Check if password is weak or common
  bool _isWeakPassword(String password) {
    final commonPasswords = [
      'password', '12345678', 'qwerty', 'abc123', 'password123',
      'admin', 'letmein', 'welcome', 'monkey', '1234567890'
    ];
    
    final lowerPassword = password.toLowerCase();
    
    // Check against common passwords
    if (commonPasswords.contains(lowerPassword)) {
      return true;
    }
    
    // Check for simple patterns
    if (RegExp(r'^(.)\1+$').hasMatch(password)) { // All same character
      return true;
    }
    
    if (RegExp(r'^(012|123|234|345|456|567|678|789|890|abc|bcd|cde)').hasMatch(lowerPassword)) {
      return true; // Sequential patterns
    }
    
    return false;
  }

  /// Check if security answer is too simple
  bool _isSimpleAnswer(String answer) {
    final simpleAnswers = [
      'yes', 'no', 'maybe', 'ok', 'fine', 'good', 'bad', 'none', 'n/a'
    ];
    
    return simpleAnswers.contains(answer.toLowerCase()) || answer.length < 3;
  }

  /// Format field name for display
  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Collect all validation errors
  List<String> _collectAllErrors() {
    final errors = <String>[];
    
    // Add field validation errors
    for (final validation in _fieldValidations.values) {
      if (!validation.isValid && validation.errorMessage != null) {
        errors.add(validation.errorMessage!);
      }
    }
    
    // Add checkbox errors
    for (final entry in _requiredCheckboxes.entries) {
      if (!entry.value) {
        errors.add('${_formatFieldName(entry.key)} is required');
      }
    }
    
    return errors;
  }

  @override
  void dispose() {
    // Cancel all timers
    for (final timer in _validationTimers.values) {
      timer.cancel();
    }
    _validationTimers.clear();
    super.dispose();
  }
}

/// Result of field validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ValidationSeverity severity;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.severity = ValidationSeverity.error,
  });

  factory ValidationResult.valid() {
    return const ValidationResult._(isValid: true);
  }

  factory ValidationResult.invalid(String message, {ValidationSeverity? severity}) {
    return ValidationResult._(
      isValid: false,
      errorMessage: message,
      severity: severity ?? ValidationSeverity.error,
    );
  }

  factory ValidationResult.warning(String message) {
    return ValidationResult._(
      isValid: true,
      errorMessage: message,
      severity: ValidationSeverity.warning,
    );
  }
}

/// Validation severity levels
enum ValidationSeverity {
  info,
  warning,
  error,
  critical,
}

/// Overall form validation summary
class FormValidationSummary {
  final bool isValid;
  final List<String> invalidFields;
  final List<String> uncheckedRequiredCheckboxes;
  final int totalErrors;

  const FormValidationSummary({
    required this.isValid,
    required this.invalidFields,
    required this.uncheckedRequiredCheckboxes,
    required this.totalErrors,
  });

  bool get hasFieldErrors => invalidFields.isNotEmpty;
  bool get hasCheckboxErrors => uncheckedRequiredCheckboxes.isNotEmpty;
}

/// Result of complete form validation
class FormValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, String> fieldErrors;

  const FormValidationResult({
    required this.isValid,
    required this.errors,
    required this.fieldErrors,
  });

  String? getFieldError(String fieldName) => fieldErrors[fieldName];
  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);
  int get totalErrors => errors.length;
}