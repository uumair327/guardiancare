# SQLite PRAGMA Fix

## Issue
App was crashing on startup with error:
```
DatabaseException(unknown error (code 0 SQLITE_OK): Queries can be performed using SQLiteDatabase query or rawQuery methods only.) sql 'PRAGMA journal_mode = WAL' args []
```

## Root Cause
SQLite PRAGMA commands that return results (like `PRAGMA journal_mode = WAL`) must use `rawQuery()` instead of `execute()` in sqflite.

## Solution

### Before (❌ Incorrect):
```dart
Future<void> _onConfigure(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');
  await db.execute('PRAGMA journal_mode = WAL');  // ❌ Error!
  await db.execute('PRAGMA synchronous = NORMAL'); // ❌ Error!
}
```

### After (✅ Correct):
```dart
Future<void> _onConfigure(Database db) async {
  // Enable foreign keys (doesn't return results, can use execute)
  await db.execute('PRAGMA foreign_keys = ON');
}

Future<Database> _initDatabase() async {
  final db = await openDatabase(...);
  
  // Set WAL mode after opening (returns results, must use rawQuery)
  try {
    await db.rawQuery('PRAGMA journal_mode = WAL');
    await db.rawQuery('PRAGMA synchronous = NORMAL');
  } catch (e) {
    print('Warning: Could not set WAL mode: $e');
  }
  
  return db;
}
```

## Key Points

1. **PRAGMA commands that return results** must use `rawQuery()`:
   - `PRAGMA journal_mode = WAL`
   - `PRAGMA synchronous = NORMAL`
   - `PRAGMA user_version`

2. **PRAGMA commands that don't return results** can use `execute()`:
   - `PRAGMA foreign_keys = ON`

3. **WAL mode** should be set after database is opened, not in `onConfigure`

4. **Error handling** added to gracefully handle cases where WAL mode can't be set

## Benefits of WAL Mode

- Better concurrency (readers don't block writers)
- Faster in most scenarios
- More robust crash recovery

## Status
✅ **FIXED** - App now starts successfully with proper SQLite configuration
