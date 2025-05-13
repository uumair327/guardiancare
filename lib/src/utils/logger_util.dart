import 'package:logger/logger.dart';
import 'dart:convert';

/// A utility class for logging messages throughout the app.
/// Provides different logging levels and formatting options.
class AppLogger {
  /// Singleton instance
  static final AppLogger _instance = AppLogger._internal();
  
  /// Logger instance
  late final Logger _logger;
  
  /// Whether to enable logging (can be toggled based on build type)
  bool _enabled = true;
  
  /// Private constructor
  AppLogger._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be shown
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        printTime: true, // Include time in the log
      ),
    );
  }
  
  /// Factory constructor to return the same instance
  factory AppLogger() => _instance;
  
  /// Enable or disable logging
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }
  
  /// Log a message at level [Level.verbose].
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.v(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log a message at level [Level.debug].
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log a message at level [Level.info].
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log a message at level [Level.warning].
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log a message at level [Level.error].
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log a message at level [Level.wtf].
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_enabled) {
      _logger.wtf(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log a JSON response in a pretty format
  void json(String jsonString, {String? title}) {
    if (!_enabled) return;
    
    try {
      // Pretty print JSON
      final dynamic json = _tryParseJson(jsonString);
      final prettyString = _formatJson(json);
      
      if (title != null) {
        _logger.i('$title:');
      }
      _logger.i(prettyString);
    } catch (e) {
      _logger.e('Failed to parse JSON: $e');
      _logger.d(jsonString);
    }
  }
  
  // Try to parse JSON string into a dynamic object
  dynamic _tryParseJson(String jsonString) {
    try {
      // Check if it's already a parsed JSON object
      if (jsonString is Map || jsonString is List) {
        return jsonString;
      }
      
      // Try to parse as JSON
      return jsonDecode(jsonString);
    } catch (e) {
      return jsonString;
    }
  }
  
  // Format JSON with proper indentation
  String _formatJson(dynamic json) {
    if (json is String) {
      try {
        // If it's a string that can be parsed as JSON, pretty print it
        final parsed = jsonDecode(json);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(parsed);
      } catch (e) {
        // If it's just a regular string, return as is
        return json;
      }
    } else {
      // If it's already a parsed JSON object, pretty print it
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    }
  }
}

// Global logger instance
final logger = AppLogger();

// Extension to add logging to Object
extension ObjectLogger on Object {
  /// Log this object as verbose
  void logV([String? message]) {
    logger.v(message ?? toString());
  }
  
  /// Log this object as debug
  void logD([String? message]) {
    logger.d(message ?? toString());
  }
  
  /// Log this object as info
  void logI([String? message]) {
    logger.i(message ?? toString());
  }
  
  /// Log this object as warning
  void logW([String? message]) {
    logger.w(message ?? toString());
  }
  
  /// Log this object as error
  void logE([String? message, dynamic error, StackTrace? stackTrace]) {
    logger.e(message ?? toString(), error, stackTrace);
  }
  
  /// Log this object as WTF (What a Terrible Failure)
  void logWtf([String? message]) {
    logger.wtf(message ?? toString());
  }
}
