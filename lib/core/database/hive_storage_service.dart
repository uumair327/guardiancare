import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Service that handles Hive operations exclusively.
/// 
/// This service is responsible for fast key-value storage operations
/// such as user sessions, settings, temporary data, and frequently accessed data.
/// 
/// Follows Single Responsibility Principle by handling only Hive
/// operations without mixing with other storage backends.
abstract class HiveStorageService {
  /// Box names constants
  static const String userSessionBox = 'user_session';
  static const String userSettingsBox = 'user_settings';
  static const String cacheBox = 'cache';
  static const String secureBox = 'secure';
  static const String reportsBox = 'reports';

  /// Initialize Hive
  Future<void> init();

  /// Save data to a box
  Future<void> put(String boxName, String key, dynamic value);

  /// Get data from a box
  T? get<T>(String boxName, String key, {T? defaultValue});

  /// Delete data from a box
  Future<void> delete(String boxName, String key);

  /// Clear a box
  Future<void> clearBox(String boxName);

  /// Clear all boxes (for logout)
  Future<void> clearAll();

  /// Check if key exists
  bool containsKey(String boxName, String key);

  /// Get all keys in a box
  Iterable<dynamic> getKeys(String boxName);

  /// Get all values in a box
  Iterable<dynamic> getValues(String boxName);

  /// Close all boxes
  Future<void> close();

  /// Compact a box (optimize storage)
  Future<void> compact(String boxName);

  /// Watch for changes in a box
  Stream<BoxEvent> watch(String boxName, {String? key});
}

/// Implementation of HiveStorageService using Hive
class HiveStorageServiceImpl implements HiveStorageService {
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;

    if (kIsWeb) {
      // On web, Hive uses IndexedDB - no path needed
      await Hive.initFlutter();
    } else {
      // On mobile/desktop, use app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocDir.path);
    }

    // Open boxes
    await _openBoxes();
    _initialized = true;
  }

  /// Open all required boxes
  Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox(HiveStorageService.userSessionBox),
      Hive.openBox(HiveStorageService.userSettingsBox),
      Hive.openBox(HiveStorageService.cacheBox),
      Hive.openBox(HiveStorageService.secureBox),
      Hive.openBox(HiveStorageService.reportsBox),
    ]);
  }

  /// Get a box by name
  Box _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError('Box $boxName is not open. Call init() first.');
    }
    return Hive.box(boxName);
  }

  @override
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = _getBox(boxName);
    await box.put(key, value);
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    final box = _getBox(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    final box = _getBox(boxName);
    await box.clear();
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      clearBox(HiveStorageService.userSessionBox),
      clearBox(HiveStorageService.userSettingsBox),
      clearBox(HiveStorageService.cacheBox),
      // Don't clear secure box automatically
    ]);
  }

  @override
  bool containsKey(String boxName, String key) {
    final box = _getBox(boxName);
    return box.containsKey(key);
  }

  @override
  Iterable<dynamic> getKeys(String boxName) {
    final box = _getBox(boxName);
    return box.keys;
  }

  @override
  Iterable<dynamic> getValues(String boxName) {
    final box = _getBox(boxName);
    return box.values;
  }

  @override
  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }

  @override
  Future<void> compact(String boxName) async {
    final box = _getBox(boxName);
    await box.compact();
  }

  @override
  Stream<BoxEvent> watch(String boxName, {String? key}) {
    final box = _getBox(boxName);
    return box.watch(key: key);
  }
}
