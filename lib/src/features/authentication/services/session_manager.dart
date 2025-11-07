import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user sessions including timeouts, renewals, and expiry handling
class SessionManager extends ChangeNotifier {
  static const Duration _defaultSessionTimeout = Duration(hours: 24);
  static const Duration _warningThreshold = Duration(minutes: 5);
  static const Duration _renewalThreshold = Duration(minutes: 10);
  static const String _sessionStartKey = 'session_start_time';
  static const String _lastActivityKey = 'last_activity_time';
  static const String _sessionTimeoutKey = 'session_timeout_duration';

  static SessionManager? _instance;
  Timer? _sessionTimer;
  Timer? _renewalTimer;
  SharedPreferences? _prefs;
  
  DateTime? _sessionStartTime;
  DateTime? _lastActivityTime;
  Duration _sessionTimeout = _defaultSessionTimeout;
  bool _isSessionActive = false;
  bool _isWarningShown = false;

  SessionManager._();

  /// Get singleton instance
  static SessionManager get instance {
    _instance ??= SessionManager._();
    return _instance!;
  }

  /// Initialize the session manager
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadSessionData();
    _setupAuthListener();
    
    // Check if there's an existing session
    if (FirebaseAuth.instance.currentUser != null) {
      await _validateExistingSession();
    }
  }

  /// Start a new session
  Future<void> startSession({Duration? customTimeout}) async {
    final now = DateTime.now();
    
    _sessionStartTime = now;
    _lastActivityTime = now;
    _sessionTimeout = customTimeout ?? _defaultSessionTimeout;
    _isSessionActive = true;
    _isWarningShown = false;

    await _saveSessionData();
    _startSessionTimer();
    _startRenewalTimer();
    
    print('📱 Session started at $now (timeout: ${_sessionTimeout.inHours}h)');
    notifyListeners();
  }

  /// Update last activity time to extend session
  Future<void> updateActivity() async {
    if (!_isSessionActive) return;

    _lastActivityTime = DateTime.now();
    await _saveSessionData();
    
    // Reset warning if user becomes active again
    if (_isWarningShown) {
      _isWarningShown = false;
      notifyListeners();
    }
  }

  /// End the current session
  Future<void> endSession() async {
    _sessionStartTime = null;
    _lastActivityTime = null;
    _isSessionActive = false;
    _isWarningShown = false;

    _sessionTimer?.cancel();
    _renewalTimer?.cancel();
    
    await _clearSessionData();
    
    print('📱 Session ended');
    notifyListeners();
  }

  /// Check if session is currently active
  bool get isSessionActive => _isSessionActive;

  /// Check if session warning should be shown
  bool get shouldShowWarning => _isWarningShown;

  /// Get remaining session time
  Duration? get remainingSessionTime {
    if (!_isSessionActive || _lastActivityTime == null) return null;
    
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = _sessionTimeout - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get session start time
  DateTime? get sessionStartTime => _sessionStartTime;

  /// Get last activity time
  DateTime? get lastActivityTime => _lastActivityTime;

  /// Get session timeout duration
  Duration get sessionTimeout => _sessionTimeout;

  /// Check if session is about to expire
  bool get isSessionNearExpiry {
    final remaining = remainingSessionTime;
    return remaining != null && remaining <= _warningThreshold;
  }

  /// Renew session if user is authenticated
  Future<SessionRenewalResult> renewSession() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return SessionRenewalResult.failure('No authenticated user found');
    }

    try {
      // Attempt to refresh the user's token
      await user.getIdToken(true);
      
      // Reset session timing
      await updateActivity();
      _isWarningShown = false;
      
      print('🔄 Session renewed successfully');
      notifyListeners();
      
      return SessionRenewalResult.success();
      
    } catch (e) {
      print('❌ Session renewal failed: $e');
      return SessionRenewalResult.failure('Failed to renew session: ${e.toString()}');
    }
  }

  /// Force session expiry
  Future<void> expireSession() async {
    print('⏰ Session expired');
    
    await endSession();
    
    // Sign out the user
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out during session expiry: $e');
    }
  }

  /// Set custom session timeout
  Future<void> setSessionTimeout(Duration timeout) async {
    _sessionTimeout = timeout;
    await _saveSessionData();
    
    // Restart timers with new timeout
    if (_isSessionActive) {
      _startSessionTimer();
      _startRenewalTimer();
    }
    
    notifyListeners();
  }

  /// Get session statistics
  SessionStats getSessionStats() {
    return SessionStats(
      isActive: _isSessionActive,
      startTime: _sessionStartTime,
      lastActivity: _lastActivityTime,
      timeout: _sessionTimeout,
      remainingTime: remainingSessionTime,
      isNearExpiry: isSessionNearExpiry,
      shouldShowWarning: _isWarningShown,
    );
  }

  /// Setup Firebase Auth state listener
  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null && _isSessionActive) {
        // User signed out, end session
        endSession();
      }
    });
  }

  /// Validate existing session on app startup
  Future<void> _validateExistingSession() async {
    if (_sessionStartTime == null || _lastActivityTime == null) {
      return;
    }

    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivityTime!);
    
    if (timeSinceLastActivity > _sessionTimeout) {
      // Session has expired
      print('📱 Existing session has expired');
      await expireSession();
    } else {
      // Session is still valid
      _isSessionActive = true;
      _startSessionTimer();
      _startRenewalTimer();
      
      print('📱 Existing session validated (${timeSinceLastActivity.inMinutes}m since last activity)');
      notifyListeners();
    }
  }

  /// Start session timeout timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    
    final remaining = remainingSessionTime;
    if (remaining == null || remaining <= Duration.zero) {
      expireSession();
      return;
    }

    // Set timer for warning threshold
    final warningTime = remaining - _warningThreshold;
    if (warningTime > Duration.zero) {
      _sessionTimer = Timer(warningTime, () {
        _isWarningShown = true;
        print('⚠️ Session expiry warning shown');
        notifyListeners();
        
        // Set timer for actual expiry
        _sessionTimer = Timer(_warningThreshold, () {
          expireSession();
        });
      });
    } else {
      // Already in warning period or past expiry
      if (remaining > Duration.zero) {
        _isWarningShown = true;
        _sessionTimer = Timer(remaining, () {
          expireSession();
        });
      } else {
        expireSession();
      }
    }
  }

  /// Start automatic session renewal timer
  void _startRenewalTimer() {
    _renewalTimer?.cancel();
    
    // Attempt renewal when approaching expiry
    final remaining = remainingSessionTime;
    if (remaining == null) return;
    
    final renewalTime = remaining - _renewalThreshold;
    if (renewalTime > Duration.zero) {
      _renewalTimer = Timer(renewalTime, () async {
        if (_isSessionActive && FirebaseAuth.instance.currentUser != null) {
          await renewSession();
        }
      });
    }
  }

  /// Save session data to SharedPreferences
  Future<void> _saveSessionData() async {
    if (_prefs == null) return;

    if (_sessionStartTime != null) {
      await _prefs!.setInt(_sessionStartKey, _sessionStartTime!.millisecondsSinceEpoch);
    }
    
    if (_lastActivityTime != null) {
      await _prefs!.setInt(_lastActivityKey, _lastActivityTime!.millisecondsSinceEpoch);
    }
    
    await _prefs!.setInt(_sessionTimeoutKey, _sessionTimeout.inMilliseconds);
  }

  /// Load session data from SharedPreferences
  Future<void> _loadSessionData() async {
    if (_prefs == null) return;

    final sessionStart = _prefs!.getInt(_sessionStartKey);
    if (sessionStart != null) {
      _sessionStartTime = DateTime.fromMillisecondsSinceEpoch(sessionStart);
    }

    final lastActivity = _prefs!.getInt(_lastActivityKey);
    if (lastActivity != null) {
      _lastActivityTime = DateTime.fromMillisecondsSinceEpoch(lastActivity);
    }

    final timeout = _prefs!.getInt(_sessionTimeoutKey);
    if (timeout != null) {
      _sessionTimeout = Duration(milliseconds: timeout);
    }
  }

  /// Clear session data from SharedPreferences
  Future<void> _clearSessionData() async {
    if (_prefs == null) return;

    await _prefs!.remove(_sessionStartKey);
    await _prefs!.remove(_lastActivityKey);
    // Keep timeout setting for next session
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _renewalTimer?.cancel();
    super.dispose();
  }
}

/// Result of session renewal attempt
class SessionRenewalResult {
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;

  SessionRenewalResult._({
    required this.success,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SessionRenewalResult.success() {
    return SessionRenewalResult._(success: true);
  }

  factory SessionRenewalResult.failure(String errorMessage) {
    return SessionRenewalResult._(success: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    return 'SessionRenewalResult{success: $success, error: $errorMessage}';
  }
}

/// Session statistics and status information
class SessionStats {
  final bool isActive;
  final DateTime? startTime;
  final DateTime? lastActivity;
  final Duration timeout;
  final Duration? remainingTime;
  final bool isNearExpiry;
  final bool shouldShowWarning;

  SessionStats({
    required this.isActive,
    this.startTime,
    this.lastActivity,
    required this.timeout,
    this.remainingTime,
    required this.isNearExpiry,
    required this.shouldShowWarning,
  });

  /// Get session duration
  Duration? get sessionDuration {
    if (startTime == null) return null;
    return DateTime.now().difference(startTime!);
  }

  /// Get time since last activity
  Duration? get timeSinceLastActivity {
    if (lastActivity == null) return null;
    return DateTime.now().difference(lastActivity!);
  }

  /// Get formatted remaining time
  String get formattedRemainingTime {
    if (remainingTime == null) return 'N/A';
    
    final hours = remainingTime!.inHours;
    final minutes = remainingTime!.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  String toString() {
    return 'SessionStats{active: $isActive, remaining: $formattedRemainingTime, nearExpiry: $isNearExpiry}';
  }
}