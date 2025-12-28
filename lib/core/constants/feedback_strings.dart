/// SnackBar and toast message constants for the GuardianCare application.
///
/// This class provides a single source of truth for all user feedback messages
/// displayed via SnackBars, toasts, and dialogs throughout the application.
///
/// ## Purpose
/// - Ensures consistent user feedback across all features
/// - Provides user-friendly messages for success, error, and info states
/// - Simplifies feedback implementation with ready-to-use messages
/// - Supports future localization efforts
///
/// ## Categories
/// - **Success Messages**: Save, delete, update, submit confirmations
/// - **Authentication Success**: Sign in, sign out, sign up confirmations
/// - **Email Verification**: Email verification status messages
/// - **Forum/Comment Success**: Post and comment confirmations
/// - **Parental Controls**: Parental key management messages
/// - **Error Messages**: User-friendly error feedback
/// - **Validation Feedback**: Input validation feedback
/// - **Warning Messages**: Caution and confirmation prompts
/// - **Info Messages**: Informational hints and tips
/// - **Offline Messages**: Network status messages
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // Success feedback
/// ScaffoldMessenger.of(context).showSnackBar(
///   SnackBar(content: Text(FeedbackStrings.saveSuccess)),
/// );
///
/// // Error feedback
/// ScaffoldMessenger.of(context).showSnackBar(
///   SnackBar(
///     content: Text(FeedbackStrings.networkError),
///     backgroundColor: Colors.red,
///   ),
/// );
///
/// // Template methods for dynamic feedback
/// FeedbackStrings.itemSaved('Profile'); // "Profile saved successfully!"
/// FeedbackStrings.confirmAction('delete'); // "Are you sure you want to delete?"
/// FeedbackStrings.actionFailed('upload'); // "Failed to upload."
/// ```
///
/// ## Best Practices
/// - Use FeedbackStrings for user-facing feedback messages
/// - Use ErrorStrings for technical/system error messages
/// - Keep messages concise and actionable
/// - Use appropriate message type (success, error, warning, info)
///
/// See also:
/// - [ErrorStrings] for technical/system error messages
/// - [ValidationStrings] for form validation messages
/// - [UIStrings] for general UI text
class FeedbackStrings {
  FeedbackStrings._();

  // ==================== Success Messages ====================
  static const String saveSuccess = 'Saved successfully!';
  static const String deleteSuccess = 'Deleted successfully!';
  static const String updateSuccess = 'Updated successfully!';
  static const String submitSuccess = 'Submitted successfully!';
  static const String copySuccess = 'Copied to clipboard!';
  static const String downloadSuccess = 'Downloaded successfully!';
  static const String uploadSuccess = 'Uploaded successfully!';

  // ==================== Authentication Success ====================
  static const String signInSuccess = 'Signed in successfully!';
  static const String signOutSuccess = 'Signed out successfully!';
  static const String signUpSuccess = 'Account created successfully!';
  static const String passwordResetSent = 'Password reset email sent!';

  // ==================== Email Verification ====================
  static const String emailVerified = 'Email verified successfully!';
  static const String emailSent = 'Verification email sent! Please check your inbox.';
  static const String emailNotVerified = 'Email not verified yet. Please check your inbox.';
  static const String verificationEmailResent = 'Verification email resent!';

  // ==================== Forum/Comment Success ====================
  static const String commentPosted = 'Comment posted successfully!';
  static const String postCreated = 'Post created successfully!';
  static const String postDeleted = 'Post deleted successfully!';
  static const String replyPosted = 'Reply posted successfully!';

  // ==================== Parental Controls ====================
  static const String parentalKeyReset = 'Parental key reset successfully!';
  static const String newParentalKeyReady = 'You can now use your new parental key';
  static const String parentalKeyVerified = 'Parental key verified!';

  // ==================== Error Messages (User-Friendly) ====================
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String loadingError = 'Failed to load. Please try again.';
  static const String saveError = 'Failed to save. Please try again.';
  static const String deleteError = 'Failed to delete. Please try again.';

  // ==================== Validation Feedback ====================
  static const String enterComment = 'Please enter a comment';
  static const String commentTooShort = 'Comment must be at least 2 characters';
  static const String incorrectAnswer = 'Incorrect answer. Please try again.';
  static const String agreementRequired = 'Please agree to the terms and conditions.';
  static const String fillAllFields = 'Please fill in all required fields.';

  // ==================== Warning Messages ====================
  static const String unsavedChanges = 'You have unsaved changes.';
  static const String sessionExpiring = 'Your session is about to expire.';
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmSignOut = 'Are you sure you want to sign out?';


  // ==================== Info Messages ====================
  static const String fullscreenHint = 'Click the fullscreen button in the video player';
  static const String loadingContent = 'Loading content...';
  static const String pleaseWait = 'Please wait...';
  static const String processingRequest = 'Processing your request...';

  // ==================== Offline Messages ====================
  static const String offlineMode = 'You are currently offline.';
  static const String backOnline = 'You are back online!';
  static const String syncPending = 'Changes will sync when online.';

  // ==================== Template Methods ====================
  /// Creates an error message with details
  static String errorWith(String message) => 'Error: $message';

  /// Creates a launch error message
  static String launchError(String target) => 'Could not launch $target';

  /// Creates a success message for a specific action
  static String actionSuccess(String action) => '$action successful!';

  /// Creates a failure message for a specific action
  static String actionFailed(String action) => 'Failed to $action.';

  /// Creates a confirmation message
  static String confirmAction(String action) => 'Are you sure you want to $action?';

  /// Creates a "saved" message for a specific item
  static String itemSaved(String item) => '$item saved successfully!';

  /// Creates a "deleted" message for a specific item
  static String itemDeleted(String item) => '$item deleted successfully!';
}
