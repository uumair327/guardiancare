import 'package:guardiancare/core/util/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Industrial-grade SQLite database service
/// Handles all SQL database operations with proper error handling and migrations
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with proper configuration
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'guardiancare.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );

    // Set journal mode to WAL for better concurrency (must be done after opening)
    try {
      await db.rawQuery('PRAGMA journal_mode = WAL');
      await db.rawQuery('PRAGMA synchronous = NORMAL');
    } on Object catch (e) {
      Log.w('Could not set WAL mode: $e');
    }

    return db;
  }

  /// Configure database settings
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Quiz results table
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        quiz_id TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        incorrect_answers INTEGER NOT NULL,
        score_percentage REAL NOT NULL,
        selected_answers TEXT NOT NULL,
        incorrect_categories TEXT NOT NULL,
        completed_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        UNIQUE(user_id, quiz_id, completed_at)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_quiz_results_user 
      ON quiz_results(user_id, completed_at DESC)
    ''');

    // Video watch history table
    await db.execute('''
      CREATE TABLE video_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        video_id TEXT NOT NULL,
        video_title TEXT NOT NULL,
        video_url TEXT NOT NULL,
        category TEXT,
        watch_duration INTEGER DEFAULT 0,
        total_duration INTEGER DEFAULT 0,
        last_watched_at INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        UNIQUE(user_id, video_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_video_history_user 
      ON video_history(user_id, last_watched_at DESC)
    ''');

    // User preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL UNIQUE,
        theme_mode TEXT DEFAULT 'system',
        notifications_enabled INTEGER DEFAULT 1,
        parental_controls_enabled INTEGER DEFAULT 1,
        language TEXT DEFAULT 'en',
        updated_at INTEGER NOT NULL
      )
    ''');

    // Cache table for offline support
    await db.execute('''
      CREATE TABLE cache_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cache_key TEXT NOT NULL UNIQUE,
        cache_value TEXT NOT NULL,
        cache_type TEXT NOT NULL,
        expires_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_cache_expiry 
      ON cache_data(expires_at)
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic for future versions
    if (oldVersion < 2) {
      // Example migration for version 2
      // await db.execute('ALTER TABLE quiz_results ADD COLUMN new_field TEXT');
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (for logout/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('quiz_results');
      await txn.delete('video_history');
      await txn.delete('user_preferences');
      await txn.delete('cache_data');
    });
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete(
      'cache_data',
      where: 'expires_at < ?',
      whereArgs: [now],
    );
  }
}
