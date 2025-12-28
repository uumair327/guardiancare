/// Centralized error message constants for the GuardianCare application.
///
/// This class provides a single source of truth for all error messages used
/// throughout the application, following Clean Architecture principles.
///
/// ## Purpose
/// - Ensures consistent error messaging across all features
/// - Simplifies maintenance by centralizing error text
/// - Enables easy updates to error messages without code changes
/// - Supports future localization efforts
///
/// ## Categories
/// - **Generic Errors**: General-purpose error messages
/// - **Network Errors**: Connection and timeout issues
/// - **Cache Errors**: Local storage failures
/// - **Server Errors**: Backend service issues
/// - **Authentication Errors**: Sign-in/sign-up failures
/// - **Permission Errors**: Authorization issues
/// - **Data Errors**: Data parsing and validation failures
/// - **Feature-Specific Errors**: Errors for specific features
/// - **Repository Errors**: Data layer error messages
/// - **Service Errors**: External service error messages
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // Static error message
/// throw ServerException(ErrorStrings.server);
///
/// // Dynamic error message using template method
/// throw ServerException(ErrorStrings.failedTo('load user data'));
///
/// // Error with reason
/// return Left(Failure(ErrorStrings.failedToWithReason('save', 'disk full')));
/// ```
///
/// ## Best Practices
/// - Use specific error messages when available (e.g., `networkError` vs `generic`)
/// - Use template methods for dynamic error messages
/// - For user-facing errors, consider using [FeedbackStrings] instead
///
/// See also:
/// - [FeedbackStrings] for user-friendly SnackBar/toast messages
/// - [ValidationStrings] for input validation errors
class ErrorStrings {
  ErrorStrings._();

  // ==================== Generic Errors ====================
  static const String generic = 'Something went wrong. Please try again.';
  static const String unknown = 'An unknown error occurred.';
  static const String unexpected = 'An unexpected error occurred.';

  // ==================== Network Errors ====================
  static const String network = 'Network error. Please check your connection.';
  static const String timeout = 'Request timed out. Please try again.';
  static const String noInternet = 'No internet connection.';
  static const String connectionFailed = 'Connection failed. Please try again.';

  // ==================== Cache Errors ====================
  static const String cacheRead = 'Failed to read from cache.';
  static const String cacheWrite = 'Failed to write to cache.';
  static const String cacheDelete = 'Failed to delete from cache.';
  static const String cacheNotFound = 'Data not found in cache.';

  // ==================== Server Errors ====================
  static const String server = 'Server error. Please try again later.';
  static const String serverUnavailable = 'Server is currently unavailable.';
  static const String serverMaintenance = 'Server is under maintenance.';
  static const String badResponse = 'Invalid response from server.';

  // ==================== Authentication Errors ====================
  static const String authFailed = 'Authentication failed.';
  static const String sessionExpired = 'Session expired. Please sign in again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String userNotFound = 'User not found.';
  static const String emailAlreadyInUse = 'Email is already in use.';
  static const String weakPassword = 'Password is too weak.';
  static const String wrongPassword = 'Wrong password provided.';
  static const String signInFailed = 'Sign in failed';
  static const String signUpFailed = 'Sign up failed';
  static const String signOutFailed = 'Sign out failed';
  static const String googleSignInCancelled = 'Google sign in cancelled';
  static const String googleSignInFailed = 'Google sign in failed';
  static const String noUserReturned = 'No user returned';
  static const String emailNotVerified = 'Please verify your email address. Check your inbox for the verification link.';
  static const String getCurrentUserError = 'Failed to get current user';
  static const String sendPasswordResetError = 'Failed to send password reset email';
  static const String updateProfileError = 'Failed to update profile';
  static const String noUserSignedIn = 'No user signed in';

  // ==================== Permission Errors ====================
  static const String permissionDenied = 'Permission denied.';
  static const String unauthorized = 'You are not authorized to perform this action.';

  // ==================== Data Errors ====================
  static const String dataNotFound = 'Data not found.';
  static const String invalidData = 'Invalid data received.';
  static const String parsingError = 'Failed to parse data.';

  // ==================== Feature-Specific Errors ====================
  static const String emailClientError = 'Could not launch email client';
  static const String loadingCarouselError = 'Error loading carousel data';
  static const String videoLoadError = 'Failed to load video.';
  static const String commentPostError = 'Failed to post comment.';
  static const String reportSubmitError = 'Failed to submit report.';

  // ==================== Repository Error Messages ====================
  // Report Repository
  static const String createReportError = 'Failed to create report';
  static const String loadReportError = 'Failed to load report';
  static const String saveReportError = 'Failed to save report';
  static const String deleteReportError = 'Failed to delete report';
  static const String getSavedReportsError = 'Failed to get saved reports';
  static const String checkReportExistenceError = 'Failed to check report existence';

  // Profile Repository
  static const String getProfileError = 'Failed to get profile';
  static const String deleteAccountError = 'Failed to delete account';
  static const String clearPreferencesError = 'Failed to clear preferences';

  // Quiz Repository
  static const String getQuizError = 'Failed to get quiz';
  static const String getQuestionsError = 'Failed to get questions';
  static const String submitQuizError = 'Failed to submit quiz';
  static const String validateQuizError = 'Failed to validate quiz';

  // Home Repository
  static const String loadCarouselItemsError = 'Failed to load carousel items';

  // Learn Repository
  static const String getCategoriesError = 'Failed to get categories';
  static const String getVideosByCategoryError = 'Failed to get videos by category';
  static const String streamVideosError = 'Failed to stream videos';

  // Consent Repository
  static const String submitConsentError = 'Failed to submit consent';
  static const String verifyKeyError = 'Failed to verify key';
  static const String resetKeyError = 'Failed to reset key';
  static const String getConsentError = 'Failed to get consent';
  static const String checkConsentError = 'Failed to check consent';
  static const String saveParentalKeyLocallyError = 'Failed to save parental key locally';
  static const String getLocalParentalKeyError = 'Failed to get local parental key';
  static const String consentNotFound = 'Consent not found';
  static const String incorrectSecurityAnswer = 'Incorrect security answer';

  // Emergency Repository
  static const String getEmergencyContactsError = 'Failed to get emergency contacts';
  static const String getContactsByCategoryError = 'Failed to get contacts by category';
  static const String makeEmergencyCallError = 'Failed to make emergency call';
  static const String phoneDialerError = 'Could not launch phone dialer';
  static const String makePhoneCallError = 'Failed to make phone call';

  // Forum Repository
  static const String unexpectedError = 'Unexpected error';
  static const String getCommentsError = 'Failed to get comments';
  static const String addCommentError = 'Failed to add comment';
  static const String getUserDetailsError = 'Failed to get user details';
  static const String createForumError = 'Failed to create forum';
  static const String deleteForumError = 'Failed to delete forum';
  static const String deleteCommentError = 'Failed to delete comment';

  // ==================== Service Errors ====================
  // Gemini AI Service
  static const String geminiCategoryEmpty = 'Category cannot be empty';
  static const String geminiNullResponse = 'Gemini API returned null response';
  static const String geminiNoSearchTerms = 'No valid search terms generated';
  static const String geminiApiError = 'Gemini API error';

  // YouTube Search Service
  static const String youtubeSearchTermEmpty = 'Search term cannot be empty';
  static const String youtubeInvalidTermFormat = 'Invalid search term format';
  static const String youtubeApiRequestFailed = 'YouTube API request failed with status';
  static const String youtubeNoVideosFound = 'No videos found for term';
  static const String youtubeApiError = 'YouTube API error';

  // ==================== Template Methods ====================
  /// Creates a "Failed to [action]" error message
  static String failedTo(String action) => 'Failed to $action.';

  /// Creates a "Failed to [action]: [reason]" error message
  static String failedToWithReason(String action, String reason) =>
      'Failed to $action: $reason';

  /// Creates a "Could not [action]" error message
  static String couldNot(String action) => 'Could not $action.';

  /// Creates an error message for a specific operation
  static String operationFailed(String operation) => '$operation failed.';

  /// Creates an error message with details
  static String withDetails(String baseError, String details) =>
      '$baseError: $details';
}
