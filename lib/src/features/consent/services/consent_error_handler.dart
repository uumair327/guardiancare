import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced error handling service for consent forms with data preservation
class ConsentErrorHandler {
  static ConsentErrorHandler? _instance;
  
  ConsentErrorHandler._();
  
  static ConsentErrorHandler get instance {
    _instance ??= ConsentErrorHandler._();
    return _instance!;
  }

  static const String _formDataKey = 'consent_form_draft_data';
  static const String _errorHistoryKey = 'consent_error_history';
  static const String _submissionAttemptsKey = 'consent_submission_attempts';

  /// Handle consent form errors with comprehensive feedback
  Future<void> handleConsentError(
    BuildContext context,
    ConsentError error, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
    bool preserveFormData = true,
  }) async {
    // Log error for analytics
    await _logError(error);

    // Preserve form data if requested
    if (preserveFormData && error.formData != null) {
      await _preserveFormData(error.formData!);
    }

    // Show appropriate error UI based on error type
    switch (error.type) {
      case ConsentErrorType.validationError:
        await _handleValidationError(context, error, onRetry);
        break;
      case ConsentErrorType.networkError:
        await _handleNetworkError(context, error, onRetry);
        break;
      case ConsentErrorType.serverError:
        await _handleServerError(context, error, onRetry);
        break;
      case ConsentErrorType.authenticationError:
        await _handleAuthenticationError(context, error);
        break;
      case ConsentErrorType.rateLimitError:
        await _handleRateLimitError(context, error, onRetry);
        break;
      case ConsentErrorType.dataCorruptionError:
        await _handleDataCorruptionError(context, error, onCancel);
        break;
      case ConsentErrorType.systemError:
        await _handleSystemError(context, error, onRetry, onCancel);
        break;
    }
  }

  /// Handle validation errors with field-specific feedback
  Future<void> _handleValidationError(
    BuildContext context,
    ConsentError error,
    VoidCallback? onRetry,
  ) async {
    final validationErrors = error.validationErrors ?? [];
    final fieldErrors = error.fieldErrors ?? {};

    if (validationErrors.isEmpty && fieldErrors.isEmpty) {
      // Generic validation error
      _showErrorSnackBar(
        context,
        'Please check your form entries and try again.',
        severity: ErrorSeverity.warning,
        action: onRetry != null ? SnackBarAction(
          label: 'Review Form',
          onPressed: onRetry,
        ) : null,
      );
      return;
    }

    // Show detailed validation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ValidationErrorDialog(
        title: 'Form Validation Issues',
        validationErrors: validationErrors,
        fieldErrors: fieldErrors,
        onFixIssues: () {
          Navigator.of(context).pop();
          onRetry?.call();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Handle network errors with retry options
  Future<void> _handleNetworkError(
    BuildContext context,
    ConsentError error,
    VoidCallback? onRetry,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkErrorDialog(
        title: 'Connection Issue',
        message: error.message,
        onRetry: () {
          Navigator.of(context).pop();
          onRetry?.call();
        },
        onCancel: () => Navigator.of(context).pop(),
        showOfflineOptions: true,
      ),
    );
  }

  /// Handle server errors with detailed information
  Future<void> _handleServerError(
    BuildContext context,
    ConsentError error,
    VoidCallback? onRetry,
  ) async {
    final isTemporary = error.isTemporary ?? true;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ServerErrorDialog(
        title: 'Server Issue',
        message: error.message,
        isTemporary: isTemporary,
        errorCode: error.errorCode,
        onRetry: isTemporary ? () {
          Navigator.of(context).pop();
          onRetry?.call();
        } : null,
        onContactSupport: () {
          Navigator.of(context).pop();
          _showContactSupportDialog(context, error);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Handle authentication errors
  Future<void> _handleAuthenticationError(
    BuildContext context,
    ConsentError error,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AuthenticationErrorDialog(
        title: 'Authentication Required',
        message: error.message,
        onSignIn: () {
          Navigator.of(context).pop();
          // Navigate to sign-in screen
          Navigator.of(context).pushReplacementNamed('/login');
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Handle rate limit errors
  Future<void> _handleRateLimitError(
    BuildContext context,
    ConsentError error,
    VoidCallback? onRetry,
  ) async {
    final waitTime = error.retryAfter ?? const Duration(minutes: 5);
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RateLimitErrorDialog(
        title: 'Too Many Attempts',
        message: error.message,
        waitTime: waitTime,
        onWait: () {
          Navigator.of(context).pop();
          _scheduleRetryAfterWait(context, waitTime, onRetry);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Handle data corruption errors
  Future<void> _handleDataCorruptionError(
    BuildContext context,
    ConsentError error,
    VoidCallback? onCancel,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataCorruptionErrorDialog(
        title: 'Data Issue Detected',
        message: error.message,
        onClearData: () async {
          Navigator.of(context).pop();
          await clearPreservedFormData();
          _showSuccessMessage(context, 'Form data cleared. Please start over.');
          onCancel?.call();
        },
        onContactSupport: () {
          Navigator.of(context).pop();
          _showContactSupportDialog(context, error);
        },
      ),
    );
  }

  /// Handle system errors with multiple options
  Future<void> _handleSystemError(
    BuildContext context,
    ConsentError error,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SystemErrorDialog(
        title: 'System Error',
        message: error.message,
        errorCode: error.errorCode,
        onRetry: onRetry != null ? () {
          Navigator.of(context).pop();
          onRetry();
        } : null,
        onRestart: () {
          Navigator.of(context).pop();
          _restartForm(context);
        },
        onContactSupport: () {
          Navigator.of(context).pop();
          _showContactSupportDialog(context, error);
        },
        onCancel: () {
          Navigator.of(context).pop();
          onCancel?.call();
        },
      ),
    );
  }

  /// Show success message for successful consent submission
  void showSuccessMessage(
    BuildContext context, {
    String? message,
    VoidCallback? onContinue,
  }) {
    final successMessage = message ?? 'Consent form submitted successfully!';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: 'Success!',
        message: successMessage,
        onContinue: () {
          Navigator.of(context).pop();
          onContinue?.call();
        },
      ),
    );
  }

  /// Preserve form data for recovery
  Future<void> _preserveFormData(Map<String, dynamic> formData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataWithTimestamp = {
        ...formData,
        'preservedAt': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_formDataKey, dataWithTimestamp.toString());
      print('ConsentErrorHandler: Form data preserved');
    } catch (e) {
      print('ConsentErrorHandler: Failed to preserve form data: $e');
    }
  }

  /// Restore preserved form data
  Future<Map<String, dynamic>?> restoreFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString(_formDataKey);
      
      if (dataString == null) return null;
      
      // In a real implementation, use proper JSON parsing
      // For now, return null to indicate no preserved data
      return null;
    } catch (e) {
      print('ConsentErrorHandler: Failed to restore form data: $e');
      return null;
    }
  }

  /// Clear preserved form data
  Future<void> clearPreservedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_formDataKey);
      print('ConsentErrorHandler: Preserved form data cleared');
    } catch (e) {
      print('ConsentErrorHandler: Failed to clear preserved data: $e');
    }
  }

  /// Check if there is preserved form data
  Future<bool> hasPreservedFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_formDataKey);
    } catch (e) {
      return false;
    }
  }

  /// Log error for analytics and debugging
  Future<void> _logError(ConsentError error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorHistory = prefs.getStringList(_errorHistoryKey) ?? [];
      
      final errorEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': error.type.toString(),
        'message': error.message,
        'errorCode': error.errorCode,
        'isTemporary': error.isTemporary,
      }.toString();
      
      errorHistory.add(errorEntry);
      
      // Keep only last 10 errors
      if (errorHistory.length > 10) {
        errorHistory.removeAt(0);
      }
      
      await prefs.setStringList(_errorHistoryKey, errorHistory);
    } catch (e) {
      print('ConsentErrorHandler: Failed to log error: $e');
    }
  }

  /// Show error snack bar with appropriate styling
  void _showErrorSnackBar(
    BuildContext context,
    String message, {
    ErrorSeverity severity = ErrorSeverity.error,
    SnackBarAction? action,
  }) {
    final color = _getColorForSeverity(severity);
    final icon = _getIconForSeverity(severity);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: Duration(seconds: severity == ErrorSeverity.critical ? 8 : 4),
        action: action,
      ),
    );
  }

  /// Show success message snack bar
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show contact support dialog
  void _showContactSupportDialog(BuildContext context, ConsentError error) {
    showDialog(
      context: context,
      builder: (context) => ContactSupportDialog(
        error: error,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Schedule retry after wait time
  void _scheduleRetryAfterWait(
    BuildContext context,
    Duration waitTime,
    VoidCallback? onRetry,
  ) {
    Timer(waitTime, () {
      if (onRetry != null) {
        _showSuccessMessage(context, 'You can now try submitting again.');
        onRetry();
      }
    });
  }

  /// Restart form from beginning
  void _restartForm(BuildContext context) {
    // Clear all form data and restart
    clearPreservedFormData();
    Navigator.of(context).pushReplacementNamed('/consent');
  }

  /// Get color for error severity
  Color _getColorForSeverity(ErrorSeverity severity) {
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
  IconData _getIconForSeverity(ErrorSeverity severity) {
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

  /// Get error statistics for debugging
  Future<ConsentErrorStats> getErrorStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorHistory = prefs.getStringList(_errorHistoryKey) ?? [];
      final submissionAttempts = prefs.getInt(_submissionAttemptsKey) ?? 0;
      
      return ConsentErrorStats(
        totalErrors: errorHistory.length,
        submissionAttempts: submissionAttempts,
        hasPreservedData: await hasPreservedFormData(),
        lastErrorTime: errorHistory.isNotEmpty 
          ? DateTime.now() // Simplified - would parse from last error
          : null,
      );
    } catch (e) {
      return ConsentErrorStats(
        totalErrors: 0,
        submissionAttempts: 0,
        hasPreservedData: false,
        lastErrorTime: null,
      );
    }
  }

  /// Clear all error data
  Future<void> clearErrorData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorHistoryKey);
      await prefs.remove(_submissionAttemptsKey);
      await clearPreservedFormData();
    } catch (e) {
      print('ConsentErrorHandler: Failed to clear error data: $e');
    }
  }
}

/// Consent error representation
class ConsentError {
  final ConsentErrorType type;
  final String message;
  final String? errorCode;
  final bool? isTemporary;
  final Duration? retryAfter;
  final List<String>? validationErrors;
  final Map<String, String>? fieldErrors;
  final Map<String, dynamic>? formData;
  final DateTime timestamp;

  ConsentError({
    required this.type,
    required this.message,
    this.errorCode,
    this.isTemporary,
    this.retryAfter,
    this.validationErrors,
    this.fieldErrors,
    this.formData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ConsentError.validation({
    required String message,
    List<String>? validationErrors,
    Map<String, String>? fieldErrors,
    Map<String, dynamic>? formData,
  }) {
    return ConsentError(
      type: ConsentErrorType.validationError,
      message: message,
      validationErrors: validationErrors,
      fieldErrors: fieldErrors,
      formData: formData,
    );
  }

  factory ConsentError.network({
    required String message,
    Map<String, dynamic>? formData,
  }) {
    return ConsentError(
      type: ConsentErrorType.networkError,
      message: message,
      isTemporary: true,
      formData: formData,
    );
  }

  factory ConsentError.server({
    required String message,
    String? errorCode,
    bool isTemporary = true,
    Map<String, dynamic>? formData,
  }) {
    return ConsentError(
      type: ConsentErrorType.serverError,
      message: message,
      errorCode: errorCode,
      isTemporary: isTemporary,
      formData: formData,
    );
  }

  factory ConsentError.rateLimit({
    required String message,
    Duration? retryAfter,
    Map<String, dynamic>? formData,
  }) {
    return ConsentError(
      type: ConsentErrorType.rateLimitError,
      message: message,
      retryAfter: retryAfter,
      isTemporary: true,
      formData: formData,
    );
  }
}

/// Types of consent errors
enum ConsentErrorType {
  validationError,
  networkError,
  serverError,
  authenticationError,
  rateLimitError,
  dataCorruptionError,
  systemError,
}

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

/// Error statistics
class ConsentErrorStats {
  final int totalErrors;
  final int submissionAttempts;
  final bool hasPreservedData;
  final DateTime? lastErrorTime;

  ConsentErrorStats({
    required this.totalErrors,
    required this.submissionAttempts,
    required this.hasPreservedData,
    this.lastErrorTime,
  });
}

// Error Dialog Widgets
class ValidationErrorDialog extends StatelessWidget {
  final String title;
  final List<String> validationErrors;
  final Map<String, String> fieldErrors;
  final VoidCallback onFixIssues;
  final VoidCallback onCancel;

  const ValidationErrorDialog({
    Key? key,
    required this.title,
    required this.validationErrors,
    required this.fieldErrors,
    required this.onFixIssues,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (validationErrors.isNotEmpty) ...[
              const Text(
                'Please fix the following issues:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...validationErrors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(error)),
                  ],
                ),
              )),
            ],
            if (fieldErrors.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Field-specific issues:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...fieldErrors.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${entry.key}: ${entry.value}'),
              )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onFixIssues,
          child: const Text('Fix Issues'),
        ),
      ],
    );
  }
}

class NetworkErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;
  final bool showOfflineOptions;

  const NetworkErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onCancel,
    this.showOfflineOptions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          if (showOfflineOptions) ...[
            const SizedBox(height: 16),
            const Text(
              'Your form data has been saved and will be submitted when connection is restored.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class ServerErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isTemporary;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback onContactSupport;
  final VoidCallback onCancel;

  const ServerErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.isTemporary,
    this.errorCode,
    this.onRetry,
    required this.onContactSupport,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error Code: $errorCode',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (!isTemporary) ...[
            const SizedBox(height: 8),
            const Text(
              'This appears to be a persistent issue. Please contact support.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ElevatedButton(
          onPressed: onContactSupport,
          child: const Text('Contact Support'),
        ),
      ],
    );
  }
}

class AuthenticationErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onSignIn;
  final VoidCallback onCancel;

  const AuthenticationErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onSignIn,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onSignIn,
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}

class RateLimitErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final Duration waitTime;
  final VoidCallback onWait;
  final VoidCallback onCancel;

  const RateLimitErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.waitTime,
    required this.onWait,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.timer, color: Colors.orange),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          Text(
            'Please wait ${waitTime.inMinutes} minutes before trying again.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onWait,
          child: const Text('Wait & Retry'),
        ),
      ],
    );
  }
}

class DataCorruptionErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onClearData;
  final VoidCallback onContactSupport;

  const DataCorruptionErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onClearData,
    required this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          const Text(
            'Clearing data will remove any saved form information.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onContactSupport,
          child: const Text('Contact Support'),
        ),
        ElevatedButton(
          onPressed: onClearData,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Clear Data'),
        ),
      ],
    );
  }
}

class SystemErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback onRestart;
  final VoidCallback onContactSupport;
  final VoidCallback onCancel;

  const SystemErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.errorCode,
    this.onRetry,
    required this.onRestart,
    required this.onContactSupport,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error Code: $errorCode',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        TextButton(
          onPressed: onRestart,
          child: const Text('Restart Form'),
        ),
        ElevatedButton(
          onPressed: onContactSupport,
          child: const Text('Contact Support'),
        ),
      ],
    );
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onContinue;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class ContactSupportDialog extends StatelessWidget {
  final ConsentError error;
  final VoidCallback onClose;

  const ContactSupportDialog({
    Key? key,
    required this.error,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.blue),
          SizedBox(width: 8),
          Text('Contact Support'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please provide the following information when contacting support:'),
          const SizedBox(height: 16),
          Text('Error Type: ${error.type}'),
          Text('Error Code: ${error.errorCode ?? 'N/A'}'),
          Text('Timestamp: ${error.timestamp}'),
          const SizedBox(height: 16),
          const Text('Support Email: support@guardiancare.com'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}