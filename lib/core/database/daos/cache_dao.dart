import 'dart:convert';

import 'package:guardiancare/core/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

/// Data Access Object for Cache operations
/// Handles offline caching with expiration
class CacheDao {
  final DatabaseService _dbService = DatabaseService.instance;

  /// Save data to cache
  Future<int> saveCache({
    required String key,
    required dynamic value,
    required String type,
    Duration ttl = const Duration(hours: 24),
  }) async {
    final db = await _dbService.database;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
    
    final data = {
      'cache_key': key,
      'cache_value': jsonEncode(value),
      'cache_type': type,
      'expires_at': expiresAt,
      'created_at': now,
    };

    return db.insert(
      'cache_data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get data from cache
  Future<dynamic> getCache(String key) async {
    final db = await _dbService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final results = await db.query(
      'cache_data',
      where: 'cache_key = ? AND expires_at > ?',
      whereArgs: [key, now],
      limit: 1,
    );

    if (results.isEmpty) return null;
    
    final cacheValue = results.first['cache_value'] as String;
    return jsonDecode(cacheValue);
  }

  /// Check if cache exists and is valid
  Future<bool> isCacheValid(String key) async {
    final db = await _dbService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM cache_data
      WHERE cache_key = ? AND expires_at > ?
    ''', [key, now]);

    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  /// Delete cache by key
  Future<int> deleteCache(String key) async {
    final db = await _dbService.database;
    
    return db.delete(
      'cache_data',
      where: 'cache_key = ?',
      whereArgs: [key],
    );
  }

  /// Delete cache by type
  Future<int> deleteCacheByType(String type) async {
    final db = await _dbService.database;
    
    return db.delete(
      'cache_data',
      where: 'cache_type = ?',
      whereArgs: [type],
    );
  }

  /// Clear expired cache
  Future<int> clearExpiredCache() async {
    final db = await _dbService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return db.delete(
      'cache_data',
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }

  /// Clear all cache
  Future<int> clearAllCache() async {
    final db = await _dbService.database;
    return db.delete('cache_data');
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final db = await _dbService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entries,
        COUNT(CASE WHEN expires_at > ? THEN 1 END) as valid_entries,
        COUNT(CASE WHEN expires_at <= ? THEN 1 END) as expired_entries,
        cache_type,
        COUNT(*) as count_by_type
      FROM cache_data
      GROUP BY cache_type
    ''', [now, now]);

    return {
      'total': result.length,
      'by_type': result,
    };
  }
}
