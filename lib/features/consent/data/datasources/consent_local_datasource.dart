import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for consent-related local storage operations
/// Requirements: 5.2 - Handle parental key persistence locally
abstract class ConsentLocalDataSource {
  /// Save parental key to local storage
  Future<void> saveParentalKey(String key);

  /// Get parental key from local storage
  Future<String?> getParentalKey();

  /// Check if parental key exists locally
  Future<bool> hasParentalKey();

  /// Clear parental key from local storage
  Future<void> clearParentalKey();
}

class ConsentLocalDataSourceImpl implements ConsentLocalDataSource {

  ConsentLocalDataSourceImpl({required this.sharedPreferences});
  static const String _parentalKeyKey = 'parental_key';

  final SharedPreferences sharedPreferences;

  @override
  Future<void> saveParentalKey(String key) async {
    await sharedPreferences.setString(_parentalKeyKey, key);
  }

  @override
  Future<String?> getParentalKey() async {
    return sharedPreferences.getString(_parentalKeyKey);
  }

  @override
  Future<bool> hasParentalKey() async {
    return sharedPreferences.containsKey(_parentalKeyKey);
  }

  @override
  Future<void> clearParentalKey() async {
    await sharedPreferences.remove(_parentalKeyKey);
  }
}
