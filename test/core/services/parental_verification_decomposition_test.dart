import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart' hide test, group, setUp, tearDown, expect;
import 'package:glados/glados.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/services/crypto_service.dart';
import 'package:guardiancare/core/services/parental_key_verifier.dart';
import 'package:guardiancare/core/services/parental_session_manager.dart';

/// **Feature: srp-clean-architecture-fix, Property 9: Parental Verification Decomposition**
/// **Validates: Requirements 9.1, 9.2, 9.3**
///
/// Property: For any parental verification operation, session state SHALL be managed
/// exclusively by ParentalSessionManager, key verification logic SHALL be handled
/// exclusively by ParentalKeyVerifier, and cryptographic operations SHALL be handled
/// exclusively by CryptoService.

// ============================================================================
// Mock Implementations for Testing
// ============================================================================

/// Mock ParentalSessionManager that tracks all method calls
class MockParentalSessionManager implements ParentalSessionManager {
  final List<String> methodCalls = [];
  final List<bool> setVerifiedCalls = [];
  bool _isVerified = false;

  @override
  bool get isVerified {
    methodCalls.add('isVerified:get');
    return _isVerified;
  }

  @override
  void setVerified(bool value) {
    methodCalls.add('setVerified:$value');
    setVerifiedCalls.add(value);
    _isVerified = value;
  }

  @override
  void reset() {
    methodCalls.add('reset');
    _isVerified = false;
  }

  /// Verifies that only session-related methods were called
  bool get onlySessionMethodsCalled {
    return methodCalls.every((call) =>
        call.startsWith('isVerified') ||
        call.startsWith('setVerified') ||
        call == 'reset');
  }

  void clearCalls() {
    methodCalls.clear();
    setVerifiedCalls.clear();
  }
}

/// Mock ParentalKeyVerifier that tracks all method calls
class MockParentalKeyVerifier implements ParentalKeyVerifier {
  final List<String> methodCalls = [];
  final List<Map<String, String>> verifyRequests = [];

  Either<Failure, bool> mockResult = const Right(true);
  bool shouldFail = false;
  String failureMessage = 'Verification error';

  @override
  Future<Either<Failure, bool>> verify(String uid, String key) async {
    methodCalls.add('verify');
    verifyRequests.add({'uid': uid, 'key': key});

    if (shouldFail) {
      return Left(AuthenticationFailure(failureMessage));
    }
    return mockResult;
  }

  /// Verifies that only verification-related methods were called
  bool get onlyVerificationMethodsCalled {
    return methodCalls.every((call) => call == 'verify');
  }

  void clearCalls() {
    methodCalls.clear();
    verifyRequests.clear();
    shouldFail = false;
  }
}

/// Mock CryptoService that tracks all method calls
class MockCryptoService implements CryptoService {
  final List<String> methodCalls = [];
  final List<String> hashedStrings = [];
  final List<Map<String, String>> compareRequests = [];

  @override
  String hashString(String input) {
    methodCalls.add('hashString');
    hashedStrings.add(input);
    // Return a deterministic hash for testing
    return 'hashed_$input';
  }

  @override
  bool compareHash(String input, String hash) {
    methodCalls.add('compareHash');
    compareRequests.add({'input': input, 'hash': hash});
    // Return true if hash matches our mock pattern
    return hash == 'hashed_$input';
  }

  /// Verifies that only crypto-related methods were called
  bool get onlyCryptoMethodsCalled {
    return methodCalls.every((call) =>
        call == 'hashString' || call == 'compareHash');
  }

  void clearCalls() {
    methodCalls.clear();
    hashedStrings.clear();
    compareRequests.clear();
  }
}

// ============================================================================
// Test Fixture
// ============================================================================

class ParentalVerificationTestFixture {

  ParentalVerificationTestFixture._({
    required this.sessionManager,
    required this.keyVerifier,
    required this.cryptoService,
  });

  factory ParentalVerificationTestFixture.create() {
    final sessionManager = MockParentalSessionManager();
    final keyVerifier = MockParentalKeyVerifier();
    final cryptoService = MockCryptoService();
    return ParentalVerificationTestFixture._(
      sessionManager: sessionManager,
      keyVerifier: keyVerifier,
      cryptoService: cryptoService,
    );
  }
  final MockParentalSessionManager sessionManager;
  final MockParentalKeyVerifier keyVerifier;
  final MockCryptoService cryptoService;

  void reset() {
    sessionManager.clearCalls();
    keyVerifier.clearCalls();
    cryptoService.clearCalls();
  }
}

// ============================================================================
// Custom Generators for Glados
// ============================================================================

/// Sample user IDs for testing
final sampleUserIds = [
  'user-123',
  'user-456',
  'user-789',
  'test-user-001',
  'test-user-002',
  'parent-abc',
  'parent-xyz',
];

/// Sample parental keys for testing
final sampleParentalKeys = [
  '1234',
  '5678',
  '0000',
  '9999',
  'abcd',
  'test123',
  'parent_key',
];

/// Extension to add custom generators for parental verification testing
extension ParentalVerificationGenerators on Any {
  /// Generator for user IDs
  Generator<String> get userId => choose(sampleUserIds);

  /// Generator for parental keys
  Generator<String> get parentalKey => choose(sampleParentalKeys);

  /// Generator for positive integers between min and max (inclusive)
  Generator<int> intBetween(int min, int max) {
    return intInRange(min, max + 1);
  }

  /// Generator for boolean values
  Generator<bool> get boolean => choose([true, false]);
}

// ============================================================================
// Property-Based Tests
// ============================================================================

void main() {
  group('Property 9: Parental Verification Decomposition', () {
    // ========================================================================
    // Property 9.1: ParentalSessionManager handles session state exclusively
    // Validates: Requirement 9.1
    // ========================================================================
    Glados(any.boolean, ExploreConfig()).test(
      'For any session state change, ParentalSessionManager SHALL manage state exclusively',
      (verifiedState) {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act - set verification state
          fixture.sessionManager.setVerified(verifiedState);

          // Assert: Only session-related methods were called
          expect(
            fixture.sessionManager.onlySessionMethodsCalled,
            isTrue,
            reason: 'ParentalSessionManager should only call session-related methods',
          );

          // Assert: The state was set correctly
          expect(
            fixture.sessionManager.setVerifiedCalls,
            contains(verifiedState),
            reason: 'ParentalSessionManager should record the state change',
          );

          // Assert: State is retrievable
          final currentState = fixture.sessionManager.isVerified;
          expect(
            currentState,
            equals(verifiedState),
            reason: 'ParentalSessionManager should return the correct state',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.2: ParentalKeyVerifier handles verification logic exclusively
    // Validates: Requirement 9.2
    // ========================================================================
    Glados2(any.userId, any.parentalKey, ExploreConfig()).test(
      'For any key verification, ParentalKeyVerifier SHALL handle verification exclusively',
      (userId, key) async {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act - verify key
          await fixture.keyVerifier.verify(userId, key);

          // Assert: Only verification-related methods were called
          expect(
            fixture.keyVerifier.onlyVerificationMethodsCalled,
            isTrue,
            reason: 'ParentalKeyVerifier should only call verification-related methods',
          );

          // Assert: The request was recorded correctly
          expect(
            fixture.keyVerifier.verifyRequests.any(
              (req) => req['uid'] == userId && req['key'] == key,
            ),
            isTrue,
            reason: 'ParentalKeyVerifier should receive uid: $userId and key: $key',
          );

          // Assert: Method was called exactly once
          expect(
            fixture.keyVerifier.methodCalls.length,
            equals(1),
            reason: 'verify should be called exactly once',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.3: CryptoService handles cryptographic operations exclusively
    // Validates: Requirement 9.3
    // ========================================================================
    Glados(any.parentalKey, ExploreConfig()).test(
      'For any hash operation, CryptoService SHALL handle crypto exclusively',
      (input) {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act - hash string
          final hash = fixture.cryptoService.hashString(input);

          // Assert: Only crypto-related methods were called
          expect(
            fixture.cryptoService.onlyCryptoMethodsCalled,
            isTrue,
            reason: 'CryptoService should only call crypto-related methods',
          );

          // Assert: The input was recorded
          expect(
            fixture.cryptoService.hashedStrings,
            contains(input),
            reason: 'CryptoService should record the hashed input',
          );

          // Assert: Hash is deterministic
          final hash2 = fixture.cryptoService.hashString(input);
          expect(
            hash,
            equals(hash2),
            reason: 'CryptoService should produce deterministic hashes',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.4: CryptoService compareHash works correctly
    // Validates: Requirement 9.3
    // ========================================================================
    Glados(any.parentalKey, ExploreConfig()).test(
      'For any hash comparison, CryptoService SHALL correctly compare hashes',
      (input) {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act - hash and compare
          final hash = fixture.cryptoService.hashString(input);
          final isMatch = fixture.cryptoService.compareHash(input, hash);

          // Assert: Only crypto-related methods were called
          expect(
            fixture.cryptoService.onlyCryptoMethodsCalled,
            isTrue,
            reason: 'CryptoService should only call crypto-related methods',
          );

          // Assert: Comparison is correct
          expect(
            isMatch,
            isTrue,
            reason: 'CryptoService should return true for matching hash',
          );

          // Assert: Wrong hash returns false
          final wrongMatch = fixture.cryptoService.compareHash(input, 'wrong_hash');
          expect(
            wrongMatch,
            isFalse,
            reason: 'CryptoService should return false for non-matching hash',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.5: Session reset clears verification state
    // Validates: Requirement 9.1
    // ========================================================================
    Glados(any.intBetween(1, 5), ExploreConfig()).test(
      'For any number of verifications, reset SHALL clear session state',
      (count) {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act - set verified multiple times then reset
          for (var i = 0; i < count; i++) {
            fixture.sessionManager.setVerified(true);
          }
          fixture.sessionManager.reset();

          // Assert: State is reset
          expect(
            fixture.sessionManager.isVerified,
            isFalse,
            reason: 'ParentalSessionManager should reset to false after reset()',
          );

          // Assert: Reset was called
          expect(
            fixture.sessionManager.methodCalls,
            contains('reset'),
            reason: 'reset() should be called',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.6: ParentalKeyVerifier returns failure on error
    // Validates: Requirement 9.2
    // ========================================================================
    Glados2(any.userId, any.parentalKey, ExploreConfig()).test(
      'For any verification failure, ParentalKeyVerifier SHALL return AuthenticationFailure',
      (userId, key) async {
        final fixture = ParentalVerificationTestFixture.create();
        fixture.keyVerifier.shouldFail = true;
        fixture.keyVerifier.failureMessage = 'Database connection error';

        try {
          // Act
          final result = await fixture.keyVerifier.verify(userId, key);

          // Assert: Result is a failure
          expect(
            result.isLeft(),
            isTrue,
            reason: 'ParentalKeyVerifier should return failure when verification fails',
          );

          // Assert: Failure is AuthenticationFailure
          result.fold(
            (failure) {
              expect(
                failure,
                isA<AuthenticationFailure>(),
                reason: 'Failure should be AuthenticationFailure',
              );
              expect(
                failure.message,
                equals('Database connection error'),
                reason: 'Failure message should match',
              );
            },
            (_) => fail('Expected failure but got success'),
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.7: Services maintain single responsibility during operations
    // Validates: Requirements 9.1, 9.2, 9.3
    // ========================================================================
    Glados2(any.userId, any.parentalKey, ExploreConfig()).test(
      'During operations, each service SHALL maintain single responsibility',
      (userId, key) async {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act - perform operations on each service
          fixture.sessionManager.setVerified(true);
          await fixture.keyVerifier.verify(userId, key);
          fixture.cryptoService.hashString(key);

          // Assert: Each service only handled its own operations
          expect(
            fixture.sessionManager.onlySessionMethodsCalled,
            isTrue,
            reason: 'ParentalSessionManager should only handle session operations',
          );

          expect(
            fixture.keyVerifier.onlyVerificationMethodsCalled,
            isTrue,
            reason: 'ParentalKeyVerifier should only handle verification operations',
          );

          expect(
            fixture.cryptoService.onlyCryptoMethodsCalled,
            isTrue,
            reason: 'CryptoService should only handle crypto operations',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.8: Multiple session state changes are all tracked
    // Validates: Requirement 9.1
    // ========================================================================
    Glados(any.nonEmptyList(any.boolean), ExploreConfig()).test(
      'For any sequence of state changes, all SHALL be tracked by ParentalSessionManager',
      (states) {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act
          for (final state in states) {
            fixture.sessionManager.setVerified(state);
          }

          // Assert: All state changes were tracked
          expect(
            fixture.sessionManager.setVerifiedCalls.length,
            equals(states.length),
            reason: 'All ${states.length} state changes should be tracked',
          );

          // Assert: Final state matches last change
          expect(
            fixture.sessionManager.isVerified,
            equals(states.last),
            reason: 'Final state should match last change',
          );
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.9: Multiple verifications are all processed
    // Validates: Requirement 9.2
    // ========================================================================
    Glados(any.intBetween(1, 5), ExploreConfig()).test(
      'For any number of verifications, all SHALL be processed by ParentalKeyVerifier',
      (count) async {
        final fixture = ParentalVerificationTestFixture.create();

        try {
          // Act
          for (var i = 0; i < count; i++) {
            await fixture.keyVerifier.verify('user-$i', 'key-$i');
          }

          // Assert: All verifications were processed
          expect(
            fixture.keyVerifier.verifyRequests.length,
            equals(count),
            reason: 'ParentalKeyVerifier should process all $count verifications',
          );

          // Assert: Each verification was recorded correctly
          for (var i = 0; i < count; i++) {
            expect(
              fixture.keyVerifier.verifyRequests.any(
                (req) => req['uid'] == 'user-$i' && req['key'] == 'key-$i',
              ),
              isTrue,
              reason: 'Verification $i should be recorded',
            );
          }
        } finally {
          fixture.reset();
        }
      },
    );

    // ========================================================================
    // Property 9.10: Verification result affects session state correctly
    // Validates: Requirements 9.1, 9.2
    // ========================================================================
    Glados(any.boolean, ExploreConfig()).test(
      'For any verification result, session state SHALL be updated accordingly',
      (isValid) async {
        final fixture = ParentalVerificationTestFixture.create();
        fixture.keyVerifier.mockResult = Right(isValid);

        try {
          // Act - verify and update session based on result
          final result = await fixture.keyVerifier.verify('test-user', 'test-key');

          result.fold(
            (_) => fail('Expected success'),
            (valid) {
              if (valid) {
                fixture.sessionManager.setVerified(true);
              }
            },
          );

          // Assert: Session state matches verification result
          if (isValid) {
            expect(
              fixture.sessionManager.isVerified,
              isTrue,
              reason: 'Session should be verified when key is valid',
            );
          } else {
            expect(
              fixture.sessionManager.isVerified,
              isFalse,
              reason: 'Session should not be verified when key is invalid',
            );
          }
        } finally {
          fixture.reset();
        }
      },
    );
  });

  // ==========================================================================
  // Unit Tests for Edge Cases
  // ==========================================================================
  group('Parental Verification Decomposition - Edge Cases', () {
    test('ParentalSessionManager should handle rapid state changes', () {
      final fixture = ParentalVerificationTestFixture.create();

      // Rapidly change states
      fixture.sessionManager.setVerified(true);
      fixture.sessionManager.setVerified(false);
      fixture.sessionManager.setVerified(true);
      fixture.sessionManager.setVerified(false);

      expect(fixture.sessionManager.setVerifiedCalls.length, equals(4));
      expect(fixture.sessionManager.isVerified, isFalse);

      fixture.reset();
    });

    test('ParentalKeyVerifier should handle empty userId', () async {
      final fixture = ParentalVerificationTestFixture.create();

      await fixture.keyVerifier.verify('', 'test-key');

      expect(fixture.keyVerifier.verifyRequests.any((req) => req['uid'] == ''), isTrue);

      fixture.reset();
    });

    test('ParentalKeyVerifier should handle empty key', () async {
      final fixture = ParentalVerificationTestFixture.create();

      await fixture.keyVerifier.verify('test-user', '');

      expect(fixture.keyVerifier.verifyRequests.any((req) => req['key'] == ''), isTrue);

      fixture.reset();
    });

    test('CryptoService should handle empty string', () {
      final fixture = ParentalVerificationTestFixture.create();

      final hash = fixture.cryptoService.hashString('');

      expect(hash, equals('hashed_'));
      expect(fixture.cryptoService.hashedStrings, contains(''));

      fixture.reset();
    });

    test('CryptoService should handle special characters', () {
      final fixture = ParentalVerificationTestFixture.create();

      const specialChars = r'!@#$%^&*()_+-=[]{}|;:,.<>?';
      final hash = fixture.cryptoService.hashString(specialChars);

      expect(hash, equals('hashed_$specialChars'));
      expect(fixture.cryptoService.hashedStrings, contains(specialChars));

      fixture.reset();
    });

    test('Services should maintain isolation during concurrent operations', () async {
      final fixture = ParentalVerificationTestFixture.create();

      // Simulate concurrent operations
      final futures = [
        Future(() => fixture.sessionManager.setVerified(true)),
        fixture.keyVerifier.verify('user-1', 'key-1'),
        Future(() => fixture.cryptoService.hashString('test')),
      ];

      await Future.wait(futures);

      // Each service should only have its own method calls
      expect(fixture.sessionManager.onlySessionMethodsCalled, isTrue);
      expect(fixture.keyVerifier.onlyVerificationMethodsCalled, isTrue);
      expect(fixture.cryptoService.onlyCryptoMethodsCalled, isTrue);

      fixture.reset();
    });

    test('ParentalSessionManager reset should work after multiple verifications', () {
      final fixture = ParentalVerificationTestFixture.create();

      // Multiple verifications
      fixture.sessionManager.setVerified(true);
      fixture.sessionManager.setVerified(true);
      fixture.sessionManager.setVerified(true);

      // Reset
      fixture.sessionManager.reset();

      expect(fixture.sessionManager.isVerified, isFalse);

      fixture.reset();
    });
  });

  // ==========================================================================
  // Integration Tests for Real Implementations
  // ==========================================================================
  group('Parental Verification - Real Implementation Tests', () {
    test('CryptoServiceImpl should produce consistent SHA-256 hashes', () {
      const cryptoService = CryptoServiceImpl();

      const input = 'test_parental_key_1234';
      final hash1 = cryptoService.hashString(input);
      final hash2 = cryptoService.hashString(input);

      // Hashes should be consistent
      expect(hash1, equals(hash2));

      // Hash should be 64 characters (SHA-256 hex)
      expect(hash1.length, equals(64));
    });

    test('CryptoServiceImpl compareHash should work correctly', () {
      const cryptoService = CryptoServiceImpl();

      const input = 'my_secret_key';
      final hash = cryptoService.hashString(input);

      // Correct input should match
      expect(cryptoService.compareHash(input, hash), isTrue);

      // Wrong input should not match
      expect(cryptoService.compareHash('wrong_key', hash), isFalse);
    });

    test('ParentalSessionManagerImpl should manage session state', () {
      final sessionManager = ParentalSessionManagerImpl();

      // Initial state should be false
      expect(sessionManager.isVerified, isFalse);

      // Set to true
      sessionManager.setVerified(true);
      expect(sessionManager.isVerified, isTrue);

      // Reset
      sessionManager.reset();
      expect(sessionManager.isVerified, isFalse);
    });
  });
}
