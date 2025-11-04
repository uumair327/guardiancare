# Design Document

## Overview

This design document outlines the architectural improvements and implementation strategies to fix critical business logic issues across the GuardianCare Flutter application. The solution focuses on implementing robust state management, proper validation mechanisms, security enhancements, and user experience improvements.

## Architecture

### State Management Strategy

The application will implement a layered state management approach:

1. **Local Component State**: For UI-specific states (loading, validation errors)
2. **Feature-Level State**: For business logic states using BLoC pattern where appropriate
3. **Global State**: For user authentication and app-wide settings
4. **Persistent State**: For form data and user preferences using SharedPreferences

### Security Layer

A centralized security service will handle:
- Parental control verification with attempt limiting
- Session management and timeout handling
- Input validation and sanitization
- Error handling with security considerations

## Components and Interfaces

### 1. Enhanced Quiz System

#### QuizStateManager
```dart
class QuizStateManager {
  Map<int, int?> _lockedAnswers = {};
  Map<int, bool> _questionAnswered = {};
  bool _quizCompleted = false;
  
  bool isAnswerLocked(int questionIndex);
  void lockAnswer(int questionIndex, int answerIndex);
  bool canNavigateToQuestion(int questionIndex);
  void completeQuiz();
}
```

#### QuizValidationService
```dart
class QuizValidationService {
  static bool canSelectAnswer(int questionIndex, QuizStateManager state);
  static bool canNavigateNext(int questionIndex, QuizStateManager state);
  static QuizResult calculateFinalScore(QuizStateManager state, List<Question> questions);
}
```

### 2. Parental Control Security System

#### AttemptLimitingService
```dart
class AttemptLimitingService {
  static const int MAX_ATTEMPTS = 3;
  static const Duration LOCKOUT_DURATION = Duration(minutes: 5);
  
  Map<String, AttemptTracker> _userAttempts = {};
  
  bool canAttemptVerification(String userId);
  void recordFailedAttempt(String userId);
  void recordSuccessfulAttempt(String userId);
  Duration getRemainingLockoutTime(String userId);
}
```

#### SecureParentalController
```dart
class SecureParentalController extends ConsentController {
  final AttemptLimitingService _attemptService;
  
  Future<ParentalVerificationResult> verifyWithAttemptLimiting(
    BuildContext context, 
    String enteredKey
  );
  
  Future<void> showSecureVerificationDialog(
    BuildContext context,
    VoidCallback onSuccess,
    VoidCallback onError
  );
}
```

### 3. Report System with State Management

#### ReportFormState
```dart
class ReportFormState {
  Map<String, bool> _checkboxStates = {};
  String _selectedIncidentType = '';
  String _description = '';
  bool _isSubmitting = false;
  
  void updateCheckboxState(String questionId, bool value);
  bool validateForm();
  Map<String, dynamic> getFormData();
  void clearForm();
}
```

#### ReportFormController
```dart
class ReportFormController {
  final ReportFormState _state = ReportFormState();
  
  void handleCheckboxChange(String questionId, bool value);
  Future<bool> submitReport();
  bool canSubmitForm();
  void saveFormState(); // For persistence
  void loadFormState(); // For restoration
}
```

### 4. Enhanced Forum System

#### CommentSubmissionService
```dart
class CommentSubmissionService {
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);
  
  Future<CommentSubmissionResult> submitWithRetry(
    String forumId, 
    String commentText
  );
  
  Future<bool> validateCommentContent(String content);
  void handleSubmissionError(Exception error);
}
```

#### ForumStateManager
```dart
class ForumStateManager {
  bool _isSubmittingComment = false;
  String _draftComment = '';
  
  void setSubmissionState(bool isSubmitting);
  void saveDraftComment(String content);
  void clearDraftComment();
  bool canSubmitComment();
}
```

### 5. Authentication Enhancement

#### AuthenticationService (Enhanced)
```dart
class AuthenticationService {
  static const int MAX_AUTH_RETRIES = 3;
  
  Future<AuthResult> authenticateWithRetry();
  Future<bool> validateUserProfile(User user);
  Future<void> handleAuthenticationError(Exception error);
  Future<void> secureSignOut();
  bool isSessionValid();
}
```

#### SessionManager
```dart
class SessionManager {
  Timer? _sessionTimer;
  static const Duration SESSION_TIMEOUT = Duration(hours: 2);
  
  void startSessionTimer();
  void resetSessionTimer();
  void handleSessionExpiry();
  bool isSessionActive();
}
```

## Data Models

### Enhanced Models

#### QuizAnswer
```dart
class QuizAnswer {
  final int questionIndex;
  final int selectedAnswerIndex;
  final DateTime answeredAt;
  final bool isLocked;
  final bool isCorrect;
}
```

#### ParentalVerificationAttempt
```dart
class ParentalVerificationAttempt {
  final String userId;
  final DateTime attemptTime;
  final bool wasSuccessful;
  final String? errorCode;
}
```

#### ReportFormData
```dart
class ReportFormData {
  final String incidentType;
  final Map<String, bool> questionResponses;
  final String description;
  final DateTime createdAt;
  final bool isComplete;
}
```

#### CommentDraft
```dart
class CommentDraft {
  final String forumId;
  final String content;
  final DateTime lastModified;
  final bool isBeingSubmitted;
}
```

## Error Handling

### Centralized Error Management

#### AppErrorHandler
```dart
class AppErrorHandler {
  static void handleQuizError(QuizException error, BuildContext context);
  static void handleAuthError(AuthException error, BuildContext context);
  static void handleNetworkError(NetworkException error, BuildContext context);
  static void handleValidationError(ValidationException error, BuildContext context);
  
  static void logError(Exception error, StackTrace stackTrace);
  static void showUserFriendlyError(String message, BuildContext context);
}
```

### Error Types

#### Custom Exception Classes
```dart
class QuizStateException extends AppException {
  final QuizErrorType type;
  QuizStateException(String message, this.type) : super(message);
}

class ParentalControlException extends AppException {
  final ParentalControlErrorType type;
  ParentalControlException(String message, this.type) : super(message);
}

class FormValidationException extends AppException {
  final Map<String, String> fieldErrors;
  FormValidationException(String message, this.fieldErrors) : super(message);
}
```

## Testing Strategy

### Unit Testing

1. **State Management Tests**
   - Quiz state transitions and locking mechanisms
   - Parental control attempt limiting logic
   - Form validation and state persistence
   - Comment submission retry logic

2. **Service Layer Tests**
   - Authentication retry mechanisms
   - Error handling and recovery
   - Data validation services
   - Security verification logic

### Integration Testing

1. **User Flow Tests**
   - Complete quiz taking flow with answer locking
   - Parental control verification with lockout scenarios
   - Report form submission with state persistence
   - Forum comment submission with error recovery

2. **Security Tests**
   - Parental key brute force protection
   - Session timeout and renewal
   - Input validation and sanitization
   - Error message information disclosure

### Widget Testing

1. **UI Component Tests**
   - Quiz question widget state management
   - Checkbox state persistence in report forms
   - Comment input validation and submission states
   - Error dialog and snackbar displays

2. **User Interaction Tests**
   - Button state management during async operations
   - Form field validation and error display
   - Navigation state preservation
   - Loading state indicators

## Implementation Phases

### Phase 1: Core State Management
- Implement QuizStateManager with answer locking
- Create AttemptLimitingService for parental controls
- Add ReportFormState for checkbox management
- Implement basic error handling framework

### Phase 2: Security Enhancements
- Integrate attempt limiting into parental controls
- Add session management and timeout handling
- Implement secure authentication retry logic
- Add input validation and sanitization

### Phase 3: User Experience Improvements
- Add form state persistence across navigation
- Implement comment draft saving and recovery
- Add loading states and progress indicators
- Improve error messages and user feedback

### Phase 4: Testing and Validation
- Comprehensive unit test coverage
- Integration testing for critical user flows
- Security testing for authentication and parental controls
- Performance testing for state management operations

## Security Considerations

1. **Parental Control Security**
   - Implement proper attempt limiting with exponential backoff
   - Add rate limiting for verification requests
   - Secure storage of hashed parental keys
   - Audit logging for security events

2. **Session Security**
   - Implement proper session timeout handling
   - Add secure token refresh mechanisms
   - Clear sensitive data on logout
   - Handle concurrent session scenarios

3. **Input Validation**
   - Sanitize all user inputs
   - Validate data types and ranges
   - Prevent injection attacks
   - Handle malformed data gracefully

4. **Error Handling Security**
   - Avoid information disclosure in error messages
   - Log security events appropriately
   - Handle edge cases securely
   - Implement proper fallback mechanisms