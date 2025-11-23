import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Industrial-grade Hive service for fast key-value storage
/// Best for: User sessions, settings, temporary data, and frequently accessed data
class HiveService {
  static final HiveService instance = HiveService._internal();
  
  HiveService._internal();

  /// Box names
  static const String userSessionBox = 'user_session';
  static const String userSettingsBox = 'user_settings';
  static const String cacheBox = 'cache';
  static const String secureBox = 'secure';
  static const String reportsBox = 'reports';

  /// Initialize Hive
  Future<void> init() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
    
    // Open boxes
    await _openBoxes();
  }

  /// Open all required boxes
  Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox(userSessionBox),
      Hive.openBox(userSettingsBox),
      Hive.openBox(cacheBox),
      Hive.openBox(secureBox),
      Hive.openBox(reportsBox),
    ]);
  }

  /// Get a box by name
  Box getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open');
    }
    return Hive.box(boxName);
  }

  /// Save data to a box
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = getBox(boxName);
    await box.put(key, value);
  }

  /// Get data from a box
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    final box = getBox(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Delete data from a box
  Future<void> delete(String boxName, String key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  /// Clear a box
  Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  /// Clear all boxes (for logout)
  Future<void> clearAll() async {
    await Future.wait([
      clearBox(userSessionBox),
      clearBox(userSettingsBox),
      clearBox(cacheBox),
      // Don't clear secure box automatically
    ]);
  }

  /// Check if key exists
  bool containsKey(String boxName, String key) {
    final box = getBox(boxName);
    return box.containsKey(key);
  }

  /// Get all keys in a box
  Iterable<dynamic> getKeys(String boxName) {
    final box = getBox(boxName);
    return box.keys;
  }

  /// Get all values in a box
  Iterable<dynamic> getValues(String boxName) {
    final box = getBox(boxName);
    return box.values;
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  /// Compact a box (optimize storage)
  Future<void> compact(String boxName) async {
    final box = getBox(boxName);
    await box.compact();
  }

  /// Watch for changes in a box
  Stream<BoxEvent> watch(String boxName, {String? key}) {
    final box = getBox(boxName);
    return box.watch(key: key);
  }
}
