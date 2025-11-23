# Storage Architecture - Industrial Grade Implementation

## Overview

This app uses a **three-tier storage strategy** for optimal performance, reliability, and scalability:

1. **SharedPreferences** - Simple key-value pairs
2. **Hive** - Fast NoSQL database for frequently accessed data
3. **SQLite** - Relational database for complex queries and large datasets

## Storage Decision Matrix

| Data Type | Storage Solution | Reason |
|-----------|-----------------|---------|
| App Settings | SharedPreferences | Simple, fast, native |
| User Session | Hive | Fast access, automatic serialization |
| Quiz Results | SQLite | Complex queries, statistics, history |
| Video History | SQLite | Relational data, progress tracking |
| Cache Data | SQLite | TTL support, bulk operations |
| Reports | Hive | Fast read/write, document-style |
| Temporary Data | Hive | Quick access, auto-cleanup |

## Architecture Components

### 1. DatabaseService (SQLite)
- **Location**: `lib/core/database/database_service.dart`
- **Purpose**: Manages SQLite database with migrations and optimizations
- **Features**:
  - WAL mode for better concurrency
  - Foreign key support
  - Automatic migrations
  - Connection pooling

### 2. HiveService
- **Location**: `lib/core/database/hive_service.dart`
- **Purpose**: Fast key-value storage with type safety
- **Features**:
  - Multiple boxes for organization
  - Reactive streams
  - Encryption support
  - Compact operations

### 3. StorageManager
- **Location**: `lib/core/database/storage_manager.dart`
- **Purpose**: Unified interface for all storage operations
- **Features**:
  - Intelligent routing
  - Maintenance operations
  - Statistics tracking
  - Cleanup utilities

### 4. Data Access Objects (DAOs)
- **QuizDao**: Quiz results and statistics
- **VideoDao**: Watch history and progress
- **CacheDao**: Offline caching with TTL

## Usage Examples

### Saving Quiz Results
```dart
final storageManager = StorageManager.instance;
await storageManager.quizDao.saveQuizResult(
  userId: 'user123',
  quizId: 'quiz456',
  totalQuestions: 10,
  correctAnswers: 8,
  incorrectAnswers: 2,
  scorePercentage: 80.0,
  selectedAnswers: {0: 'A', 1: 'B'},
  incorrectCategories: ['Safety'],
);
```

### Tracking Video Progress
```dart
await storageManager.videoDao.saveVideoHistory(
  userId: 'user123',
  videoId: 'video789',
  videoTitle: 'Child Safety Basics',
  videoUrl: 'https://...',
  category: 'Safety',
  watchDuration: 120,
  totalDuration: 300,
);
```

### Caching Data
```dart
await storageManager.cacheDao.saveCache(
  key: 'recommended_videos',
  value: videoList,
  type: 'videos',
  ttl: Duration(hours: 6),
);

final cached = await storageManager.cacheDao.getCache('recommended_videos');
```

### User Session Management
```dart
// Save session
await storageManager.saveUserSession({
  'userId': 'user123',
  'lastActive': DateTime.now().toIso8601String(),
  'preferences': {...},
});

// Get session
final session = storageManager.getUserSession();
```

## Best Practices

### 1. Data Lifecycle
- **Create**: Use appropriate storage based on data type
- **Read**: Cache frequently accessed data
- **Update**: Use transactions for consistency
- **Delete**: Clean up old data regularly

### 2. Performance Optimization
```dart
// Batch operations
await db.transaction((txn) async {
  for (var item in items) {
    await txn.insert('table', item);
  }
});

// Use indexes for frequent queries
CREATE INDEX idx_user_date ON table(user_id, created_at DESC);

// Compact Hive boxes periodically
await hiveService.compact('boxName');
```

### 3. Error Handling
```dart
try {
  await storageManager.quizDao.saveQuizResult(...);
} on CacheException catch (e) {
  // Handle storage errors
  logger.error('Failed to save quiz result: $e');
  // Fallback or retry logic
}
```

### 4. Maintenance
```dart
// Run periodically (e.g., on app start or daily)
await storageManager.performMaintenance();

// Clear expired cache
await storageManager.cacheDao.clearExpiredCache();

// Delete old data
await storageManager.quizDao.deleteOldResults(userId, daysToKeep: 90);
```

### 5. Logout/Cleanup
```dart
// Clear all user data on logout
await storageManager.clearAllUserData();

// Or selectively clear
await storageManager.clearUserSession();
await storageManager.clearHiveBox(HiveService.cacheBox);
```

## Database Schema

### quiz_results
```sql
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
);
```

### video_history
```sql
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
);
```

### cache_data
```sql
CREATE TABLE cache_data (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cache_key TEXT NOT NULL UNIQUE,
  cache_value TEXT NOT NULL,
  cache_type TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);
```

## Hive Boxes

- **user_session**: Current user session data
- **user_settings**: User preferences and settings
- **cache**: Temporary cached data
- **secure**: Encrypted sensitive data
- **reports**: Report form data

## Migration Strategy

### Adding New Tables
1. Increment database version in `DatabaseService`
2. Add migration logic in `_onUpgrade`
3. Test with existing data

```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE quiz_results ADD COLUMN difficulty TEXT');
  }
}
```

### Adding New Hive Boxes
```dart
// In HiveService.init()
await Hive.openBox('new_box_name');
```

## Testing

### Unit Tests
```dart
test('should save quiz result', () async {
  final dao = QuizDao();
  final id = await dao.saveQuizResult(...);
  expect(id, greaterThan(0));
});
```

### Integration Tests
```dart
testWidgets('should persist data across app restarts', (tester) async {
  await storageManager.init();
  await storageManager.saveSetting('key', 'value');
  
  // Simulate app restart
  await storageManager.close();
  await storageManager.init();
  
  expect(storageManager.getSetting('key'), equals('value'));
});
```

## Monitoring & Analytics

### Storage Statistics
```dart
final stats = await storageManager.getStorageStatistics(userId);
print('Quiz stats: ${stats['quiz']}');
print('Video stats: ${stats['video']}');
print('Cache stats: ${stats['cache']}');
```

### Performance Metrics
- Track query execution times
- Monitor cache hit rates
- Log storage errors
- Alert on storage limits

## Security Considerations

1. **Encryption**: Use Hive's encryption for sensitive data
2. **Validation**: Validate all input before storage
3. **Sanitization**: Prevent SQL injection with parameterized queries
4. **Access Control**: User-specific data isolation
5. **Backup**: Regular backups for critical data

## Future Enhancements

- [ ] Cloud sync for offline-first architecture
- [ ] Compression for large datasets
- [ ] Multi-user support with data isolation
- [ ] Advanced analytics and reporting
- [ ] Automated backup and restore
- [ ] Data export functionality
