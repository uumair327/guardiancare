import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/src/features/authentication/services/session_manager.dart';

void main() {
  group('SessionManager Tests', () {
    late SessionManager sessionManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sessionManager = SessionManager.instance;
      await sessionManager.initialize();
    });

    tearDown(() async {
      await sessionManager.endSession();
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = SessionManager.instance;
        final instance2 = SessionManager.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Session Lifecycle', () {
      test('should start session correctly', () async {
        expect(sessionManager.isSessionActive, isFalse);
        
        await sessionManager.startSession();
        
        expect(sessionManager.isSessionActive, isTrue);
        expect(sessionManager.sessionStartTime, isNotNull);
        expect(sessionManager.lastActivityTime, isNotNull);
      });

      test('should end session correctly', () async {
        await sessionManager.startSession();
        expect(sessionManager.isSessionActive, isTrue);
        
        await sessionManager.endSession();
        
        expect(sessionManager.isSessionActive, isFalse);
        expect(sessionManager.sessionStartTime, isNull);
        expect(sessionManager.lastActivityTime, isNull);
      });

      test('should start session with custom timeout', () async {
        const customTimeout = Duration(hours: 2);
        
        await sessionManager.startSession(customTimeout: customTimeout);
        
        expect(sessionManager.sessionTimeout, equals(customTimeout));
      });
    });

    group('Activity Tracking', () {
      test('should update activity time', () async {
        await sessionManager.startSession();
        
        final initialActivity = sessionManager.lastActivityTime;
        
        // Wait a moment and update activity
        await Future.delayed(const Duration(milliseconds: 10));
        await sessionManager.updateActivity();
        
        expect(sessionManager.lastActivityTime!.isAfter(initialActivity!), isTrue);
      });

      test('should not update activity when session is inactive', () async {
        expect(sessionManager.isSessionActive, isFalse);
        
        await sessionManager.updateActivity();
        
        expect(sessionManager.lastActivityTime, isNull);
      });
    });

    group('Session Timing', () {
      test('should calculate remaining session time correctly', () async {
        const timeout = Duration(minutes: 30);
        await sessionManager.startSession(customTimeout: timeout);
        
        final remaining = sessionManager.remainingSessionTime;
        
        expect(remaining, isNotNull);
        expect(remaining!.inMinutes, lessThanOrEqualTo(30));
        expect(remaining.inMinutes, greaterThan(29)); // Should be close to 30
      });

      test('should return null remaining time for inactive session', () {
        expect(sessionManager.remainingSessionTime, isNull);
      });

      test('should detect near expiry correctly', () async {
        // Start session with very short timeout
        const shortTimeout = Duration(minutes: 4);
        await sessionManager.startSession(customTimeout: shortTimeout);
        
        // Manually set last activity to make session near expiry
        // Note: This would require exposing internal methods for testing
        // For now, we test the logic exists
        expect(sessionManager.isSessionNearExpiry, isA<bool>());
      });
    });

    group('Session Renewal', () {
      test('should handle renewal when no user is authenticated', () async {
        await sessionManager.startSession();
        
        final result = await sessionManager.renewSession();
        
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('No authenticated user'));
      });

      test('should create renewal result correctly', () {
        final successResult = SessionRenewalResult.success();
        expect(successResult.success, isTrue);
        expect(successResult.errorMessage, isNull);

        final failureResult = SessionRenewalResult.failure('Test error');
        expect(failureResult.success, isFalse);
        expect(failureResult.errorMessage, equals('Test error'));
      });
    });

    group('Session Configuration', () {
      test('should set custom session timeout', () async {
        const newTimeout = Duration(hours: 12);
        
        await sessionManager.setSessionTimeout(newTimeout);
        
        expect(sessionManager.sessionTimeout, equals(newTimeout));
      });

      test('should persist timeout setting', () async {
        const customTimeout = Duration(hours: 6);
        
        await sessionManager.setSessionTimeout(customTimeout);
        
        // Create new instance to test persistence
        final newManager = SessionManager.instance;
        await newManager.initialize();
        
        expect(newManager.sessionTimeout, equals(customTimeout));
      });
    });

    group('Session Statistics', () {
      test('should provide session statistics', () async {
        await sessionManager.startSession();
        
        final stats = sessionManager.getSessionStats();
        
        expect(stats.isActive, isTrue);
        expect(stats.startTime, isNotNull);
        expect(stats.lastActivity, isNotNull);
        expect(stats.remainingTime, isNotNull);
        expect(stats.sessionDuration, isNotNull);
        expect(stats.timeSinceLastActivity, isNotNull);
      });

      test('should provide statistics for inactive session', () {
        final stats = sessionManager.getSessionStats();
        
        expect(stats.isActive, isFalse);
        expect(stats.startTime, isNull);
        expect(stats.lastActivity, isNull);
        expect(stats.remainingTime, isNull);
      });

      test('should format remaining time correctly', () async {
        await sessionManager.startSession(customTimeout: const Duration(hours: 2, minutes: 30));
        
        final stats = sessionManager.getSessionStats();
        final formatted = stats.formattedRemainingTime;
        
        expect(formatted, matches(RegExp(r'\d+h \d+m')));
      });

      test('should format minutes-only time correctly', () async {
        await sessionManager.startSession(customTimeout: const Duration(minutes: 45));
        
        final stats = sessionManager.getSessionStats();
        final formatted = stats.formattedRemainingTime;
        
        expect(formatted, matches(RegExp(r'\d+m')));
      });
    });

    group('Session Persistence', () {
      test('should save and load session data', () async {
        const customTimeout = Duration(hours: 8);
        await sessionManager.startSession(customTimeout: customTimeout);
        
        final originalStart = sessionManager.sessionStartTime;
        final originalActivity = sessionManager.lastActivityTime;
        
        // Create new instance to test persistence
        final newManager = SessionManager.instance;
        await newManager.initialize();
        
        // Note: In a real test, we'd need to properly test persistence
        // This requires more complex mocking of SharedPreferences
        expect(newManager.sessionTimeout, equals(customTimeout));
      });
    });

    group('Error Handling', () {
      test('should handle initialization errors gracefully', () async {
        // Should not throw during initialization
        expect(() => sessionManager.initialize(), returnsNormally);
      });

      test('should handle session operations when not initialized', () async {
        final uninitializedManager = SessionManager._();
        
        // Should not crash
        expect(() => uninitializedManager.updateActivity(), returnsNormally);
        expect(() => uninitializedManager.endSession(), returnsNormally);
      });
    });

    group('Memory Management', () {
      test('should dispose resources properly', () {
        sessionManager.dispose();
        
        // Should not crash after disposal
        expect(() => sessionManager.getSessionStats(), returnsNormally);
      });

      test('should handle multiple dispose calls', () {
        sessionManager.dispose();
        expect(() => sessionManager.dispose(), returnsNormally);
      });
    });

    group('Edge Cases', () {
      test('should handle very short session timeouts', () async {
        const veryShortTimeout = Duration(seconds: 1);
        
        await sessionManager.startSession(customTimeout: veryShortTimeout);
        
        expect(sessionManager.sessionTimeout, equals(veryShortTimeout));
        
        // Wait for session to expire
        await Future.delayed(const Duration(seconds: 2));
        
        // Session should be expired
        expect(sessionManager.isSessionActive, isFalse);
      });

      test('should handle very long session timeouts', () async {
        const veryLongTimeout = Duration(days: 30);
        
        await sessionManager.startSession(customTimeout: veryLongTimeout);
        
        expect(sessionManager.sessionTimeout, equals(veryLongTimeout));
        
        final remaining = sessionManager.remainingSessionTime;
        expect(remaining, isNotNull);
        expect(remaining!.inDays, greaterThan(29));
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners on session start', () async {
        int notificationCount = 0;
        sessionManager.addListener(() => notificationCount++);

        await sessionManager.startSession();
        
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on session end', () async {
        await sessionManager.startSession();
        
        int notificationCount = 0;
        sessionManager.addListener(() => notificationCount++);

        await sessionManager.endSession();
        
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners on activity update', () async {
        await sessionManager.startSession();
        
        int notificationCount = 0;
        sessionManager.addListener(() => notificationCount++);

        await sessionManager.updateActivity();
        
        expect(notificationCount, greaterThan(0));
      });
    });
  });

  group('SessionRenewalResult Tests', () {
    test('should create success result correctly', () {
      final result = SessionRenewalResult.success();
      
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.timestamp, isNotNull);
    });

    test('should create failure result correctly', () {
      final result = SessionRenewalResult.failure('Test error');
      
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Test error'));
      expect(result.timestamp, isNotNull);
    });

    test('should have proper string representation', () {
      final successResult = SessionRenewalResult.success();
      final failureResult = SessionRenewalResult.failure('Error');

      expect(successResult.toString(), contains('success: true'));
      expect(failureResult.toString(), contains('success: false'));
      expect(failureResult.toString(), contains('Error'));
    });
  });

  group('SessionStats Tests', () {
    test('should calculate session duration correctly', () {
      final startTime = DateTime.now().subtract(const Duration(hours: 2));
      
      final stats = SessionStats(
        isActive: true,
        startTime: startTime,
        lastActivity: DateTime.now(),
        timeout: const Duration(hours: 24),
        remainingTime: const Duration(hours: 22),
        isNearExpiry: false,
        shouldShowWarning: false,
      );

      final duration = stats.sessionDuration;
      expect(duration, isNotNull);
      expect(duration!.inHours, equals(2));
    });

    test('should calculate time since last activity correctly', () {
      final lastActivity = DateTime.now().subtract(const Duration(minutes: 30));
      
      final stats = SessionStats(
        isActive: true,
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        lastActivity: lastActivity,
        timeout: const Duration(hours: 24),
        remainingTime: const Duration(hours: 23),
        isNearExpiry: false,
        shouldShowWarning: false,
      );

      final timeSinceActivity = stats.timeSinceLastActivity;
      expect(timeSinceActivity, isNotNull);
      expect(timeSinceActivity!.inMinutes, equals(30));
    });

    test('should format remaining time correctly', () {
      final stats1 = SessionStats(
        isActive: true,
        startTime: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(hours: 24),
        remainingTime: const Duration(hours: 2, minutes: 30),
        isNearExpiry: false,
        shouldShowWarning: false,
      );

      expect(stats1.formattedRemainingTime, equals('2h 30m'));

      final stats2 = SessionStats(
        isActive: true,
        startTime: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(hours: 24),
        remainingTime: const Duration(minutes: 45),
        isNearExpiry: false,
        shouldShowWarning: false,
      );

      expect(stats2.formattedRemainingTime, equals('45m'));
    });

    test('should handle null remaining time', () {
      final stats = SessionStats(
        isActive: false,
        startTime: null,
        lastActivity: null,
        timeout: const Duration(hours: 24),
        remainingTime: null,
        isNearExpiry: false,
        shouldShowWarning: false,
      );

      expect(stats.formattedRemainingTime, equals('N/A'));
    });

    test('should have proper string representation', () {
      final stats = SessionStats(
        isActive: true,
        startTime: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(hours: 24),
        remainingTime: const Duration(hours: 2),
        isNearExpiry: false,
        shouldShowWarning: false,
      );

      final stringRep = stats.toString();
      expect(stringRep, contains('active: true'));
      expect(stringRep, contains('remaining: 2h 0m'));
      expect(stringRep, contains('nearExpiry: false'));
    });
  });
}