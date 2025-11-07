import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handler for consistent error management throughout the app
class AppErrorHandler {
  static AppErrorHandler? _instance;
  
  AppErrorHandler._();
  
  static AppErrorHandler get instance {
    _instance ??= AppErrorHandler._();
    return _instance!;
  }

  // Error listeners for different error types
  final List<Function(AppError)> _errorListeners = [];
  final List<AppError> _errorHistory = [];
  static const int _maxErrorHistory = 100;

  /// Add an error listener
  void addErrorListener(Function(AppError) listener) {
    _errorListeners.add(listener);
  }

  /// Remove an error listener
  void removeErrorListener(Function(AppError) listener) {
    _errorListeners.remove(listener);
  }

  /// Handle an error with appropriate categorization and logging
  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    bool showToUser = true,
    Map<String, dynamic>? metadata,
  }) async {
    final appError = _categorizeError(
      error,
      stackTrace: stackTrace,
      context: context,
      severity: severity,
      metadata: metadata,
    );

    // Log the error
    await _logError(appError);

    // Add to history
    _addToHistory(appError);

    // Notify listeners
    _notifyListeners(appError);

    // Show to user if requested
    if (showToUser) {
      _showErrorToUser(appError);
    }
  }

  /// Categorize error into AppError
  AppError _categorizeError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity? severity,
    Map<String, dynamic>? metadata,
  }) {
    final timestamp = DateTime.now();
    
    // Determine error type and message
    ErrorType errorType;
    String message;
    String? technicalDetails;

    if (error is AppError) {
      return error;
    } else if (error is NetworkException) {
      errorType = ErrorType.network;
      message = error.message;
      technicalDetails = error.details;
    } else if (error is ValidationException) {
      errorType = ErrorType.validation;
      message = error.message;
      technicalDetails = error.fieldErrors.toString();
    } else if (error is AuthenticationException) {
      errorType = ErrorType.authentication;
      message = error.message;
      technicalDetails = error.code;
    } else if (error is PermissionException) {
      errorType = ErrorType.permission;
      message = error.message;
    } else if (error is TimeoutException) {
      errorType = ErrorType.timeout;
      message = 'Operation timed out. Please try again.';
      technicalDetails = error.message;
    } else if (error is FormatException) {
      errorType = ErrorType.dataFormat;
      message = 'Invalid data format received.';
      technicalDetails = error.message;
    } else {
      errorType = ErrorType.unknown;
      message = 'An unexpected error occurred.';
      technicalDetails = error.toString();
    }

    return AppError(
      type: errorType,
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      timestamp: timestamp,
      context: context,
      severity: severity ?? _determineSeverity(errorType),
      metadata: metadata,
    );
  }

  /// Determine severity based on error type
  ErrorSeverity _determineSeverity(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
      case ErrorType.timeout:
        return ErrorSeverity.warning;
      case ErrorType.validation:
        return ErrorSeverity.info;
      case ErrorType.authentication:
      case ErrorType.permission:
        return ErrorSeverity.error;
      case ErrorType.dataFormat:
      case ErrorType.storage:
      case ErrorType.unknown:
        return ErrorSeverity.critical;
    }
  }

  /// Log error to console and external services
  Future<void> _logError(AppError error) async {
    // Console logging
    if (kDebugMode) {
      print('═══════════════════════════════════════════════════════');
      print('🔴 ERROR [${error.severity.name.toUpperCase()}]');
      print('Type: ${error.type.name}');
      print('Message: ${error.message}');
      if (error.context != null) print('Context: ${error.context}');
      if (error.technicalDetails != null) {
        print('Technical Details: ${error.technicalDetails}');
      }
      print('Timestamp: ${error.timestamp}');
      if (error.stackTrace != null) {
        print('Stack Trace:\n${error.stackTrace}');
      }
      if (error.metadata != null) {
        print('Metadata: ${error.metadata}');
      }
      print('═══════════════════════════════════════════════════════');
    }

    // In production, send to error tracking service (e.g., Sentry, Firebase Crashlytics)
    // await _sendToErrorTrackingService(error);
  }

  /// Add error to history
  void _addToHistory(AppError error) {
    _errorHistory.add(error);
    
    // Keep history size manageable
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
  }

  /// Notify all error listeners
  void _notifyListeners(AppError error) {
    for (final listener in _errorListeners) {
      try {
        listener(error);
      } catch (e) {
        if (kDebugMode) {
          print('Error in error listener: $e');
        }
      }
    }
  }

  /// Show error to user (this would typically show a snackbar or dialog)
  void _showErrorToUser(AppError error) {
    // This will be called from UI layer with BuildContext
    // For now, just log that we should show it
    if (kDebugMode) {
      print('📱 Should show to user: ${error.userFriendlyMessage}');
    }
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(AppError error) {
    return error.userFriendlyMessage;
  }

  /// Get error history
  List<AppError> getErrorHistory({
    ErrorType? filterByType,
    ErrorSeverity? filterBySeverity,
    int? limit,
  }) {
    var filtered = _errorHistory.toList();

    if (filterByType != null) {
      filtered = filtered.where((e) => e.type == filterByType).toList();
    }

    if (filterBySeverity != null) {
      filtered = filtered.where((e) => e.severity == filterBySeverity).toList();
    }

    if (limit != null && filtered.length > limit) {
      filtered = filtered.sublist(filtered.length - limit);
    }

    return filtered;
  }

  /// Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get error statistics
  ErrorStatistics getErrorStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastHour = now.subtract(const Duration(hours: 1));

    final recentErrors = _errorHistory.where((e) => e.timestamp.isAfter(last24Hours)).toList();
    final lastHourErrors = _errorHistory.where((e) => e.timestamp.isAfter(lastHour)).toList();

    final errorsByType = <ErrorType, int>{};
    final errorsBySeverity = <ErrorSeverity, int>{};

    for (final error in recentErrors) {
      errorsByType[error.type] = (errorsByType[error.type] ?? 0) + 1;
      errorsBySeverity[error.severity] = (errorsBySeverity[error.severity] ?? 0) + 1;
    }

    return ErrorStatistics(
      totalErrors: _errorHistory.length,
      errorsLast24Hours: recentErrors.length,
      errorsLastHour: lastHourErrors.length,
      errorsByType: errorsByType,
      errorsBySeverity: errorsBySeverity,
      mostCommonErrorType: _getMostCommon(errorsByType),
      mostCommonSeverity: _getMostCommon(errorsBySeverity),
    );
  }

  /// Get most common item from map
  T? _getMostCommon<T>(Map<T, int> map) {
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if error is retryable
  bool isRetryable(AppError error) {
    switch (error.type) {
      case ErrorType.network:
      case ErrorType.timeout:
        return true;
      case ErrorType.authentication:
      case ErrorType.permission:
      case ErrorType.validation:
      case ErrorType.dataFormat:
      case ErrorType.storage:
      case ErrorType.unknown:
        return false;
    }
  }

  /// Get retry suggestion for error
  String? getRetrySuggestion(AppError error) {
    if (!isRetryable(error)) return null;

    switch (error.type) {
      case ErrorType.network:
        return 'Check your internet connection and try again.';
      case ErrorType.timeout:
        return 'The operation took too long. Please try again.';
      default:
        return 'Please try again.';
    }
  }
}

/// Represents an application error with full context
class AppError {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final String? context;
  final ErrorSeverity severity;
  final Map<String, dynamic>? metadata;

  AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.stackTrace,
    required this.timestamp,
    this.context,
    required this.severity,
    this.metadata,
  });

  /// Get user-friendly message
  String get userFriendlyMessage {
    switch (type) {
      case ErrorType.network:
        return 'Unable to connect. Please check your internet connection.';
      case ErrorType.timeout:
        return 'The request took too long. Please try again.';
      case ErrorType.authentication:
        return 'Authentication failed. Please sign in again.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.validation:
        return message; // Validation messages are already user-friendly
      case ErrorType.dataFormat:
        return 'Received invalid data. Please try again.';
      case ErrorType.storage:
        return 'Unable to save data. Please check storage permissions.';
      case ErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  String toString() {
    return 'AppError{type: $type, severity: $severity, message: $message, context: $context}';
  }
}

/// Types of errors in the application
enum ErrorType {
  network,
  timeout,
  authentication,
  permission,
  validation,
  dataFormat,
  storage,
  unknown,
}

/// Severity levels for errors
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

/// Custom exception types
class NetworkException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  NetworkException(this.message, {this.details, this.statusCode});

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;

  ValidationException(this.message, {this.fieldErrors = const {}});

  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  final String code;

  AuthenticationException(this.message, this.code);

  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;
  final String? requiredPermission;

  PermissionException(this.message, {this.requiredPermission});

  @override
  String toString() => message;
}

/// Error statistics
class ErrorStatistics {
  final int totalErrors;
  final int errorsLast24Hours;
  final int errorsLastHour;
  final Map<ErrorType, int> errorsByType;
  final Map<ErrorSeverity, int> errorsBySeverity;
  final ErrorType? mostCommonErrorType;
  final ErrorSeverity? mostCommonSeverity;

  ErrorStatistics({
    required this.totalErrors,
    required this.errorsLast24Hours,
    required this.errorsLastHour,
    required this.errorsByType,
    required this.errorsBySeverity,
    this.mostCommonErrorType,
    this.mostCommonSeverity,
  });

  @override
  String toString() {
    return 'ErrorStatistics{total: $totalErrors, last24h: $errorsLast24Hours, lastHour: $errorsLastHour}';
  }
}

/// Helper widget to show errors to users
class ErrorDisplay extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRetryable = AppErrorHandler.instance.isRetryable(error);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getSeverityColor(error.severity).withOpacity(0.1),
        border: Border.all(color: _getSeverityColor(error.severity)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSeverityIcon(error.severity),
                color: _getSeverityColor(error.severity),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error.userFriendlyMessage,
                  style: TextStyle(
                    color: _getSeverityColor(error.severity),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (isRetryable && onRetry != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ] else if (onDismiss != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDismiss,
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
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

  IconData _getSeverityIcon(ErrorSeverity severity) {
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
}
