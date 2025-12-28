/// Stub implementation of CacheDao for web platform
/// SQLite is not available on web, so this provides a no-op implementation
class CacheDao {
  /// Save to cache - no-op on web
  Future<int> saveToCache({
    required String key,
    required dynamic value,
    required String type,
    Duration expiration = const Duration(hours: 24),
  }) async {
    return 0;
  }

  /// Get from cache - returns null on web
  Future<dynamic> getFromCache(String key) async {
    return null;
  }

  /// Check if cache exists - returns false on web
  Future<bool> cacheExists(String key) async {
    return false;
  }

  /// Delete from cache - no-op on web
  Future<int> deleteFromCache(String key) async {
    return 0;
  }

  /// Clear expired cache - no-op on web
  Future<int> clearExpiredCache() async {
    return 0;
  }

  /// Clear all cache - no-op on web
  Future<int> clearAllCache() async {
    return 0;
  }

  /// Get cache statistics - returns empty on web
  Future<Map<String, dynamic>> getCacheStatistics() async {
    return {};
  }
}
