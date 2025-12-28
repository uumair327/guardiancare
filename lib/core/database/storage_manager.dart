import 'package:flutter/foundation.dart' show debugPrint;
import 'package:guardiancare/core/database/preferences_storage_service.dart';
import 'package:guardiancare/core/database/hive_storage_service.dart';
import 'package:guardiancare/core/database/sqlite_storage_service.dart';
import 'package:guardiancare/core/database/daos/daos.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Unified Storage Manager
/// 
/// Coordinates between different storage services without containing
/// implementation details. Each storage backend is handled by its
/// dedicated service:
/// 
/// - PreferencesStorageService: Simple key-value pairs, app settings
/// - HiveStorageService: Fast access data, user sessions, temporary data
/// - SQLiteStorageService: Complex queries, relational data, large datasets
/// 
/// Follows Single Responsibility Principle by only orchestrating
/// storage services without implementing storage logic directly.
class StorageManager {
  static final StorageManager instance = StorageManager._internal();
  
  StorageManager._internal();

  // Storage Services
  final PreferencesStorageServiceImpl _prefsService = PreferencesStorageServiceImpl();
  final HiveStorageServiceImpl _hiveService = HiveStorageServiceImpl();
  final SQLiteStorageServiceImpl _sqliteService = SQLiteStorageServiceImpl();

  bool _initialized = false;

  /// Get the preferences storage service
  PreferencesStorageService get preferencesService => _prefsService;

  /// Get the Hive storage service
  HiveStorageService get hiveService => _hiveService;

  /// Get the SQLite storage service
  SQLiteStorageService get sqliteService => _sqliteService;

  // DAOs (delegated to SQLiteStorageService)
  QuizDao? get quizDao => _sqliteService.quizDao;
  VideoDao? get videoDao => _sqliteService.videoDao;
  CacheDao? get cacheDao => _sqliteService.cacheDao;

  /// Initialize all storage services
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize all services in parallel for faster startup
      await Future.wait([
        _prefsService.init(),
        _hiveService.init(),
        _sqliteService.init(),
      ]);

      _initialized = true;
      debugPrint('✅ Storage Manager initialized successfully');
    } catch (e) {
      debugPrint('❌ Storage Manager initialization failed: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SharedPreferences Methods (delegated to PreferencesStorageService)
  // ============================================================================

  /// Save simple setting
  Future<bool> saveSetting(String key, dynamic value) async {
    return await _prefsService.saveSetting(key, value);
  }

  /// Get simple setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _prefsService.getSetting<T>(key, defaultValue: defaultValue);
  }

  /// Remove setting
  Future<bool> removeSetting(String key) async {
    return await _prefsService.removeSetting(key);
  }

  // ============================================================================
  // Hive Methods (delegated to HiveStorageService)
  // ============================================================================

  /// Save to Hive (for frequently accessed data)
  Future<void> saveToHive(String box, String key, dynamic value) async {
    await _hiveService.put(box, key, value);
  }

  /// Get from Hive
  T? getFromHive<T>(String box, String key, {T? defaultValue}) {
    return _hiveService.get<T>(box, key, defaultValue: defaultValue);
  }

  /// Delete from Hive
  Future<void> deleteFromHive(String box, String key) async {
    await _hiveService.delete(box, key);
  }

  /// Clear Hive box
  Future<void> clearHiveBox(String box) async {
    await _hiveService.clearBox(box);
  }

  // ============================================================================
  // User Session Management (delegated to HiveStorageService)
  // ============================================================================

  Future<void> saveUserSession(Map<String, dynamic> sessionData) async {
    await _hiveService.put(
      HiveStorageService.userSessionBox,
      'current_session',
      sessionData,
    );
  }

  Map<String, dynamic>? getUserSession() {
    return _hiveService.get<Map<String, dynamic>>(
      HiveStorageService.userSessionBox,
      'current_session',
    );
  }

  Future<void> clearUserSession() async {
    await _hiveService.clearBox(HiveStorageService.userSessionBox);
  }

  // ============================================================================
  // Cleanup Methods (coordinating all services)
  // ============================================================================

  /// Clear all user data (on logout)
  Future<void> clearAllUserData() async {
    await Future.wait([
      _hiveService.clearAll(),
      _sqliteService.clearAllData(),
      // Keep some SharedPreferences (like app settings)
    ]);
  }

  /// Perform maintenance (clear expired cache, old data)
  Future<void> performMaintenance() async {
    await _sqliteService.clearExpiredCache();
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStatistics(String userId) async {
    final quizStats = await _sqliteService.getQuizStatistics(userId);
    final videoStats = await _sqliteService.getVideoWatchStatistics(userId);
    final cacheStats = await _sqliteService.getCacheStatistics();

    return {
      'quiz': quizStats,
      'video': videoStats,
      'cache': cacheStats,
    };
  }
  
  /// Get video watch statistics (helper method)
  Future<Map<String, dynamic>> getVideoWatchStatistics(String userId) async {
    return await _sqliteService.getVideoWatchStatistics(userId);
  }

  /// Watch for changes in a Hive box
  Stream<BoxEvent> watchHiveBox(String boxName, {String? key}) {
    return _hiveService.watch(boxName, key: key);
  }

  /// Close all storage services
  Future<void> close() async {
    await Future.wait([
      _hiveService.close(),
      _sqliteService.close(),
    ]);
    _initialized = false;
  }
}
