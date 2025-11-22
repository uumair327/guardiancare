import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized state management for critical user data
class AppStateManager extends ChangeNotifier {
  static AppStateManager? _instance;
  SharedPreferences? _prefs;
  
  // State persistence keys
  static const String _userStateKey = 'app_user_state';
  static const String _appStateKey = 'app_global_state';
  static const String _lastSyncKey = 'app_last_sync';
  
  // State data
  Map<String, dynamic> _userState = {};
  Map<String, dynamic> _appState = {};
  DateTime? _lastSyncTime;
  bool _isInitialized = false;
  bool _isSyncing = false;
  
  AppStateManager._();
  
  static AppStateManager get instance {
    _instance ??= AppStateManager._();
    return _instance!;
  }

  /// Initialize the state manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs ??= await SharedPreferences.getInstance();
    await _loadPersistedState();
    _isInitialized = true;
    
    print('AppStateManager: Initialized');
  }

  /// Check if state manager is initialized
  bool get isInitialized => _isInitialized;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Set user state value
  Future<void> setUserState(String key, dynamic value) async {
    _userState[key] = value;
    await _persistUserState();
    notifyListeners();
  }

  /// Get user state value
  T? getUserState<T>(String key) {
    return _userState[key] as T?;
  }

  /// Set app state value
  Future<void> setAppState(String key, dynamic value) async {
    _appState[key] = value;
    await _persistAppState();
    notifyListeners();
  }

  /// Get app state value
  T? getAppState<T>(String key) {
    return _appState[key] as T?;
  }

  /// Clear user state
  Future<void> clearUserState() async {
    _userState.clear();
    await _prefs?.remove(_userStateKey);
    notifyListeners();
  }

  /// Clear app state
  Future<void> clearAppState() async {
    _appState.clear();
    await _prefs?.remove(_appStateKey);
    notifyListeners();
  }

  /// Clear all state
  Future<void> clearAllState() async {
    await clearUserState();
    await clearAppState();
    _lastSyncTime = null;
    await _prefs?.remove(_lastSyncKey);
  }

  /// Sync state with server
  Future<StateSyncResult> syncWithServer({
    required Future<Map<String, dynamic>> Function() fetchServerState,
    required Future<bool> Function(Map<String, dynamic>) pushLocalState,
  }) async {
    if (_isSyncing) {
      return StateSyncResult.failure('Sync already in progress');
    }

    _isSyncing = true;
    notifyListeners();

    try {
      // Fetch server state
      final serverState = await fetchServerState();
      
      // Resolve conflicts
      final resolvedState = _resolveConflicts(_userState, serverState);
      
      // Push resolved state to server
      final pushSuccess = await pushLocalState(resolvedState);
      
      if (pushSuccess) {
        _userState = resolvedState;
        _lastSyncTime = DateTime.now();
        await _persistUserState();
        await _persistLastSyncTime();
        
        _isSyncing = false;
        notifyListeners();
        
        return StateSyncResult.success(_lastSyncTime!);
      } else {
        _isSyncing = false;
        notifyListeners();
        return StateSyncResult.failure('Failed to push state to server');
      }
    } catch (e) {
      _isSyncing = false;
      notifyListeners();
      return StateSyncResult.failure('Sync error: ${e.toString()}');
    }
  }

  /// Resolve conflicts between local and server state
  Map<String, dynamic> _resolveConflicts(
    Map<String, dynamic> localState,
    Map<String, dynamic> serverState,
  ) {
    final resolved = <String, dynamic>{};
    
    // Merge keys from both states
    final allKeys = {...localState.keys, ...serverState.keys};
    
    for (final key in allKeys) {
      final localValue = localState[key];
      final serverValue = serverState[key];
      
      if (localValue == null) {
        // Only on server, use server value
        resolved[key] = serverValue;
      } else if (serverValue == null) {
        // Only local, use local value
        resolved[key] = localValue;
      } else {
        // Both exist, use conflict resolution strategy
        resolved[key] = _resolveValueConflict(key, localValue, serverValue);
      }
    }
    
    return resolved;
  }

  /// Resolve conflict for a specific value
  dynamic _resolveValueConflict(String key, dynamic localValue, dynamic serverValue) {
    // Strategy: Server wins for most cases
    // Can be customized per key if needed
    
    // For timestamps, use the most recent
    if (key.contains('timestamp') || key.contains('time')) {
      if (localValue is String && serverValue is String) {
        try {
          final localTime = DateTime.parse(localValue);
          final serverTime = DateTime.parse(serverValue);
          return localTime.isAfter(serverTime) ? localValue : serverValue;
        } catch (e) {
          return serverValue; // Default to server on parse error
        }
      }
    }
    
    // For counters, use the higher value
    if (key.contains('count') || key.contains('score')) {
      if (localValue is num && serverValue is num) {
        return localValue > serverValue ? localValue : serverValue;
      }
    }
    
    // Default: server wins
    return serverValue;
  }

  /// Restore state after app backgrounding
  Future<void> restoreState() async {
    await _loadPersistedState();
    notifyListeners();
    print('AppStateManager: State restored');
  }

  /// Persist user state
  Future<void> _persistUserState() async {
    if (_prefs == null) return;
    
    try {
      final jsonString = jsonEncode(_userState);
      await _prefs!.setString(_userStateKey, jsonString);
    } catch (e) {
      print('AppStateManager: Error persisting user state: $e');
    }
  }

  /// Persist app state
  Future<void> _persistAppState() async {
    if (_prefs == null) return;
    
    try {
      final jsonString = jsonEncode(_appState);
      await _prefs!.setString(_appStateKey, jsonString);
    } catch (e) {
      print('AppStateManager: Error persisting app state: $e');
    }
  }

  /// Persist last sync time
  Future<void> _persistLastSyncTime() async {
    if (_prefs == null || _lastSyncTime == null) return;
    
    await _prefs!.setString(_lastSyncKey, _lastSyncTime!.toIso8601String());
  }

  /// Load persisted state
  Future<void> _loadPersistedState() async {
    if (_prefs == null) return;
    
    try {
      // Load user state
      final userStateString = _prefs!.getString(_userStateKey);
      if (userStateString != null) {
        _userState = jsonDecode(userStateString) as Map<String, dynamic>;
      }
      
      // Load app state
      final appStateString = _prefs!.getString(_appStateKey);
      if (appStateString != null) {
        _appState = jsonDecode(appStateString) as Map<String, dynamic>;
      }
      
      // Load last sync time
      final lastSyncString = _prefs!.getString(_lastSyncKey);
      if (lastSyncString != null) {
        _lastSyncTime = DateTime.parse(lastSyncString);
      }
      
      print('AppStateManager: State loaded from persistence');
    } catch (e) {
      print('AppStateManager: Error loading persisted state: $e');
    }
  }

  /// Get state summary
  StateManagerSummary getSummary() {
    return StateManagerSummary(
      isInitialized: _isInitialized,
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime,
      userStateKeys: _userState.keys.toList(),
      appStateKeys: _appState.keys.toList(),
      userStateSize: _userState.length,
      appStateSize: _appState.length,
    );
  }

  @override
  void dispose() {
    print('AppStateManager: Disposing');
    super.dispose();
  }
}

/// Result of state synchronization
class StateSyncResult {
  final bool success;
  final String? errorMessage;
  final DateTime? syncTime;

  StateSyncResult._({
    required this.success,
    this.errorMessage,
    this.syncTime,
  });

  factory StateSyncResult.success(DateTime syncTime) {
    return StateSyncResult._(
      success: true,
      syncTime: syncTime,
    );
  }

  factory StateSyncResult.failure(String errorMessage) {
    return StateSyncResult._(
      success: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'StateSyncResult{success: $success, error: $errorMessage, syncTime: $syncTime}';
  }
}

/// Summary of state manager status
class StateManagerSummary {
  final bool isInitialized;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final List<String> userStateKeys;
  final List<String> appStateKeys;
  final int userStateSize;
  final int appStateSize;

  StateManagerSummary({
    required this.isInitialized,
    required this.isSyncing,
    this.lastSyncTime,
    required this.userStateKeys,
    required this.appStateKeys,
    required this.userStateSize,
    required this.appStateSize,
  });

  @override
  String toString() {
    return 'StateManagerSummary{initialized: $isInitialized, syncing: $isSyncing, '
           'userState: $userStateSize keys, appState: $appStateSize keys, '
           'lastSync: $lastSyncTime}';
  }
}
