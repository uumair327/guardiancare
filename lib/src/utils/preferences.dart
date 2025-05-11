import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyHasSeenForumGuidelines = 'has_seen_forum_guidelines';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLastLoginTime = 'last_login_time';

  // Singleton pattern
  static final Preferences _instance = Preferences._internal();
  factory Preferences() => _instance;
  Preferences._internal();

  late SharedPreferences _prefs;

  // Initialize preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Getters
  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  bool get hasSeenForumGuidelines => _prefs.getBool(_keyHasSeenForumGuidelines) ?? false;
  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;
  bool get areNotificationsEnabled => _prefs.getBool(_keyNotificationsEnabled) ?? true;
  String get language => _prefs.getString(_keyLanguage) ?? 'en';
  int? get lastLoginTime => _prefs.getInt(_keyLastLoginTime);

  // Setters
  Future<bool> setHasSeenOnboarding(bool value) => _prefs.setBool(_keyHasSeenOnboarding, value);
  Future<bool> setHasSeenForumGuidelines(bool value) => _prefs.setBool(_keyHasSeenForumGuidelines, value);
  Future<bool> setDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);
  Future<bool> setNotificationsEnabled(bool value) => _prefs.setBool(_keyNotificationsEnabled, value);
  Future<bool> setLanguage(String language) => _prefs.setString(_keyLanguage, language);
  Future<bool> setLastLoginTime(int timestamp) => _prefs.setInt(_keyLastLoginTime, timestamp);

  // Clear all preferences (for logout)
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Clear specific preference
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Check if a key exists
  bool containsKey(String key) => _prefs.containsKey(key);

  // Get all keys
  Set<String> getKeys() => _prefs.getKeys();

  // Custom preference getter with default value
  T? get<T>(String key, T defaultValue) {
    switch (T) {
      case String:
        return _prefs.getString(key) as T? ?? defaultValue;
      case int:
        return _prefs.getInt(key) as T? ?? defaultValue;
      case double:
        return _prefs.getDouble(key) as T? ?? defaultValue;
      case bool:
        return _prefs.getBool(key) as T? ?? defaultValue;
      case const (List<String>):
        return _prefs.getStringList(key) as T? ?? defaultValue;
      default:
        throw UnsupportedError('Type not supported: $T');
    }
  }

  // Custom preference setter
  Future<bool> set<T>(String key, T value) {
    switch (T) {
      case String:
        return _prefs.setString(key, value as String);
      case int:
        return _prefs.setInt(key, value as int);
      case double:
        return _prefs.setDouble(key, value as double);
      case bool:
        return _prefs.setBool(key, value as bool);
      case const (List<String>):
        return _prefs.setStringList(key, value as List<String>);
      default:
        throw UnsupportedError('Type not supported: $T');
    }
  }
}
