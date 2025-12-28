/// Input validation message constants for the GuardianCare application.
///
/// This class provides a single source of truth for all validation messages
/// used in forms and input fields throughout the application.
///
/// ## Purpose
/// - Ensures consistent validation feedback across all forms
/// - Simplifies form validation implementation
/// - Enables easy updates to validation messages
/// - Supports future localization efforts
///
/// ## Categories
/// - **Required Field**: Messages for mandatory fields
/// - **Email Validation**: Email format and requirement messages
/// - **Password Validation**: Password strength and format messages
/// - **Name Validation**: Name format and length messages
/// - **Phone Validation**: Phone number format messages
/// - **General Format**: Generic format validation messages
/// - **Comment/Text Validation**: Text input validation messages
/// - **Consent Form Validation**: Parental consent form messages
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // In a form validator
/// String? validateEmail(String? value) {
///   if (value == null || value.isEmpty) {
///     return ValidationStrings.emailRequired;
///   }
///   if (!isValidEmail(value)) {
///     return ValidationStrings.emailInvalid;
///   }
///   return null;
/// }
///
/// // Using template methods for dynamic validation
/// String? validateLength(String value, int min, int max) {
///   if (value.length < min) {
///     return ValidationStrings.minLength(min);
///   }
///   if (value.length > max) {
///     return ValidationStrings.maxLength(max);
///   }
///   return null;
/// }
/// ```
///
/// ## Best Practices
/// - Use specific validation messages when available
/// - Use template methods for length/range validation
/// - Keep validation messages user-friendly and actionable
///
/// See also:
/// - [ErrorStrings] for system/technical error messages
/// - [FeedbackStrings] for SnackBar/toast feedback messages
class ValidationStrings {
  ValidationStrings._();

  // ==================== Required Field ====================
  static const String required = 'This field is required.';
  static const String fieldRequired = 'Please fill in this field.';
  static const String cannotBeEmpty = 'This field cannot be empty.';

  // ==================== Email Validation ====================
  static const String emailRequired = 'Please enter your email.';
  static const String emailInvalid = 'Please enter a valid email address.';
  static const String emailFormat = 'Email format is invalid.';

  // ==================== Password Validation ====================
  static const String passwordRequired = 'Please enter your password.';
  static const String passwordMinLength = 'Password must be at least 6 characters.';
  static const String passwordWeak = 'Password is too weak.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String passwordUppercase = 'Password must contain at least one uppercase letter.';
  static const String passwordLowercase = 'Password must contain at least one lowercase letter.';
  static const String passwordNumber = 'Password must contain at least one number.';
  static const String passwordSpecial = 'Password must contain at least one special character.';

  // ==================== Name Validation ====================
  static const String nameRequired = 'Please enter your name.';
  static const String nameInvalid = 'Please enter a valid name.';
  static const String nameTooShort = 'Name is too short.';
  static const String nameTooLong = 'Name is too long.';

  // ==================== Phone Validation ====================
  static const String phoneRequired = 'Please enter your phone number.';
  static const String phoneInvalid = 'Please enter a valid phone number.';

  // ==================== General Format ====================
  static const String invalidFormat = 'Invalid format.';
  static const String tooShort = 'Input is too short.';
  static const String tooLong = 'Input is too long.';
  static const String invalidCharacters = 'Contains invalid characters.';

  // ==================== Comment/Text Validation ====================
  static const String commentRequired = 'Please enter a comment.';
  static const String commentTooShort = 'Comment must be at least 2 characters.';
  static const String textTooLong = 'Text exceeds maximum length.';

  // ==================== Consent Form Validation ====================
  static const String parentEmailRequired = 'Please enter parent email';
  static const String childNameRequired = 'Please enter child name';
  static const String parentalKeyRequired = 'Please enter a parental key';
  static const String parentalKeyMinLength = 'Key must be at least 4 characters';
  static const String confirmParentalKeyRequired = 'Please confirm your parental key';
  static const String keysDoNotMatch = 'Keys do not match';
  static const String securityQuestionRequired = 'Please select a security question';
  static const String answerRequired = 'Please enter an answer';
  static const String answerMinLength = 'Answer must be at least 2 characters';
  static const String newKeyRequired = 'Please enter a new key';
  static const String confirmKeyRequired = 'Please confirm your key';

  // ==================== Template Methods ====================
  /// Creates a minimum length validation message
  static String minLength(int length) => 'Must be at least $length characters.';

  /// Creates a maximum length validation message
  static String maxLength(int length) => 'Must be at most $length characters.';

  /// Creates a minimum value validation message
  static String minValue(num value) => 'Must be at least $value.';

  /// Creates a maximum value validation message
  static String maxValue(num value) => 'Must be at most $value.';

  /// Creates a range validation message
  static String range(num min, num max) => 'Must be between $min and $max.';

  /// Creates a length range validation message
  static String lengthRange(int min, int max) =>
      'Must be between $min and $max characters.';
}
