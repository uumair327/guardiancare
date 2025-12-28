# Design Document: String Centralization

## Overview

This design document outlines the architecture for centralizing all hardcoded strings in the GuardianCare Flutter application. The solution follows Clean Architecture principles and SOLID design patterns, organizing strings into logical categories while maintaining feature-level separation where appropriate.

## Architecture

The string centralization system follows a layered approach:

```
lib/
├── core/
│   └── constants/
│       ├── constants.dart          # Barrel file (exports all)
│       ├── app_strings.dart        # Core app strings (existing, extended)
│       ├── error_strings.dart      # Error messages (NEW)
│       ├── validation_strings.dart # Validation messages (NEW)
│       ├── ui_strings.dart         # UI text constants (NEW)
│       ├── feedback_strings.dart   # SnackBar/Toast messages (NEW)
│       ├── firebase_strings.dart   # Firebase collection names (NEW)
│       └── api_strings.dart        # API-related strings (NEW)
│
└── features/
    └── {feature}/
        └── presentation/
            └── constants/
                └── strings.dart    # Feature-specific strings
```

## Components and Interfaces

### Core String Classes

#### 1. AppStrings (Extended)
```dart
/// Core application strings - non-localized constants
/// Location: lib/core/constants/app_strings.dart
class AppStrings {
  AppStrings._();
  
  // App Info
  static const String appName = 'Guardian Care';
  static const String appTagline = 'A Children of India App';
  
  // URLs
  static const String websiteUrl = 'https://childrenofindia.in/';
  static const String supportEmail = 'hello@childrenofindia.in';
  
  // Asset Paths
  static const String logoPath = 'assets/logo/logo.png';
  static const String logoSplashPath = 'assets/logo/logo_splash.png';
}
```

#### 2. ErrorStrings (NEW)
```dart
/// Centralized error message constants
/// Location: lib/core/constants/error_strings.dart
class ErrorStrings {
  ErrorStrings._();
  
  // Generic Errors
  static const String generic = 'Something went wrong. Please try again.';
  static const String unknown = 'An unknown error occurred.';
  
  // Network Errors
  static const String network = 'Network error. Please check your connection.';
  static const String timeout = 'Request timed out. Please try again.';
  static const String noInternet = 'No internet connection.';
  
  // Cache Errors
  static const String cacheRead = 'Failed to read from cache.';
  static const String cacheWrite = 'Failed to write to cache.';
  static const String cacheDelete = 'Failed to delete from cache.';
  
  // Server Errors
  static const String server = 'Server error. Please try again later.';
  static const String serverUnavailable = 'Server is currently unavailable.';
  
  // Authentication Errors
  static const String authFailed = 'Authentication failed.';
  static const String sessionExpired = 'Session expired. Please sign in again.';
  static const String invalidCredentials = 'Invalid email or password.';
  
  // Template methods for dynamic errors
  static String failedTo(String action) => 'Failed to $action.';
  static String failedToWithReason(String action, String reason) => 
      'Failed to $action: $reason';
}
```

#### 3. ValidationStrings (NEW)
```dart
/// Input validation message constants
/// Location: lib/core/constants/validation_strings.dart
class ValidationStrings {
  ValidationStrings._();
  
  // Required Field
  static const String required = 'This field is required.';
  static const String fieldRequired = 'Please fill in this field.';
  
  // Email Validation
  static const String emailRequired = 'Please enter your email.';
  static const String emailInvalid = 'Please enter a valid email address.';
  
  // Password Validation
  static const String passwordRequired = 'Please enter your password.';
  static const String passwordMinLength = 'Password must be at least 6 characters.';
  static const String passwordWeak = 'Password is too weak.';
  static const String passwordMismatch = 'Passwords do not match.';
  
  // Name Validation
  static const String nameRequired = 'Please enter your name.';
  static const String nameInvalid = 'Please enter a valid name.';
  
  // General Format
  static const String invalidFormat = 'Invalid format.';
  static const String tooShort = 'Input is too short.';
  static const String tooLong = 'Input is too long.';
  
  // Template methods
  static String minLength(int length) => 'Must be at least $length characters.';
  static String maxLength(int length) => 'Must be at most $length characters.';
  static String minValue(num value) => 'Must be at least $value.';
}
```

#### 4. UIStrings (NEW)
```dart
/// UI text constants (labels, buttons, titles)
/// Location: lib/core/constants/ui_strings.dart
class UIStrings {
  UIStrings._();
  
  // Common Buttons
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String goBack = 'Go Back';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String tryAgain = 'Try Again';
  static const String close = 'Close';
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String signUp = 'Sign Up';
  static const String iAgree = 'I Agree';
  
  // Common Labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Name';
  static const String phone = 'Phone';
  
  // Common Titles
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Information';
  
  // Time-based Greetings
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  
  // Relative Time
  static const String justNow = 'Just now';
  static String minutesAgo(int minutes) => '${minutes}m ago';
  static String hoursAgo(int hours) => '${hours}h ago';
  static String daysAgo(int days) => '${days}d ago';
  
  // Content States
  static const String noData = 'No data available.';
  static const String empty = 'Nothing here yet.';
  static const String contentUnavailable = 'Content unavailable';
  static const String imageUnavailable = 'Image unavailable';
  
  // Actions
  static const String showMore = 'Show more';
  static const String showLess = 'Show less';
  static const String seeAll = 'See All';
  static const String viewAll = 'View All';
}
```

#### 5. FeedbackStrings (NEW)
```dart
/// SnackBar and toast message constants
/// Location: lib/core/constants/feedback_strings.dart
class FeedbackStrings {
  FeedbackStrings._();
  
  // Success Messages
  static const String saveSuccess = 'Saved successfully!';
  static const String deleteSuccess = 'Deleted successfully!';
  static const String updateSuccess = 'Updated successfully!';
  static const String submitSuccess = 'Submitted successfully!';
  static const String emailVerified = 'Email verified successfully!';
  static const String emailSent = 'Verification email sent! Please check your inbox.';
  static const String commentPosted = 'Comment posted successfully!';
  static const String parentalKeyReset = 'Parental key reset successfully!';
  static const String newParentalKeyReady = 'You can now use your new parental key';
  
  // Error Messages (User-Friendly)
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String emailNotVerified = 'Email not verified yet. Please check your inbox.';
  static const String incorrectAnswer = 'Incorrect answer. Please try again.';
  static const String agreementRequired = 'Please agree to the terms and conditions.';
  
  // Warning Messages
  static const String unsavedChanges = 'You have unsaved changes.';
  static const String sessionExpiring = 'Your session is about to expire.';
  
  // Info Messages
  static const String fullscreenHint = 'Click the fullscreen button in the video player';
  
  // Input Validation Feedback
  static const String enterComment = 'Please enter a comment';
  static const String commentTooShort = 'Comment must be at least 2 characters';
  
  // Template methods
  static String errorWith(String message) => 'Error: $message';
  static String launchError(String target) => 'Could not launch $target';
}
```

#### 6. FirebaseStrings (NEW)
```dart
/// Firebase collection and document name constants
/// Location: lib/core/constants/firebase_strings.dart
class FirebaseStrings {
  FirebaseStrings._();
  
  // Collections
  static const String users = 'users';
  static const String carouselItems = 'carousel_items';
  static const String forumPosts = 'forum_posts';
  static const String comments = 'comments';
  static const String recommendations = 'recommendations';
  static const String reports = 'reports';
  static const String quizResults = 'quiz_results';
  
  // Document Fields
  static const String fieldUserId = 'userId';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldEmail = 'email';
  static const String fieldName = 'name';
  static const String fieldRole = 'role';
}
```

#### 7. ApiStrings (NEW)
```dart
/// API-related string constants
/// Location: lib/core/constants/api_strings.dart
class ApiStrings {
  ApiStrings._();
  
  // Base URLs
  static const String youtubeApiBase = 'https://www.googleapis.com/youtube/v3';
  static const String geminiApiBase = 'https://generativelanguage.googleapis.com';
  
  // Endpoints
  static const String youtubeSearch = '/search';
  static const String youtubeVideos = '/videos';
  
  // Query Parameters
  static const String paramPart = 'part';
  static const String paramQuery = 'q';
  static const String paramKey = 'key';
  static const String paramMaxResults = 'maxResults';
  static const String paramType = 'type';
  
  // Content Types
  static const String contentTypeJson = 'application/json';
  
  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
}
```

### Feature-Specific String Classes

#### Example: Forum Feature Strings
```dart
/// Forum feature-specific strings
/// Location: lib/features/forum/presentation/constants/strings.dart
class ForumStrings {
  ForumStrings._();
  
  // Page Titles
  static const String pageTitle = 'Forum';
  static const String guidelinesTitle = 'Forum Guidelines';
  
  // Labels
  static const String forChildren = 'For Children';
  static const String communityDiscussion = 'Community Discussion';
  
  // Actions
  static const String postComment = 'Post Comment';
  static const String replyToComment = 'Reply';
}
```

## Data Models

No new data models are required. String constants are static compile-time values.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, most acceptance criteria are testable as specific examples (file existence, content verification). One property-based test is identified for string value preservation.

### Property 1: String Value Preservation

*For any* hardcoded string that is migrated to a constant, the constant value SHALL be exactly equal to the original hardcoded string value.

**Validates: Requirements 8.3**

This property ensures that when we replace a hardcoded string like `'Something went wrong'` with `ErrorStrings.generic`, the constant value is identical to the original string, preserving application behavior.

### Property 2: Barrel File Export Completeness

*For any* string constant class created in `lib/core/constants/`, it SHALL be exported through the `constants.dart` barrel file.

**Validates: Requirements 8.2**

This property ensures all new string classes are accessible via a single import statement.

## Error Handling

### String Not Found
When a required string constant is not defined:
- Compile-time error will occur (Dart's static analysis)
- No runtime fallback needed as constants are compile-time checked

### Migration Errors
When migrating hardcoded strings:
- Use IDE refactoring tools to ensure all usages are updated
- Run `flutter analyze` to catch any missing imports
- Run existing tests to verify no behavioral changes

## Testing Strategy

### Unit Tests
Unit tests will verify:
1. **File Existence**: Each new string file exists at the expected path
2. **Class Structure**: Each string class has expected constants
3. **Export Completeness**: Barrel file exports all string classes
4. **No Localization Duplication**: Constants don't duplicate AppLocalizations keys

### Property-Based Tests
Property tests will verify:
1. **String Value Preservation**: Migrated strings maintain exact values

### Test Configuration
- Use `flutter_test` for unit tests
- Tests located in `test/core/constants/`
- Minimum 100 iterations for property tests (if applicable)

### Example Test Structure
```dart
// test/core/constants/string_constants_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/constants/constants.dart';

void main() {
  group('ErrorStrings', () {
    test('should have generic error message', () {
      expect(ErrorStrings.generic, isNotEmpty);
      expect(ErrorStrings.generic, contains('wrong'));
    });
    
    test('should have network error message', () {
      expect(ErrorStrings.network, isNotEmpty);
    });
  });
  
  group('UIStrings', () {
    test('should have common button labels', () {
      expect(UIStrings.ok, equals('OK'));
      expect(UIStrings.cancel, equals('Cancel'));
      expect(UIStrings.save, equals('Save'));
    });
  });
  
  group('Barrel File Exports', () {
    test('should export all string classes', () {
      // Verify imports work (compile-time check)
      expect(AppStrings.appName, isNotEmpty);
      expect(ErrorStrings.generic, isNotEmpty);
      expect(ValidationStrings.required, isNotEmpty);
      expect(UIStrings.ok, isNotEmpty);
      expect(FeedbackStrings.saveSuccess, isNotEmpty);
      expect(FirebaseStrings.users, isNotEmpty);
      expect(ApiStrings.youtubeApiBase, isNotEmpty);
    });
  });
}
```

## Implementation Notes

### Migration Strategy
1. Create new string constant files first
2. Update barrel file to export new classes
3. Migrate hardcoded strings feature by feature
4. Run tests after each feature migration
5. Remove any duplicate strings

### Localization Consideration
- Strings that need translation should use `AppLocalizations` (l10n)
- Constants are for non-localized strings only:
  - Technical identifiers (collection names, API endpoints)
  - Error codes and technical messages
  - Asset paths and URLs
  - Strings that are the same in all languages

### Import Pattern
```dart
// Single import for all constants
import 'package:guardiancare/core/constants/constants.dart';

// Usage
Text(UIStrings.signIn);
Text(ErrorStrings.network);
```

