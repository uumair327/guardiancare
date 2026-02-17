import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:guardiancare/core/database/daos/daos.dart';
import 'package:guardiancare/core/util/logger.dart';

// Conditional import for DatabaseService
// ignore: uri_does_not_exist, directives_ordering
import 'package:guardiancare/core/database/database_service_stub.dart'
    if (dart.library.io) 'package:guardiancare/core/database/database_service.dart';

/// Service that handles SQLite operations exclusively.
///
/// This service is responsible for complex queries, relational data,
/// and large datasets that require SQL capabilities.
///
/// Note: SQLite is not available on web platforms.
///
/// Follows Single Responsibility Principle by handling only SQLite
/// operations without mixing with other storage backends.
abstract class SQLiteStorageService {
  /// Check if SQLite is available on the current platform
  bool get isAvailable;

  /// Initialize SQLite database
  Future<void> init();

  /// Get QuizDao for quiz-related operations
  QuizDao? get quizDao;

  /// Get VideoDao for video-related operations
  VideoDao? get videoDao;

  /// Get CacheDao for cache-related operations
  CacheDao? get cacheDao;

  /// Clear all data from the database
  Future<void> clearAllData();

  /// Clear expired cache entries
  Future<void> clearExpiredCache();

  /// Get quiz statistics for a user
  Future<Map<String, dynamic>> getQuizStatistics(String userId);

  /// Get video watch statistics for a user
  Future<Map<String, dynamic>> getVideoWatchStatistics(String userId);

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics();

  /// Close the database connection
  Future<void> close();
}

/// Implementation of SQLiteStorageService using sqflite
class SQLiteStorageServiceImpl implements SQLiteStorageService {
  final DatabaseService _dbService = DatabaseService.instance;

  QuizDao? _quizDao;
  VideoDao? _videoDao;
  CacheDao? _cacheDao;

  bool _initialized = false;

  @override
  bool get isAvailable => !kIsWeb;

  @override
  Future<void> init() async {
    if (_initialized) return;

    if (!isAvailable) {
      Log.w('⚠️ SQLite is not available on web platform');
      return;
    }

    try {
      await _dbService.database; // Initialize database
      _quizDao = QuizDao();
      _videoDao = VideoDao();
      _cacheDao = CacheDao();
      _initialized = true;
      Log.i('✅ SQLite Storage Service initialized successfully');
    } on Object catch (e) {
      Log.e('❌ SQLite Storage Service initialization failed: $e');
      rethrow;
    }
  }

  @override
  QuizDao? get quizDao {
    if (!isAvailable || !_initialized) return null;
    return _quizDao;
  }

  @override
  VideoDao? get videoDao {
    if (!isAvailable || !_initialized) return null;
    return _videoDao;
  }

  @override
  CacheDao? get cacheDao {
    if (!isAvailable || !_initialized) return null;
    return _cacheDao;
  }

  @override
  Future<void> clearAllData() async {
    if (!isAvailable || !_initialized) return;
    await _dbService.clearAllData();
  }

  @override
  Future<void> clearExpiredCache() async {
    if (!isAvailable || !_initialized) return;

    if (_cacheDao != null) {
      await _cacheDao!.clearExpiredCache();
    }
    await _dbService.clearExpiredCache();
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics(String userId) async {
    if (!isAvailable || !_initialized || _quizDao == null) {
      return {};
    }
    return _quizDao!.getQuizStatistics(userId);
  }

  @override
  Future<Map<String, dynamic>> getVideoWatchStatistics(String userId) async {
    if (!isAvailable || !_initialized || _videoDao == null) {
      return {};
    }
    return _videoDao!.getWatchStatistics(userId);
  }

  @override
  Future<Map<String, dynamic>> getCacheStatistics() async {
    if (!isAvailable || !_initialized || _cacheDao == null) {
      return {};
    }
    return _cacheDao!.getCacheStatistics();
  }

  @override
  Future<void> close() async {
    if (!isAvailable) return;
    await _dbService.close();
    _initialized = false;
  }
}
