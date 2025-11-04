import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

void main() {
  group('Parental Control Security Integration Tests', () {
    late ConsentController controller;
    late AttemptLimitingService attemptService;

    setUp(() {
      controller = ConsentController();
      attemptService = AttemptLimitingService();
      attemptService.clearAllAttempts();
    });

    tearDown(() {
      attemptService.clearAllAttempts();
    });

    group('Complete Lockout Flow', () {
      test('should handle complete brute force attack scenario', () async {
        const userId = 'attacker-user';
        
        // Simulate brute force attack
        List<String> commonPasswords = [
          'password', '123456', 'admin', 'test', 'user',
          'parent', 'child', 'family', 'home', 'secure'
        ];
        
        int attemptCount = 0;
        bool isLockedOut = false;
        
        for (String password in commonPasswords) {
          if (attemptService.canAttemptVerification(userId)) {
            attemptService.recordFailedAttempt(userId);
            attemptCount++;
            
            if (attemptCount >= AttemptLimitingService.MAX_ATTEMPTS) {
              isLockedOut = true;
              break;
            }
          } else {
            break;
          }
        }
        
        // Verify lockout occurred after max attempts
        expect(isLockedOut, isTrue);
        expect(attemptService.isUserLockedOut(userId), isTrue);
        expect(attemptService.canAttemptVerification(userId), isFalse);
        expect(attemptService.getFailedAttemptCount(userId), equals(3));
        
        // Verify lockout duration
        final remainingTime = attemptService.getRemainingLockoutTime(userId);
        expect(remainingTime.inSeconds, greaterThan(0));
        expect(remainingTime.inSeconds, lessThanOrEqualTo(300));
      });

      test('should prevent verification during entire lockout period', () {
        const userId = 'locked-user';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        // Verify lockout state
        expect(attemptService.isUserLockedOut(userId), isTrue);
        
        // Multiple verification attempts should all be blocked
        for (int i = 0; i < 5; i++) {
          expect(attemptService.canAttemptVerification(userId), isFalse);
          
          // Even recording more failed attempts shouldn't change lockout state
          attemptService.recordFailedAttempt(userId);
          expect(attemptService.isUserLockedOut(userId), isTrue);
        }
      });

      test('should handle legitimate user mixed with attack attempts', () {
        const legitimateUser = 'legitimate-user';
        const attackerUser = 'attacker-user';
        
        // Legitimate user makes a few failed attempts
        attemptService.recordFailedAttempt(legitimateUser);
        attemptService.recordFailedAttempt(legitimateUser);
        
        // Attacker gets locked out
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(attackerUser);
        }
        
        // Legitimate user should still be able to attempt
        expect(attemptService.canAttemptVerification(legitimateUser), isTrue);
        expect(attemptService.getFailedAttemptCount(legitimateUser), equals(2));
        
        // Attacker should be locked out
        expect(attemptService.canAttemptVerification(attackerUser), isFalse);
        expect(attemptService.isUserLockedOut(attackerUser), isTrue);
        
        // Legitimate user succeeds
        attemptService.recordSuccessfulAttempt(legitimateUser);
        expect(attemptService.getFailedAttemptCount(legitimateUser), equals(0));
        
        // Attacker still locked out
        expect(attemptService.isUserLockedOut(attackerUser), isTrue);
      });
    });

    group('Progressive Security Warnings', () {
      test('should provide appropriate warnings at each attempt level', () {
        const userId = 'warning-user';
        
        // Initial state - normal
        var status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.normal));
        expect(status.message, contains('Enter your parental key'));
        
        // First failed attempt - warning
        attemptService.recordFailedAttempt(userId);
        status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.warning));
        expect(status.message, contains('Incorrect key'));
        expect(status.message, contains('2 attempts remaining'));
        expect(status.attemptsRemaining, equals(2));
        
        // Second failed attempt - final warning
        attemptService.recordFailedAttempt(userId);
        status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.warning));
        expect(status.message, contains('1 attempt remaining'));
        expect(status.attemptsRemaining, equals(1));
        
        // Third failed attempt - lockout
        attemptService.recordFailedAttempt(userId);
        status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.lockedOut));
        expect(status.message, contains('Too many failed attempts'));
        expect(status.message, contains('Try again in'));
        expect(status.remainingTime, isNotNull);
      });

      test('should handle warning escalation correctly', () {
        const userId = 'escalation-user';
        
        // Track message changes through escalation
        List<String> messages = [];
        List<LockoutState> states = [];
        
        // Initial state
        var status = attemptService.getLockoutStatus(userId);
        messages.add(status.message);
        states.add(status.state);
        
        // Record attempts and track changes
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
          status = attemptService.getLockoutStatus(userId);
          messages.add(status.message);
          states.add(status.state);
        }
        
        // Verify progression: normal -> warning -> warning -> locked
        expect(states[0], equals(LockoutState.normal));
        expect(states[1], equals(LockoutState.warning));
        expect(states[2], equals(LockoutState.warning));
        expect(states[3], equals(LockoutState.lockedOut));
        
        // Verify messages become more urgent
        expect(messages[0], contains('Enter your parental key'));
        expect(messages[1], contains('2 attempts remaining'));
        expect(messages[2], contains('1 attempt remaining'));
        expect(messages[3], contains('Too many failed attempts'));
      });
    });

    group('Recovery Scenarios', () {
      test('should handle successful recovery after warnings', () {
        const userId = 'recovery-user';
        
        // Build up to final warning
        attemptService.recordFailedAttempt(userId);
        attemptService.recordFailedAttempt(userId);
        
        var status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.warning));
        expect(status.attemptsRemaining, equals(1));
        
        // Successful attempt should reset everything
        attemptService.recordSuccessfulAttempt(userId);
        
        status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.normal));
        expect(status.failedAttempts, equals(0));
        expect(status.message, contains('Enter your parental key'));
      });

      test('should handle recovery from lockout state', () {
        const userId = 'lockout-recovery-user';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        expect(attemptService.isUserLockedOut(userId), isTrue);
        
        // Successful attempt should unlock immediately
        attemptService.recordSuccessfulAttempt(userId);
        
        expect(attemptService.isUserLockedOut(userId), isFalse);
        expect(attemptService.canAttemptVerification(userId), isTrue);
        expect(attemptService.getFailedAttemptCount(userId), equals(0));
        
        final status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.normal));
      });

      test('should handle administrative reset scenarios', () {
        const userId = 'admin-reset-user';
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        expect(attemptService.isUserLockedOut(userId), isTrue);
        
        // Administrative reset
        attemptService.resetUserAttempts(userId);
        
        expect(attemptService.isUserLockedOut(userId), isFalse);
        expect(attemptService.canAttemptVerification(userId), isTrue);
        expect(attemptService.getFailedAttemptCount(userId), equals(0));
        
        // User should be able to attempt verification immediately
        attemptService.recordFailedAttempt(userId);
        expect(attemptService.getFailedAttemptCount(userId), equals(1));
        expect(attemptService.canAttemptVerification(userId), isTrue);
      });
    });

    group('Concurrent User Scenarios', () {
      test('should handle multiple users with different security states', () {
        const user1 = 'user1';
        const user2 = 'user2';
        const user3 = 'user3';
        
        // User1: Normal state
        var status1 = attemptService.getLockoutStatus(user1);
        expect(status1.state, equals(LockoutState.normal));
        
        // User2: Warning state
        attemptService.recordFailedAttempt(user2);
        var status2 = attemptService.getLockoutStatus(user2);
        expect(status2.state, equals(LockoutState.warning));
        
        // User3: Locked out
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(user3);
        }
        var status3 = attemptService.getLockoutStatus(user3);
        expect(status3.state, equals(LockoutState.lockedOut));
        
        // Verify independent states
        expect(attemptService.canAttemptVerification(user1), isTrue);
        expect(attemptService.canAttemptVerification(user2), isTrue);
        expect(attemptService.canAttemptVerification(user3), isFalse);
        
        // User1 fails, should not affect others
        attemptService.recordFailedAttempt(user1);
        expect(attemptService.getFailedAttemptCount(user1), equals(1));
        expect(attemptService.getFailedAttemptCount(user2), equals(1));
        expect(attemptService.getFailedAttemptCount(user3), equals(3));
        
        // User2 succeeds, should not affect others
        attemptService.recordSuccessfulAttempt(user2);
        expect(attemptService.getFailedAttemptCount(user1), equals(1));
        expect(attemptService.getFailedAttemptCount(user2), equals(0));
        expect(attemptService.getFailedAttemptCount(user3), equals(3));
        expect(attemptService.isUserLockedOut(user3), isTrue);
      });

      test('should handle rapid concurrent attempts from same user', () {
        const userId = 'concurrent-user';
        
        // Simulate rapid concurrent failed attempts
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(Future(() {
            attemptService.recordFailedAttempt(userId);
          }));
        }
        
        // Wait for all concurrent operations
        Future.wait(futures);
        
        // Should maintain consistent state
        expect(attemptService.getFailedAttemptCount(userId), equals(10));
        expect(attemptService.isUserLockedOut(userId), isTrue);
        expect(attemptService.canAttemptVerification(userId), isFalse);
        
        // Lockout should still be enforced
        final status = attemptService.getLockoutStatus(userId);
        expect(status.state, equals(LockoutState.lockedOut));
        expect(status.remainingTime, isNotNull);
      });
    });

    group('Edge Case Security Scenarios', () {
      test('should handle system restart simulation', () {
        const userId = 'restart-user';
        
        // Build up failed attempts
        attemptService.recordFailedAttempt(userId);
        attemptService.recordFailedAttempt(userId);
        expect(attemptService.getFailedAttemptCount(userId), equals(2));
        
        // Simulate system restart by creating new service instance
        final newService = AttemptLimitingService(); // Singleton, same instance
        
        // State should be maintained (in real app, this would depend on persistence)
        expect(newService.getFailedAttemptCount(userId), equals(2));
        expect(newService.canAttemptVerification(userId), isTrue);
        
        // Continue with attempts
        newService.recordFailedAttempt(userId);
        expect(newService.isUserLockedOut(userId), isTrue);
      });

      test('should handle memory cleanup scenarios', () {
        // Create many users to test memory management
        for (int i = 0; i < 100; i++) {
          final userId = 'user$i';
          attemptService.recordFailedAttempt(userId);
          
          if (i % 10 == 0) {
            // Some users succeed to create mixed state
            attemptService.recordSuccessfulAttempt(userId);
          }
        }
        
        // Service should still function correctly
        const testUser = 'test-cleanup-user';
        expect(attemptService.canAttemptVerification(testUser), isTrue);
        
        attemptService.recordFailedAttempt(testUser);
        expect(attemptService.getFailedAttemptCount(testUser), equals(1));
        
        // Clear all should work
        attemptService.clearAllAttempts();
        expect(attemptService.getFailedAttemptCount(testUser), equals(0));
      });

      test('should handle extreme lockout scenarios', () {
        const userId = 'extreme-user';
        
        // Record many failed attempts beyond lockout
        for (int i = 0; i < 50; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        // Should still maintain correct lockout state
        expect(attemptService.isUserLockedOut(userId), isTrue);
        expect(attemptService.canAttemptVerification(userId), isFalse);
        expect(attemptService.getFailedAttemptCount(userId), equals(50));
        
        // Recovery should still work
        attemptService.recordSuccessfulAttempt(userId);
        expect(attemptService.isUserLockedOut(userId), isFalse);
        expect(attemptService.getFailedAttemptCount(userId), equals(0));
      });
    });

    group('Security Metrics and Monitoring', () {
      test('should provide comprehensive security metrics', () {
        const user1 = 'metrics-user1';
        const user2 = 'metrics-user2';
        
        // Create different security states
        attemptService.recordFailedAttempt(user1);
        
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(user2);
        }
        
        // Verify individual user metrics
        final status1 = attemptService.getLockoutStatus(user1);
        final status2 = attemptService.getLockoutStatus(user2);
        
        expect(status1.failedAttempts, equals(1));
        expect(status1.attemptsRemaining, equals(2));
        expect(status1.state, equals(LockoutState.warning));
        
        expect(status2.failedAttempts, equals(3));
        expect(status2.attemptsRemaining, isNull);
        expect(status2.state, equals(LockoutState.lockedOut));
        expect(status2.remainingTime, isNotNull);
      });

      test('should track security events over time', () {
        const userId = 'tracking-user';
        
        // Simulate security events over time
        List<LockoutState> stateHistory = [];
        
        // Initial state
        stateHistory.add(attemptService.getLockoutStatus(userId).state);
        
        // Failed attempts
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
          stateHistory.add(attemptService.getLockoutStatus(userId).state);
        }
        
        // Recovery
        attemptService.recordSuccessfulAttempt(userId);
        stateHistory.add(attemptService.getLockoutStatus(userId).state);
        
        // Verify state progression
        expect(stateHistory, equals([
          LockoutState.normal,    // Initial
          LockoutState.warning,   // 1 failed
          LockoutState.warning,   // 2 failed
          LockoutState.lockedOut, // 3 failed (locked)
          LockoutState.normal,    // Recovery
        ]));
      });
    });
  });
}