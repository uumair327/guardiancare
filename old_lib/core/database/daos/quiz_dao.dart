import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:guardiancare/core/database/database_service.dart';

/// Data Access Object for Quiz operations
/// Handles all quiz-related database operations with proper error handling
class QuizDao {
  final DatabaseService _dbService = DatabaseService.instance;

  /// Save quiz result
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
    final db = await _dbService.database;
    
    final data = {
      'user_id': userId,
      'quiz_id': quizId,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'score_percentage': scorePercentage,
      'selected_answers': jsonEncode(selectedAnswers),
      'incorrect_categories': jsonEncode(incorrectCategories),
      'completed_at': DateTime.now().millisecondsSinceEpoch,
      'synced': 0,
    };

    return await db.insert(
      'quiz_results',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get quiz results for a user
  Future<List<Map<String, dynamic>>> getQuizResults(String userId) async {
    final db = await _dbService.database;
    
    final results = await db.query(
      'quiz_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );

    return results.map((row) {
      return {
        ...row,
        'selected_answers': jsonDecode(row['selected_answers'] as String),
        'incorrect_categories': jsonDecode(row['incorrect_categories'] as String),
      };
    }).toList();
  }

  /// Get quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics(String userId) async {
    final db = await _dbService.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_quizzes,
        AVG(score_percentage) as average_score,
        MAX(score_percentage) as best_score,
        SUM(correct_answers) as total_correct,
        SUM(total_questions) as total_questions
      FROM quiz_results
      WHERE user_id = ?
    ''', [userId]);

    return result.first;
  }

  /// Get recent quiz results (last N results)
  Future<List<Map<String, dynamic>>> getRecentQuizResults(
    String userId, {
    int limit = 10,
  }) async {
    final db = await _dbService.database;
    
    return await db.query(
      'quiz_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
      limit: limit,
    );
  }

  /// Mark quiz result as synced
  Future<void> markAsSynced(int id) async {
    final db = await _dbService.database;
    
    await db.update(
      'quiz_results',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get unsynced quiz results
  Future<List<Map<String, dynamic>>> getUnsyncedResults(String userId) async {
    final db = await _dbService.database;
    
    return await db.query(
      'quiz_results',
      where: 'user_id = ? AND synced = 0',
      whereArgs: [userId],
    );
  }

  /// Delete old quiz results (keep last N days)
  Future<int> deleteOldResults(String userId, {int daysToKeep = 90}) async {
    final db = await _dbService.database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;
    
    return await db.delete(
      'quiz_results',
      where: 'user_id = ? AND completed_at < ?',
      whereArgs: [userId, cutoffTime],
    );
  }
}
