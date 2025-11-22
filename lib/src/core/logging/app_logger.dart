import 'package:flutter/foundation.dart';

/// Centralized logging utility for the application
class AppLogger {
  static const String _prefix = '[GuardianCare]';

  /// Log levels
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarning = 2;
  static const int _levelError = 3;

  /// Current log level (can be configured)
  static int _currentLevel = kDebugMode ? _levelDebug : _levelInfo;

  /// Set the minimum log level
  static void setLogLevel(int level) {
    _currentLevel = level;
  }

  /// Log debug message (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (_currentLevel <= _levelDebug) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr [DEBUG] $message');
    }
  }

  /// Log info message
  static void info(String message, {String? tag}) {
    if (_currentLevel <= _levelInfo) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr [INFO] $message');
    }
  }

  /// Log warning message
  static void warning(String message, {String? tag}) {
    if (_currentLevel <= _levelWarning) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr [WARNING] $message');
    }
  }

  /// Log error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_currentLevel <= _levelError) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_prefix$tagStr [ERROR] $message');
      if (error != null) {
        debugPrint('$_prefix$tagStr [ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('$_prefix$tagStr [ERROR] StackTrace: $stackTrace');
      }
    }
  }

  /// Log feature-specific messages
  static void feature(String featureName, String message, {String? level}) {
    final levelStr = level ?? 'INFO';
    debugPrint('$_prefix[$featureName] [$levelStr] $message');
  }

  /// Log network requests
  static void network(String method, String url, {int? statusCode, String? error}) {
    if (statusCode != null) {
      debugPrint('$_prefix[NETWORK] $method $url - Status: $statusCode');
    } else if (error != null) {
      debugPrint('$_prefix[NETWORK] $method $url - Error: $error');
    } else {
      debugPrint('$_prefix[NETWORK] $method $url');
    }
  }

  /// Log authentication events
  static void auth(String event, {String? userId, String? error}) {
    if (error != null) {
      debugPrint('$_prefix[AUTH] $event - Error: $error');
    } else if (userId != null) {
      debugPrint('$_prefix[AUTH] $event - User: $userId');
    } else {
      debugPrint('$_prefix[AUTH] $event');
    }
  }

  /// Log state changes
  static void state(String stateName, String change) {
    debugPrint('$_prefix[STATE] $stateName: $change');
  }

  /// Log BLoC events
  static void bloc(String blocName, String event, {String? state}) {
    if (state != null) {
      debugPrint('$_prefix[BLOC][$blocName] Event: $event → State: $state');
    } else {
      debugPrint('$_prefix[BLOC][$blocName] Event: $event');
    }
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    debugPrint('$_prefix[NAV] $from → $to');
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    debugPrint('$_prefix[PERF] $operation took ${duration.inMilliseconds}ms');
  }
}

/// Extension for easy logging from any class
extension LoggerExtension on Object {
  void logDebug(String message) {
    AppLogger.debug(message, tag: runtimeType.toString());
  }

  void logInfo(String message) {
    AppLogger.info(message, tag: runtimeType.toString());
  }

  void logWarning(String message) {
    AppLogger.warning(message, tag: runtimeType.toString());
  }

  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(message, tag: runtimeType.toString(), error: error, stackTrace: stackTrace);
  }
}
