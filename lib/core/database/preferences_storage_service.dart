import 'package:shared_preferences/shared_preferences.dart';

/// Service that handles SharedPreferences operations exclusively.
/// 
/// This service is responsible for simple key-value storage operations
/// such as app settings, user preferences, and simple configuration values.
/// 
/// Follows Single Responsibility Principle by handling only SharedPreferences
/// operations without mixing with other storage backends.
abstract class PreferencesStorageService {
  /// Save a setting value
  Future<bool> saveSetting(String key, dynamic value);

  /// Get a setting value
  T? getSetting<T>(String key, {T? defaultValue});

  /// Remove a setting
  Future<bool> removeSetting(String key);

  /// Check if a key exists
  bool containsKey(String key);

  /// Get all keys
  Set<String> getKeys();

  /// Clear all settings
  Future<bool> clear();
}

/// Implementation of PreferencesStorageService using SharedPreferences
class PreferencesStorageServiceImpl implements PreferencesStorageService {
  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the SharedPreferences instance
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Ensure the service is initialized before use
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'PreferencesStorageService not initialized. Call init() first.',
      );
    }
  }

  @override
  Future<bool> saveSetting(String key, dynamic value) async {
    _ensureInitialized();
    
    if (value is String) {
      return _prefs.setString(key, value);
    } else if (value is int) {
      return _prefs.setInt(key, value);
    } else if (value is double) {
      return _prefs.setDouble(key, value);
    } else if (value is bool) {
      return _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return _prefs.setStringList(key, value);
    }
    throw ArgumentError('Unsupported type for SharedPreferences: ${value.runtimeType}');
  }

  @override
  T? getSetting<T>(String key, {T? defaultValue}) {
    _ensureInitialized();
    final value = _prefs.get(key);
    return value as T? ?? defaultValue;
  }

  @override
  Future<bool> removeSetting(String key) async {
    _ensureInitialized();
    return _prefs.remove(key);
  }

  @override
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs.containsKey(key);
  }

  @override
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs.getKeys();
  }

  @override
  Future<bool> clear() async {
    _ensureInitialized();
    return _prefs.clear();
  }
}
