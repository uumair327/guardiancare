import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

void main() {
  group('AttemptLimitingService Tests', () {
    late AttemptLimitingService service;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      service = AttemptLimitingService.instance;
      await service.initialize();
      await service.resetAllData(); // Ensure clean state
    });

    tearDown(() async {
      await service.resetAllData();
    });

    group('Initialization and Configuration', () {
      test('should have correct default configuration', () {
        expect(AttemptLimitingService.maxAttempts, equals(3));
        expect(AttemptLimitingService.lockoutDurationMinutes, equals(5));
      });

      test('should initialize successfully', () async {
        expect(() => service.initialize(), returnsNormally);
      });
    });

    group('Failed Attempt Tracking', () {
      test('should start with zero failed attempts', () async {
        final failedAttempts = await service.getFailedAttempts();
        expect(failedAttempts, equals(0));
      });

      test('should increment failed attempts correctly', () async {
        await service.recordFailedAttempt();
        expect(await service.getFailedAttempts(), equals(1));

        await service.recordFailedAttempt();
        expect(await service.getFailedAttempts(), equals(2));
      });

      test('should calculate remaining attempts correctly', () async {
        expect(await service.getRemainingAttempts(), equals(3));

        await service.recordFailedAttempt();
        expect(await service.getRemainingAttempts(), equals(2));

        await service.recordFailedAttempt();
        expect(await service.getRemainingAttempts(), equals(1));

        await service.recordFailedAttempt();
        expect(await service.getRemainingAttempts(), equals(0));
      });

      test('should return correct attempt result for failed attempts', () async {
        final result1 = await service.recordFailedAttempt();
        expect(result1.success, isFalse);
        expect(result1.isLockedOut, isFalse);
        expect(result1.remainingAttempts, equals(2));
        expect(result1.message, contains('2 attempts remaining'));

        final result2 = await service.recordFailedAttempt();
        expect(result2.success, isFalse);
        expect(result2.isLockedOut, isFalse);
        expect(result2.remainingAttempts, equals(1));
        expect(result2.message, contains('1 attempt remaining'));
      });
    });

    group('Lockout Mechanism', () {
      test('should trigger lockout after max attempts', () async {
        // First two attempts should not trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        expect(await service.isLockedOut(), isFalse);

        // Third attempt should trigger lockout
        final result = await service.recordFailedAttempt();
        expect(result.success, isFalse);
        expect(result.isLockedOut, isTrue);
        expect(result.remainingAttempts, equals(0));
        expect(result.message, contains('locked'));
        expect(await service.isLockedOut(), isTrue);
      });

      test('should prevent attempts when locked out', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        // Further attempts should be blocked
        final result = await service.recordFailedAttempt();
        expect(result.success, isFalse);
        expect(result.isLockedOut, isTrue);
        expect(result.message, contains('locked'));
      });

      test('should calculate remaining lockout time correctly', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        final remainingTime = await service.getRemainingLockoutTime();
        expect(remainingTime, greaterThan(0));
        expect(remainingTime, lessThanOrEqualTo(5 * 60)); // 5 minutes in seconds
      });

      test('should format remaining lockout time correctly', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        final formattedTime = await service.getRemainingLockoutTimeFormatted();
        expect(formattedTime, matches(RegExp(r'^\d{2}:\d{2}$'))); // MM:SS format
      });

      test('should clear lockout after expiry', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        expect(await service.isLockedOut(), isTrue);

        // Manually set lockout time to past (simulate expiry)
        final pastTime = DateTime.now().subtract(const Duration(minutes: 6));
        await service.setLockoutTime(pastTime);

        // Should no longer be locked out
        expect(await service.isLockedOut(), isFalse);
        expect(await service.getRemainingLockoutTime(), equals(0));
      });
    });

    group('Successful Attempt Handling', () {
      test('should clear attempts on successful verification', () async {
        // Record some failed attempts
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        expect(await service.getFailedAttempts(), equals(2));

        // Record successful attempt
        final result = await service.recordSuccessfulAttempt();
        expect(result.success, isTrue);
        expect(result.isLockedOut, isFalse);
        expect(result.remainingAttempts, equals(3));
        expect(result.message, contains('successfully'));

        // Failed attempts should be cleared
        expect(await service.getFailedAttempts(), equals(0));
        expect(await service.getRemainingAttempts(), equals(3));
      });

      test('should clear lockout on successful verification', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        expect(await service.isLockedOut(), isTrue);

        // Record successful attempt (should clear lockout)
        await service.recordSuccessfulAttempt();
        expect(await service.isLockedOut(), isFalse);
        expect(await service.getFailedAttempts(), equals(0));
      });
    });

    group('Attempt Status', () {
      test('should provide correct attempt status for clean state', () async {
        final status = await service.getAttemptStatus();
        expect(status.isLockedOut, isFalse);
        expect(status.failedAttempts, equals(0));
        expect(status.remainingAttempts, equals(3));
        expect(status.remainingLockoutTime, equals(0));
        expect(status.canAttempt, isTrue);
        expect(status.maxAttempts, equals(3));
        expect(status.lockoutDurationMinutes, equals(5));
      });

      test('should provide correct attempt status with failed attempts', () async {
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        final status = await service.getAttemptStatus();
        expect(status.isLockedOut, isFalse);
        expect(status.failedAttempts, equals(2));
        expect(status.remainingAttempts, equals(1));
        expect(status.remainingLockoutTime, equals(0));
        expect(status.canAttempt, isTrue);
      });

      test('should provide correct attempt status when locked out', () async {
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        final status = await service.getAttemptStatus();
        expect(status.isLockedOut, isTrue);
        expect(status.failedAttempts, equals(3));
        expect(status.remainingAttempts, equals(0));
        expect(status.remainingLockoutTime, greaterThan(0));
        expect(status.canAttempt, isFalse);
      });
    });

    group('Data Persistence', () {
      test('should persist failed attempts across service instances', () async {
        // Record attempts with first instance
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        // Create new instance and check persistence
        final newService = AttemptLimitingService.instance;
        await newService.initialize();
        expect(await newService.getFailedAttempts(), equals(2));
      });

      test('should persist lockout state across service instances', () async {
        // Trigger lockout with first instance
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        // Create new instance and check lockout persistence
        final newService = AttemptLimitingService.instance;
        await newService.initialize();
        expect(await newService.isLockedOut(), isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle can attempt check correctly', () async {
        expect(await service.canAttempt(), isTrue);

        // After lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        expect(await service.canAttempt(), isFalse);
      });

      test('should handle reset all data correctly', () async {
        // Set up some state
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        expect(await service.isLockedOut(), isTrue);

        // Reset all data
        await service.resetAllData();

        // Should be back to clean state
        expect(await service.getFailedAttempts(), equals(0));
        expect(await service.isLockedOut(), isFalse);
        expect(await service.canAttempt(), isTrue);
      });

      test('should handle multiple rapid attempts correctly', () async {
        // Simulate rapid attempts
        final futures = <Future<AttemptResult>>[];
        for (int i = 0; i < 5; i++) {
          futures.add(service.recordFailedAttempt());
        }

        final results = await Future.wait(futures);
        
        // Should still respect max attempts limit
        expect(await service.getFailedAttempts(), greaterThanOrEqualTo(3));
        expect(await service.isLockedOut(), isTrue);
      });

      test('should handle time manipulation for testing', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        // Manually set lockout time to future (extend lockout)
        final futureTime = DateTime.now().add(const Duration(minutes: 10));
        await service.setLockoutTime(futureTime);

        expect(await service.isLockedOut(), isTrue);
        final remainingTime = await service.getRemainingLockoutTime();
        expect(remainingTime, greaterThan(5 * 60)); // More than 5 minutes
      });

      test('should handle manual attempt count setting for testing', () async {
        await service.setFailedAttempts(2);
        expect(await service.getFailedAttempts(), equals(2));
        expect(await service.getRemainingAttempts(), equals(1));
      });
    });

    group('Lockout Time Formatting', () {
      test('should format zero time correctly', () async {
        final formatted = await service.getRemainingLockoutTimeFormatted();
        expect(formatted, equals('00:00'));
      });

      test('should format time correctly when locked out', () async {
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        final formatted = await service.getRemainingLockoutTimeFormatted();
        expect(formatted, matches(RegExp(r'^\d{2}:\d{2}$')));
        expect(formatted, isNot(equals('00:00')));
      });
    });

    group('Singleton Behavior', () {
      test('should return same instance', () {
        final instance1 = AttemptLimitingService.instance;
        final instance2 = AttemptLimitingService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Stress Testing', () {
      test('should handle many failed attempts correctly', () async {
        // Record many failed attempts
        for (int i = 0; i < 10; i++) {
          await service.recordFailedAttempt();
        }

        // Should still be locked out with correct count
        expect(await service.isLockedOut(), isTrue);
        expect(await service.getFailedAttempts(), greaterThanOrEqualTo(3));
      });

      test('should handle alternating success and failure', () async {
        // Alternate between success and failure
        await service.recordFailedAttempt();
        await service.recordSuccessfulAttempt();
        expect(await service.getFailedAttempts(), equals(0));

        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordSuccessfulAttempt();
        expect(await service.getFailedAttempts(), equals(0));
        expect(await service.isLockedOut(), isFalse);
      });
    });
  });
}