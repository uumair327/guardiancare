import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

void main() {
  group('AttemptLimitingService', () {
    late AttemptLimitingService service;

    setUp(() {
      service = AttemptLimitingService();
      service.clearAllAttempts(); // Start with clean state
    });

    tearDown(() {
      service.clearAllAttempts();
    });

    group('Basic Attempt Tracking', () {
      test('should allow verification attempts initially', () {
        expect(service.canAttemptVerification('user1'), isTrue);
        expect(service.getFailedAttemptCount('user1'), equals(0));
        expect(service.isUserLockedOut('user1'), isFalse);
      });

      test('should track failed attempts correctly', () {
        const userId = 'user1';
        
        service.recordFailedAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(1));
        expect(service.canAttemptVerification(userId), isTrue);
        
        service.recordFailedAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(2));
        expect(service.canAttemptVerification(userId), isTrue);
        
        service.recordFailedAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(3));
        expect(service.canAttemptVerification(userId), isFalse);
        expect(service.isUserLockedOut(userId), isTrue);
      });

      test('should reset attempts on successful verification', () {
        const userId = 'user1';
        
        service.recordFailedAttempt(userId);
        service.recordFailedAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(2));
        
        service.recordSuccessfulAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(0));
        expect(service.canAttemptVerification(userId), isTrue);
      });
    });

    group('Lockout Mechanism', () {
      test('should lock out user after max attempts', () {
        const userId = 'user1';
        
        // Record max attempts
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(userId);
        }
        
        expect(service.isUserLockedOut(userId), isTrue);
        expect(service.canAttemptVerification(userId), isFalse);
        
        final remainingTime = service.getRemainingLockoutTime(userId);
        expect(remainingTime.inMinutes, greaterThan(0));
        expect(remainingTime.inMinutes, lessThanOrEqualTo(5));
      });

      test('should prevent verification during lockout', () {
        const userId = 'user1';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(userId);
        }
        
        expect(service.canAttemptVerification(userId), isFalse);
        
        // Additional failed attempts should not change lockout state
        service.recordFailedAttempt(userId);
        expect(service.isUserLockedOut(userId), isTrue);
      });

      test('should calculate remaining lockout time correctly', () {
        const userId = 'user1';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(userId);
        }
        
        final remainingTime = service.getRemainingLockoutTime(userId);
        expect(remainingTime.inSeconds, greaterThan(0));
        expect(remainingTime.inSeconds, lessThanOrEqualTo(300)); // 5 minutes
      });

      test('should reset attempts after successful verification during lockout', () {
        const userId = 'user1';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(userId);
        }
        
        expect(service.isUserLockedOut(userId), isTrue);
        
        // Successful attempt should reset everything
        service.recordSuccessfulAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(0));
        expect(service.isUserLockedOut(userId), isFalse);
        expect(service.canAttemptVerification(userId), isTrue);
      });
    });

    group('Lockout Status', () {
      test('should return normal status initially', () {
        const userId = 'user1';
        final status = service.getLockoutStatus(userId);
        
        expect(status.state, equals(LockoutState.normal));
        expect(status.isNormal, isTrue);
        expect(status.hasWarning, isFalse);
        expect(status.isLockedOut, isFalse);
        expect(status.failedAttempts, equals(0));
      });

      test('should return warning status with failed attempts', () {
        const userId = 'user1';
        
        service.recordFailedAttempt(userId);
        final status = service.getLockoutStatus(userId);
        
        expect(status.state, equals(LockoutState.warning));
        expect(status.hasWarning, isTrue);
        expect(status.isLockedOut, isFalse);
        expect(status.failedAttempts, equals(1));
        expect(status.attemptsRemaining, equals(2));
      });

      test('should return locked out status after max attempts', () {
        const userId = 'user1';
        
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(userId);
        }
        
        final status = service.getLockoutStatus(userId);
        
        expect(status.state, equals(LockoutState.lockedOut));
        expect(status.isLockedOut, isTrue);
        expect(status.hasWarning, isFalse);
        expect(status.failedAttempts, equals(3));
        expect(status.remainingTime, isNotNull);
        expect(status.remainingTime!.inSeconds, greaterThan(0));
      });

      test('should provide appropriate status messages', () {
        const userId = 'user1';
        
        // Normal status
        var status = service.getLockoutStatus(userId);
        expect(status.message, contains('Enter your parental key'));
        
        // Warning status
        service.recordFailedAttempt(userId);
        status = service.getLockoutStatus(userId);
        expect(status.message, contains('Incorrect key'));
        expect(status.message, contains('2 attempts remaining'));
        
        // Locked out status
        service.recordFailedAttempt(userId);
        service.recordFailedAttempt(userId);
        status = service.getLockoutStatus(userId);
        expect(status.message, contains('Too many failed attempts'));
        expect(status.message, contains('Try again in'));
      });
    });

    group('Multi-User Support', () {
      test('should track attempts independently for different users', () {
        const user1 = 'user1';
        const user2 = 'user2';
        
        service.recordFailedAttempt(user1);
        service.recordFailedAttempt(user1);
        
        service.recordFailedAttempt(user2);
        
        expect(service.getFailedAttemptCount(user1), equals(2));
        expect(service.getFailedAttemptCount(user2), equals(1));
        expect(service.canAttemptVerification(user1), isTrue);
        expect(service.canAttemptVerification(user2), isTrue);
      });

      test('should lock out users independently', () {
        const user1 = 'user1';
        const user2 = 'user2';
        
        // Lock out user1
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(user1);
        }
        
        // user2 should still be able to attempt
        expect(service.isUserLockedOut(user1), isTrue);
        expect(service.isUserLockedOut(user2), isFalse);
        expect(service.canAttemptVerification(user1), isFalse);
        expect(service.canAttemptVerification(user2), isTrue);
      });

      test('should reset attempts independently for different users', () {
        const user1 = 'user1';
        const user2 = 'user2';
        
        service.recordFailedAttempt(user1);
        service.recordFailedAttempt(user2);
        service.recordFailedAttempt(user2);
        
        service.recordSuccessfulAttempt(user1);
        
        expect(service.getFailedAttemptCount(user1), equals(0));
        expect(service.getFailedAttemptCount(user2), equals(2));
      });
    });

    group('Manual Reset', () {
      test('should allow manual reset of user attempts', () {
        const userId = 'user1';
        
        service.recordFailedAttempt(userId);
        service.recordFailedAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(2));
        
        service.resetUserAttempts(userId);
        expect(service.getFailedAttemptCount(userId), equals(0));
        expect(service.canAttemptVerification(userId), isTrue);
      });

      test('should reset locked out users', () {
        const userId = 'user1';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          service.recordFailedAttempt(userId);
        }
        
        expect(service.isUserLockedOut(userId), isTrue);
        
        service.resetUserAttempts(userId);
        expect(service.isUserLockedOut(userId), isFalse);
        expect(service.canAttemptVerification(userId), isTrue);
        expect(service.getFailedAttemptCount(userId), equals(0));
      });

      test('should clear all attempts for all users', () {
        const user1 = 'user1';
        const user2 = 'user2';
        
        service.recordFailedAttempt(user1);
        service.recordFailedAttempt(user2);
        service.recordFailedAttempt(user2);
        
        service.clearAllAttempts();
        
        expect(service.getFailedAttemptCount(user1), equals(0));
        expect(service.getFailedAttemptCount(user2), equals(0));
        expect(service.canAttemptVerification(user1), isTrue);
        expect(service.canAttemptVerification(user2), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty user ID', () {
        expect(service.canAttemptVerification(''), isTrue);
        expect(service.getFailedAttemptCount(''), equals(0));
        
        service.recordFailedAttempt('');
        expect(service.getFailedAttemptCount(''), equals(1));
      });

      test('should handle null-like user IDs', () {
        const userId = 'null';
        
        expect(service.canAttemptVerification(userId), isTrue);
        service.recordFailedAttempt(userId);
        expect(service.getFailedAttemptCount(userId), equals(1));
      });

      test('should handle very long user IDs', () {
        final longUserId = 'a' * 1000;
        
        expect(service.canAttemptVerification(longUserId), isTrue);
        service.recordFailedAttempt(longUserId);
        expect(service.getFailedAttemptCount(longUserId), equals(1));
      });

      test('should handle rapid successive calls', () {
        const userId = 'user1';
        
        // Rapid failed attempts
        for (int i = 0; i < 10; i++) {
          service.recordFailedAttempt(userId);
        }
        
        // Should still be locked out with correct count
        expect(service.isUserLockedOut(userId), isTrue);
        expect(service.getFailedAttemptCount(userId), equals(10));
      });
    });

    group('AttemptTracker', () {
      test('should track individual attempt state correctly', () {
        final tracker = AttemptTracker();
        
        expect(tracker.isLockedOut, isFalse);
        expect(tracker.shouldLockOut, isFalse);
        expect(tracker.failedAttempts, equals(0));
        expect(tracker.remainingLockoutTime, equals(Duration.zero));
      });

      test('should lock out after max attempts', () {
        final tracker = AttemptTracker();
        
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          tracker.recordFailedAttempt();
        }
        
        expect(tracker.shouldLockOut, isTrue);
        expect(tracker.isLockedOut, isTrue);
        expect(tracker.failedAttempts, equals(3));
        expect(tracker.remainingLockoutTime.inSeconds, greaterThan(0));
      });

      test('should reset tracker state', () {
        final tracker = AttemptTracker();
        
        tracker.recordFailedAttempt();
        tracker.recordFailedAttempt();
        expect(tracker.failedAttempts, equals(2));
        
        tracker.reset();
        expect(tracker.failedAttempts, equals(0));
        expect(tracker.isLockedOut, isFalse);
        expect(tracker.remainingLockoutTime, equals(Duration.zero));
      });

      test('should format remaining time correctly', () {
        final tracker = AttemptTracker();
        
        // Lock out the tracker
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          tracker.recordFailedAttempt();
        }
        
        final formatted = tracker.remainingLockoutTimeFormatted;
        expect(formatted, matches(r'^\d+:\d{2}$')); // Format: M:SS
      });
    });

    group('LockoutStatus', () {
      test('should create normal status correctly', () {
        final status = LockoutStatus.normal();
        
        expect(status.state, equals(LockoutState.normal));
        expect(status.isNormal, isTrue);
        expect(status.hasWarning, isFalse);
        expect(status.isLockedOut, isFalse);
        expect(status.failedAttempts, equals(0));
        expect(status.messageType, equals(LockoutMessageType.info));
      });

      test('should create warning status correctly', () {
        final status = LockoutStatus.warning(
          failedAttempts: 2,
          attemptsRemaining: 1,
        );
        
        expect(status.state, equals(LockoutState.warning));
        expect(status.hasWarning, isTrue);
        expect(status.isLockedOut, isFalse);
        expect(status.failedAttempts, equals(2));
        expect(status.attemptsRemaining, equals(1));
        expect(status.messageType, equals(LockoutMessageType.warning));
      });

      test('should create locked out status correctly', () {
        final remainingTime = const Duration(minutes: 3, seconds: 30);
        final status = LockoutStatus.lockedOut(
          remainingTime: remainingTime,
          failedAttempts: 3,
        );
        
        expect(status.state, equals(LockoutState.lockedOut));
        expect(status.isLockedOut, isTrue);
        expect(status.hasWarning, isFalse);
        expect(status.failedAttempts, equals(3));
        expect(status.remainingTime, equals(remainingTime));
        expect(status.messageType, equals(LockoutMessageType.error));
      });
    });
  });
}