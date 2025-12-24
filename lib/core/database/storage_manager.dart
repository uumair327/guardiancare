import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:guardiancare/core/database/database_service.dart';
import 'package:guardiancare/core/database/hive_service.dart';
import 'package:guardiancare/core/database/daos/quiz_dao.dart';
import 'package:guardiancare/core/database/daos/video_dao.dart';
import 'package:guardiancare/core/database/daos/cache_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified Storage Manager
/// Intelligently routes data to the appropriate storage solution:
/// - SharedPreferences: Simple key-value pairs, app settings
/// - Hive: Fast access data, user sessions, temporary data
/// - SQLite: Complex queries, relational data, large datasets (not available on web)
class StorageManager {
  static final StorageManager instance = StorageManager._internal();
  
  StorageManager._internal();

  // Services
  final DatabaseService _dbService = DatabaseService.instance;
  final HiveService _hiveService = HiveService.instance;
  late SharedPreferences _prefs;

  // DAOs (only available on non-web platforms)
  QuizDao? quizDao;
  VideoDao? videoDao;
  CacheDao? cacheDao;

  bool _initialized = false;

  /// Initialize all storage services
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize in parallel for faster startup
      final futures = <Future>[
        _initSharedPreferences(),
        _initHive(),
      ];
      
      // SQLite is not supported on web
      if (!kIsWeb) {
        futures.add(_initSQLite());
      }
      
      await Future.wait(futures);

      _initialized = true;
      debugPrint('✅ Storage Manager initialized successfully');
    } catch (e) {
      debugPrint('❌ Storage Manager initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _initHive() async {
    await _hiveService.init();
  }

  Future<void> _initSQLite() async {
    await _dbService.database; // Initialize database
    quizDao = QuizDao();
    videoDao = VideoDao();
    cacheDao = CacheDao();
  }

  // ============================================================================
  // SharedPreferences Methods (Simple Settings)
  // ============================================================================

  /// Save simple setting
  Future<bool> saveSetting(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    }
    throw ArgumentError('Unsupported type for SharedPreferences');
  }

  /// Get simple setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _prefs.get(key) as T? ?? defaultValue;
  }

  /// Remove setting
  Future<bool> removeSetting(String key) async {
    return await _prefs.remove(key);
  }

  // ============================================================================
  // Hive Methods (Fast Access Data)
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
  // User Session Management (Hive)
  // ============================================================================

  Future<void> saveUserSession(Map<String, dynamic> sessionData) async {
    await _hiveService.put(
      HiveService.userSessionBox,
      'current_session',
      sessionData,
    );
  }

  Map<String, dynamic>? getUserSession() {
    return _hiveService.get<Map<String, dynamic>>(
      HiveService.userSessionBox,
      'current_session',
    );
  }

  Future<void> clearUserSession() async {
    await _hiveService.clearBox(HiveService.userSessionBox);
  }

  // ============================================================================
  // Cleanup Methods
  // ============================================================================

  /// Clear all user data (on logout)
  Future<void> clearAllUserData() async {
    final futures = <Future>[
      _hiveService.clearAll(),
      // Keep some SharedPreferences (like app settings)
    ];
    
    // SQLite cleanup only on non-web platforms
    if (!kIsWeb) {
      futures.add(_dbService.clearAllData());
    }
    
    await Future.wait(futures);
  }

  /// Perform maintenance (clear expired cache, old data)
  Future<void> performMaintenance() async {
    final futures = <Future>[];
    
    if (!kIsWeb && cacheDao != null) {
      futures.add(cacheDao!.clearExpiredCache());
      futures.add(_dbService.clearExpiredCache());
    }
    
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStatistics(String userId) async {
    if (kIsWeb) {
      // Return empty stats on web since SQLite is not available
      return {
        'quiz': {},
        'video': {},
        'cache': {},
      };
    }
    
    final quizStats = await quizDao!.getQuizStatistics(userId);
    final videoStats = await videoDao!.getWatchStatistics(userId);
    final cacheStats = await cacheDao!.getCacheStatistics();

    return {
      'quiz': quizStats,
      'video': videoStats,
      'cache': cacheStats,
    };
  }
  
  /// Get video watch statistics (helper method)
  Future<Map<String, dynamic>> getVideoWatchStatistics(String userId) async {
    if (kIsWeb || videoDao == null) {
      return {};
    }
    return await videoDao!.getWatchStatistics(userId);
  }

  /// Close all storage services
  Future<void> close() async {
    final futures = <Future>[
      _hiveService.close(),
    ];
    
    if (!kIsWeb) {
      futures.add(_dbService.close());
    }
    
    await Future.wait(futures);
    _initialized = false;
  }
}
