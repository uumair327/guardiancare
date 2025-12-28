/// Stub implementation of QuizDao for web platform
/// SQLite is not available on web, so this provides a no-op implementation
class QuizDao {
  /// Save quiz result - no-op on web
  Future<int> saveQuizResult({
    required String userId,
    required String quizId,
    required int totalQuestions,
    required int correctAnswers,
    required int incorrectAnswers,
    required double scorePercentage,
    required Map<int, String> selectedAnswers,
    required List<String> incorrectCategories,
  }) async {
    return 0;
  }

  /// Get quiz results - returns empty on web
  Future<List<Map<String, dynamic>>> getQuizResults(String userId) async {
    return [];
  }

  /// Get quiz statistics - returns empty on web
  Future<Map<String, dynamic>> getQuizStatistics(String userId) async {
    return {};
  }

  /// Get recent quiz results - returns empty on web
  Future<List<Map<String, dynamic>>> getRecentQuizResults(
    String userId, {
    int limit = 10,
  }) async {
    return [];
  }

  /// Mark quiz result as synced - no-op on web
  Future<void> markAsSynced(int id) async {}

  /// Get unsynced quiz results - returns empty on web
  Future<List<Map<String, dynamic>>> getUnsyncedResults(String userId) async {
    return [];
  }

  /// Delete old quiz results - no-op on web
  Future<int> deleteOldResults(String userId, {int daysToKeep = 90}) async {
    return 0;
  }
}
