import 'package:flutter/foundation.dart';

/// Secure logger for the application.
///
/// This class handles logging in a secure way, ensuring that:
/// 1. Logs are only printed in debug mode.
/// 2. Sensitive information can be redacted (future enhancement).
/// 3. Provides a unified interface for logging.
class Log {
  Log._();

  /// Log a debug message
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    }
  }

  /// Log an info message
  static void i(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  /// Log a warning message
  static void w(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('[WARN] $message');
      if (error != null) debugPrint('Error: $error');
    }
  }

  /// Log an error message
  ///
  /// Errors are logged even in release mode to Crashlytics (handled by global error handler usually),
  /// but we avoid printing to console in release.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    }
    // In a real app, you might want to send this to Crashlytics here explicitly if needed.
  }
}
