import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage failed parental key verification attempts and lockouts
class AttemptLimitingService {
  static const int _maxAttempts = 3;
  static const int _lockoutDurationMinutes = 5;
  static const String _attemptsKey = 'parental_key_attempts';
  static const String _lockoutTimeKey = 'parental_key_lockout_time';
  static const String _lastAttemptTimeKey = 'parental_key_last_attempt_time';

  static AttemptLimitingService? _instance;
  SharedPreferences? _prefs;

  AttemptLimitingService._();

  /// Get singleton instance
  static AttemptLimitingService get instance {
    _instance ??= AttemptLimitingService._();
    return _instance!;
  }

  /// Initialize the service with SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if the user is currently locked out
  Future<bool> isLockedOut() async {
    await initialize();
    
    final lockoutTime = _prefs!.getInt(_lockoutTimeKey);
    if (lockoutTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutExpiry = lockoutTime + (_lockoutDurationMinutes * 60 * 1000);

    if (now >= lockoutExpiry) {
      // Lockout has expired, clear it
      await _clearLockout();
      return false;
    }

    return true;
  }

  /// Get remaining lockout time in seconds
  Future<int> getRemainingLockoutTime() async {
    await initialize();
    
    if (!await isLockedOut()) return 0;

    final lockoutTime = _prefs!.getInt(_lockoutTimeKey)!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final lockoutExpiry = lockoutTime + (_lockoutDurationMinutes * 60 * 1000);

    return ((lockoutExpiry - now) / 1000).ceil();
  }

  /// Get remaining lockout time formatted as MM:SS
  Future<String> getRemainingLockoutTimeFormatted() async {
    final remainingSeconds = await getRemainingLockoutTime();
    if (remainingSeconds <= 0) return "00:00";

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  /// Get current number of failed attempts
  Future<int> getFailedAttempts() async {
    await initialize();
    return _prefs!.getInt(_attemptsKey) ?? 0;
  }

  /// Get remaining attempts before lockout
  Future<int> getRemainingAttempts() async {
    final failedAttempts = await getFailedAttempts();
    return (_maxAttempts - failedAttempts).clamp(0, _maxAttempts);
  }

  /// Record a failed verification attempt
  Future<AttemptResult> recordFailedAttempt() async {
    await initialize();
    
    // Check if already locked out
    if (await isLockedOut()) {
      final remainingTime = await getRemainingLockoutTime();
      return AttemptResult(
        success: false,
        isLockedOut: true,
        remainingAttempts: 0,
        remainingLockoutTime: remainingTime,
        message: 'Account is locked. Please wait ${await getRemainingLockoutTimeFormatted()} before trying again.',
      );
    }

    final currentAttempts = await getFailedAttempts();
    final newAttempts = currentAttempts + 1;
    
    await _prefs!.setInt(_attemptsKey, newAttempts);
    await _prefs!.setInt(_lastAttemptTimeKey, DateTime.now().millisecondsSinceEpoch);

    // Check if this attempt triggers a lockout
    if (newAttempts >= _maxAttempts) {
      await _triggerLockout();
      return AttemptResult(
        success: false,
        isLockedOut: true,
        remainingAttempts: 0,
        remainingLockoutTime: _lockoutDurationMinutes * 60,
        message: 'Too many failed attempts. Account locked for $_lockoutDurationMinutes minutes.',
      );
    }

    final remainingAttempts = _maxAttempts - newAttempts;
    return AttemptResult(
      success: false,
      isLockedOut: false,
      remainingAttempts: remainingAttempts,
      remainingLockoutTime: 0,
      message: 'Incorrect parental key. $remainingAttempts attempt${remainingAttempts == 1 ? '' : 's'} remaining.',
    );
  }

  /// Record a successful verification (clears attempts and lockout)
  Future<AttemptResult> recordSuccessfulAttempt() async {
    await initialize();
    
    await _clearAttempts();
    await _clearLockout();

    return AttemptResult(
      success: true,
      isLockedOut: false,
      remainingAttempts: _maxAttempts,
      remainingLockoutTime: 0,
      message: 'Parental key verified successfully.',
    );
  }

  /// Check if an attempt can be made (not locked out)
  Future<bool> canAttempt() async {
    return !(await isLockedOut());
  }

  /// Get detailed attempt status
  Future<AttemptStatus> getAttemptStatus() async {
    await initialize();
    
    final isLocked = await isLockedOut();
    final failedAttempts = await getFailedAttempts();
    final remainingAttempts = await getRemainingAttempts();
    final remainingLockoutTime = await getRemainingLockoutTime();
    final lastAttemptTime = _prefs!.getInt(_lastAttemptTimeKey);

    return AttemptStatus(
      isLockedOut: isLocked,
      failedAttempts: failedAttempts,
      remainingAttempts: remainingAttempts,
      remainingLockoutTime: remainingLockoutTime,
      remainingLockoutTimeFormatted: await getRemainingLockoutTimeFormatted(),
      lastAttemptTime: lastAttemptTime != null ? DateTime.fromMillisecondsSinceEpoch(lastAttemptTime) : null,
      canAttempt: await canAttempt(),
      maxAttempts: _maxAttempts,
      lockoutDurationMinutes: _lockoutDurationMinutes,
    );
  }

  /// Trigger immediate lockout
  Future<void> _triggerLockout() async {
    await _prefs!.setInt(_lockoutTimeKey, DateTime.now().millisecondsSinceEpoch);
    print('AttemptLimitingService: Lockout triggered for $_lockoutDurationMinutes minutes');
  }

  /// Clear failed attempts counter
  Future<void> _clearAttempts() async {
    await _prefs!.remove(_attemptsKey);
    print('AttemptLimitingService: Failed attempts cleared');
  }

  /// Clear lockout
  Future<void> _clearLockout() async {
    await _prefs!.remove(_lockoutTimeKey);
    print('AttemptLimitingService: Lockout cleared');
  }

  /// Reset all attempt data (for testing or admin purposes)
  Future<void> resetAllData() async {
    await initialize();
    await _clearAttempts();
    await _clearLockout();
    await _prefs!.remove(_lastAttemptTimeKey);
    print('AttemptLimitingService: All attempt data reset');
  }

  /// Get configuration values
  static int get maxAttempts => _maxAttempts;
  static int get lockoutDurationMinutes => _lockoutDurationMinutes;

  /// For testing purposes - allow manual time manipulation
  Future<void> setLockoutTime(DateTime lockoutTime) async {
    await initialize();
    await _prefs!.setInt(_lockoutTimeKey, lockoutTime.millisecondsSinceEpoch);
  }

  /// For testing purposes - set failed attempts count
  Future<void> setFailedAttempts(int attempts) async {
    await initialize();
    await _prefs!.setInt(_attemptsKey, attempts);
  }
}

/// Result of an attempt operation
class AttemptResult {
  final bool success;
  final bool isLockedOut;
  final int remainingAttempts;
  final int remainingLockoutTime; // in seconds
  final String message;

  AttemptResult({
    required this.success,
    required this.isLockedOut,
    required this.remainingAttempts,
    required this.remainingLockoutTime,
    required this.message,
  });

  @override
  String toString() {
    return 'AttemptResult(success: $success, isLockedOut: $isLockedOut, '
           'remainingAttempts: $remainingAttempts, remainingLockoutTime: $remainingLockoutTime, '
           'message: $message)';
  }
}

/// Detailed status of attempt limiting
class AttemptStatus {
  final bool isLockedOut;
  final int failedAttempts;
  final int remainingAttempts;
  final int remainingLockoutTime; // in seconds
  final String remainingLockoutTimeFormatted; // MM:SS format
  final DateTime? lastAttemptTime;
  final bool canAttempt;
  final int maxAttempts;
  final int lockoutDurationMinutes;

  AttemptStatus({
    required this.isLockedOut,
    required this.failedAttempts,
    required this.remainingAttempts,
    required this.remainingLockoutTime,
    required this.remainingLockoutTimeFormatted,
    required this.lastAttemptTime,
    required this.canAttempt,
    required this.maxAttempts,
    required this.lockoutDurationMinutes,
  });

  @override
  String toString() {
    return 'AttemptStatus(isLockedOut: $isLockedOut, failedAttempts: $failedAttempts, '
           'remainingAttempts: $remainingAttempts, remainingLockoutTime: $remainingLockoutTime, '
           'canAttempt: $canAttempt)';
  }
}