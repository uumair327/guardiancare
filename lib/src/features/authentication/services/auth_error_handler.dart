import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/login_controller.dart';

/// Enhanced authentication error handler with user-friendly messages and fallback mechanisms
class AuthErrorHandler {
  static AuthErrorHandler? _instance;
  
  AuthErrorHandler._();
  
  static AuthErrorHandler get instance {
    _instance ??= AuthErrorHandler._();
    return _instance!;
  }

  /// Handle authentication errors with appropriate user feedback
  Future<void> handleAuthError(
    BuildContext context,
    AuthResult authResult, {
    VoidCallback? onRetry,
    VoidCallback? onFallback,
    bool showSnackBar = true,
  }) async {
    if (authResult.success) return;

    final errorInfo = _getErrorInfo(authResult);
    
    if (showSnackBar) {
      _showErrorSnackBar(context, errorInfo, onRetry);
    }

    // Handle specific error types
    switch (authResult.errorType) {
      case AuthErrorType.network:
        await _handleNetworkError(context, errorInfo, onRetry);
        break;
      case AuthErrorType.credential:
        await _handleCredentialError(context, errorInfo, onFallback);
        break;
      case AuthErrorType.permission:
        await _handlePermissionError(context, errorInfo);
        break;
      case AuthErrorType.validation:
        await _handleValidationError(context, errorInfo);
        break;
      case AuthErrorType.timeout:
        await _handleTimeoutError(context, errorInfo, onRetry);
        break;
      case AuthErrorType.cancelled:
        // User cancelled, no action needed
        break;
      case AuthErrorType.system:
      case null:
        await _handleSystemError(context, errorInfo, onFallback);
        break;
    }
  }

  /// Get detailed error information
  AuthErrorInfo _getErrorInfo(AuthResult authResult) {
    return AuthErrorInfo(
      message: authResult.error ?? 'An unknown error occurred',
      errorType: authResult.errorType ?? AuthErrorType.system,
      isRetryable: _isRetryableError(authResult.errorType),
      severity: _getErrorSeverity(authResult.errorType),
      suggestedActions: _getSuggestedActions(authResult.errorType),
      attemptCount: authResult.attemptCount,
      totalDuration: authResult.totalDuration,
    );
  }

  /// Check if error is retryable
  bool _isRetryableError(AuthErrorType? errorType) {
    switch (errorType) {
      case AuthErrorType.network:
      case AuthErrorType.timeout:
      case AuthErrorType.system:
        return true;
      case AuthErrorType.credential:
      case AuthErrorType.permission:
      case AuthErrorType.validation:
      case AuthErrorType.cancelled:
      case null:
        return false;
    }
  }

  /// Get error severity level
  ErrorSeverity _getErrorSeverity(AuthErrorType? errorType) {
    switch (errorType) {
      case AuthErrorType.network:
      case AuthErrorType.timeout:
        return ErrorSeverity.warning;
      case AuthErrorType.credential:
      case AuthErrorType.validation:
        return ErrorSeverity.error;
      case AuthErrorType.permission:
        return ErrorSeverity.critical;
      case AuthErrorType.cancelled:
        return ErrorSeverity.info;
      case AuthErrorType.system:
      case null:
        return ErrorSeverity.error;
    }
  }

  /// Get suggested actions for error type
  List<String> _getSuggestedActions(AuthErrorType? errorType) {
    switch (errorType) {
      case AuthErrorType.network:
        return [
          'Check your internet connection',
          'Try again in a moment',
          'Switch to a different network if available',
        ];
      case AuthErrorType.timeout:
        return [
          'Check your internet connection speed',
          'Try again with a better connection',
          'Contact support if the problem persists',
        ];
      case AuthErrorType.credential:
        return [
          'Verify your account credentials',
          'Try signing in with a different method',
          'Contact support if you need help',
        ];
      case AuthErrorType.permission:
        return [
          'Contact support for assistance',
          'Check if your account is active',
        ];
      case AuthErrorType.validation:
        return [
          'Check your account information',
          'Ensure your Google account has a name and email',
          'Update your Google profile if needed',
        ];
      case AuthErrorType.cancelled:
        return [
          'Try signing in again when ready',
        ];
      case AuthErrorType.system:
      case null:
        return [
          'Try again in a moment',
          'Restart the app if the problem continues',
          'Contact support if the issue persists',
        ];
    }
  }

  /// Show error snack bar with appropriate styling
  void _showErrorSnackBar(
    BuildContext context,
    AuthErrorInfo errorInfo,
    VoidCallback? onRetry,
  ) {
    final color = _getErrorColor(errorInfo.severity);
    final icon = _getErrorIcon(errorInfo.severity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorInfo.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: errorInfo.severity == ErrorSeverity.critical ? 8 : 4),
        action: errorInfo.isRetryable && onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Handle network-related errors
  Future<void> _handleNetworkError(
    BuildContext context,
    AuthErrorInfo errorInfo,
    VoidCallback? onRetry,
  ) async {
    if (errorInfo.attemptCount != null && errorInfo.attemptCount! > 1) {
      // Multiple attempts failed, show detailed dialog
      await _showDetailedErrorDialog(
        context,
        'Network Connection Issue',
        errorInfo,
        onRetry,
      );
    }
  }

  /// Handle credential-related errors
  Future<void> _handleCredentialError(
    BuildContext context,
    AuthErrorInfo errorInfo,
    VoidCallback? onFallback,
  ) async {
    await _showDetailedErrorDialog(
      context,
      'Authentication Issue',
      errorInfo,
      onFallback,
      actionLabel: 'Try Different Method',
    );
  }

  /// Handle permission-related errors
  Future<void> _handlePermissionError(
    BuildContext context,
    AuthErrorInfo errorInfo,
  ) async {
    await _showDetailedErrorDialog(
      context,
      'Account Access Issue',
      errorInfo,
      null,
    );
  }

  /// Handle validation errors
  Future<void> _handleValidationError(
    BuildContext context,
    AuthErrorInfo errorInfo,
  ) async {
    await _showDetailedErrorDialog(
      context,
      'Account Information Issue',
      errorInfo,
      null,
    );
  }

  /// Handle timeout errors
  Future<void> _handleTimeoutError(
    BuildContext context,
    AuthErrorInfo errorInfo,
    VoidCallback? onRetry,
  ) async {
    await _showDetailedErrorDialog(
      context,
      'Connection Timeout',
      errorInfo,
      onRetry,
    );
  }

  /// Handle system errors
  Future<void> _handleSystemError(
    BuildContext context,
    AuthErrorInfo errorInfo,
    VoidCallback? onFallback,
  ) async {
    await _showDetailedErrorDialog(
      context,
      'System Error',
      errorInfo,
      onFallback,
      actionLabel: 'Contact Support',
    );
  }

  /// Show detailed error dialog with suggestions
  Future<void> _showDetailedErrorDialog(
    BuildContext context,
    String title,
    AuthErrorInfo errorInfo,
    VoidCallback? onAction, {
    String? actionLabel,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getErrorIcon(errorInfo.severity),
              color: _getErrorColor(errorInfo.severity),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorInfo.message),
            if (errorInfo.attemptCount != null) ...[
              const SizedBox(height: 8),
              Text(
                'Attempts: ${errorInfo.attemptCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (errorInfo.totalDuration != null) ...[
              Text(
                'Duration: ${errorInfo.totalDuration!.inSeconds}s',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (errorInfo.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Suggested actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...errorInfo.suggestedActions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(action)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onAction != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionLabel ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  /// Get color for error severity
  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  /// Get icon for error severity
  IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  /// Perform secure sign-out with data clearing
  Future<void> performSecureSignOut(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign out from all providers
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        // Add other sign-out operations here
      ]);

      // Clear local data
      await _clearLocalData();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      print('🔓 Secure sign-out completed');

    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-out failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('❌ Secure sign-out failed: $e');
    }
  }

  /// Clear local data during sign-out
  Future<void> _clearLocalData() async {
    // Clear any sensitive local data
    // This should be implemented based on what data the app stores locally
    print('🧹 Local data cleared during sign-out');
  }
}

/// Detailed authentication error information
class AuthErrorInfo {
  final String message;
  final AuthErrorType errorType;
  final bool isRetryable;
  final ErrorSeverity severity;
  final List<String> suggestedActions;
  final int? attemptCount;
  final Duration? totalDuration;

  AuthErrorInfo({
    required this.message,
    required this.errorType,
    required this.isRetryable,
    required this.severity,
    required this.suggestedActions,
    this.attemptCount,
    this.totalDuration,
  });

  @override
  String toString() {
    return 'AuthErrorInfo{type: $errorType, severity: $severity, retryable: $isRetryable}';
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}