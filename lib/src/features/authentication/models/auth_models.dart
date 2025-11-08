import 'package:firebase_auth/firebase_auth.dart';

/// Types of authentication errors for better categorization
enum AuthErrorType {
  network,
  credential,
  permission,
  validation,
  timeout,
  cancelled,
  system,
}

/// Enhanced exception classes for better error handling
class AuthenticationException implements Exception {
  final String message;
  final String code;
  final AuthErrorType errorType;
  
  AuthenticationException(this.message, this.code, this.errorType);
  
  @override
  String toString() => message;
}

/// Enhanced authentication result with detailed information
class AuthResult {
  final bool success;
  final String? error;
  final UserCredential? userCredential;
  final AuthErrorType? errorType;
  final int? attemptCount;
  final Duration? totalDuration;
  final Map<String, dynamic>? metadata;
  
  AuthResult._({
    required this.success,
    this.error,
    this.userCredential,
    this.errorType,
    this.attemptCount,
    this.totalDuration,
    this.metadata,
  });
  
  factory AuthResult.success(
    UserCredential? userCredential, {
    int? attemptCount,
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult._(
      success: true,
      userCredential: userCredential,
      attemptCount: attemptCount,
      totalDuration: totalDuration,
      metadata: metadata,
    );
  }
  
  factory AuthResult.failure(
    String error,
    AuthErrorType errorType, {
    int? attemptCount,
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
  }) {
    return AuthResult._(
      success: false,
      error: error,
      errorType: errorType,
      attemptCount: attemptCount,
      totalDuration: totalDuration,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'AuthResult{success: $success, error: $error, errorType: $errorType, attempts: $attemptCount}';
  }
}

/// Authentication status enumeration
enum AuthStatus {
  signedOut,
  signedIn,
  incompleteProfile,
}
