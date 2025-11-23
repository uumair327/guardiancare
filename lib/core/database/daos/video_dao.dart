import 'package:sqflite/sqflite.dart';
import 'package:guardiancare/core/database/database_service.dart';

/// Data Access Object for Video operations
/// Tracks video watch history and progress
class VideoDao {
  final DatabaseService _dbService = DatabaseService.instance;

  /// Save or update video watch history
  Future<int> saveVideoHistory({
    required String userId,
    required String videoId,
    required String videoTitle,
    required String videoUrl,
    String? category,
    int watchDuration = 0,
    int totalDuration = 0,
    bool completed = false,
  }) async {
    final db = await _dbService.database;
    
    final data = {
      'user_id': userId,
      'video_id': videoId,
      'video_title': videoTitle,
      'video_url': videoUrl,
      'category': category,
      'watch_duration': watchDuration,
      'total_duration': totalDuration,
      'last_watched_at': DateTime.now().millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
    };

    return await db.insert(
      'video_history',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get video watch history for a user
  Future<List<Map<String, dynamic>>> getVideoHistory(
    String userId, {
    int? limit,
  }) async {
    final db = await _dbService.database;
    
    return await db.query(
      'video_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_watched_at DESC',
      limit: limit,
    );
  }

  /// Get video progress
  Future<Map<String, dynamic>?> getVideoProgress(
    String userId,
    String videoId,
  ) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'video_history',
      where: 'user_id = ? AND video_id = ?',
      whereArgs: [userId, videoId],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Update video watch progress
  Future<void> updateVideoProgress({
    required String userId,
    required String videoId,
    required int watchDuration,
    required int totalDuration,
  }) async {
    final db = await _dbService.database;
    
    final completed = watchDuration >= (totalDuration * 0.9); // 90% completion
    
    await db.update(
      'video_history',
      {
        'watch_duration': watchDuration,
        'total_duration': totalDuration,
        'last_watched_at': DateTime.now().millisecondsSinceEpoch,
        'completed': completed ? 1 : 0,
      },
      where: 'user_id = ? AND video_id = ?',
      whereArgs: [userId, videoId],
    );
  }

  /// Get completed videos count
  Future<int> getCompletedVideosCount(String userId) async {
    final db = await _dbService.database;
    
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM video_history
      WHERE user_id = ? AND completed = 1
    ''', [userId]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get videos by category
  Future<List<Map<String, dynamic>>> getVideosByCategory(
    String userId,
    String category,
  ) async {
    final db = await _dbService.database;
    
    return await db.query(
      'video_history',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'last_watched_at DESC',
    );
  }

  /// Get watch time statistics
  Future<Map<String, dynamic>> getWatchStatistics(String userId) async {
    final db = await _dbService.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_videos,
        SUM(watch_duration) as total_watch_time,
        COUNT(CASE WHEN completed = 1 THEN 1 END) as completed_videos,
        AVG(CASE WHEN total_duration > 0 
          THEN (watch_duration * 100.0 / total_duration) 
          ELSE 0 END) as avg_completion_rate
      FROM video_history
      WHERE user_id = ?
    ''', [userId]);

    return result.first;
  }

  /// Clear video history for a user
  Future<int> clearHistory(String userId) async {
    final db = await _dbService.database;
    
    return await db.delete(
      'video_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Delete old video history (keep last N days)
  Future<int> deleteOldHistory(String userId, {int daysToKeep = 30}) async {
    final db = await _dbService.database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;
    
    return await db.delete(
      'video_history',
      where: 'user_id = ? AND last_watched_at < ?',
      whereArgs: [userId, cutoffTime],
    );
  }
}
