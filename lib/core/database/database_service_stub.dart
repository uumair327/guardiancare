/// Stub implementation of DatabaseService for web platform
/// SQLite is not available on web, so this provides a no-op implementation
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  
  DatabaseService._internal();

  /// Get database instance - throws on web
  Future<dynamic> get database async {
    throw UnsupportedError('SQLite is not supported on web platform');
  }

  /// Close database connection - no-op on web
  Future<void> close() async {}

  /// Clear all data - no-op on web
  Future<void> clearAllData() async {}

  /// Clear expired cache - no-op on web
  Future<void> clearExpiredCache() async {}
}
