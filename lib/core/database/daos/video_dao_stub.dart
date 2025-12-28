/// Stub implementation of VideoDao for web platform
/// SQLite is not available on web, so this provides a no-op implementation
class VideoDao {
  /// Save video watch progress - no-op on web
  Future<int> saveWatchProgress({
    required String userId,
    required String videoId,
    required String videoTitle,
    required String videoUrl,
    String? category,
    int watchDuration = 0,
    int totalDuration = 0,
    bool completed = false,
  }) async {
    return 0;
  }

  /// Get video watch history - returns empty on web
  Future<List<Map<String, dynamic>>> getWatchHistory(String userId) async {
    return [];
  }

  /// Get video progress - returns null on web
  Future<Map<String, dynamic>?> getVideoProgress(
    String userId,
    String videoId,
  ) async {
    return null;
  }

  /// Get watch statistics - returns empty on web
  Future<Map<String, dynamic>> getWatchStatistics(String userId) async {
    return {};
  }

  /// Get recently watched videos - returns empty on web
  Future<List<Map<String, dynamic>>> getRecentlyWatched(
    String userId, {
    int limit = 10,
  }) async {
    return [];
  }

  /// Get completed videos count - returns 0 on web
  Future<int> getCompletedVideosCount(String userId) async {
    return 0;
  }

  /// Delete video history - no-op on web
  Future<int> deleteVideoHistory(String userId, String videoId) async {
    return 0;
  }

  /// Clear all history for user - no-op on web
  Future<int> clearAllHistory(String userId) async {
    return 0;
  }
}
