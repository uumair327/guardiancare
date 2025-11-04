import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  DocumentReference,
  DocumentSnapshot,
  CollectionReference,
])
import 'consent_controller_security_test.mocks.dart';

void main() {
  group('ConsentController Security Tests', () {
    late ConsentController controller;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockDocumentReference mockDocRef;
    late MockDocumentSnapshot mockDocSnapshot;
    late MockCollectionReference mockCollection;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockDocRef = MockDocumentReference();
      mockDocSnapshot = MockDocumentSnapshot();
      mockCollection = MockCollectionReference();

      // Setup basic mocks
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockFirestore.collection('consents')).thenReturn(mockCollection);
      when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);

      controller = ConsentController();
      
      // Clear any existing attempts
      AttemptLimitingService().clearAllAttempts();
    });

    tearDown(() {
      AttemptLimitingService().clearAllAttempts();
    });

    group('Parental Key Verification Security', () {
      test('should prevent verification when user is locked out', () async {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Lock out the user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        expect(controller.canCurrentUserAttemptVerification(), isFalse);
        expect(controller.isCurrentUserLockedOut(), isTrue);
      });

      test('should track failed attempts correctly', () async {
        const userId = 'test-user-id';
        
        // Setup mock for failed verification
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.get('parentalKey')).thenReturn('hashed-wrong-key');
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        
        // First failed attempt
        final result1 = await controller.verifyParentalKeySecure('wrong-key');
        expect(result1.success, isFalse);
        expect(result1.errorType, equals(ParentalVerificationErrorType.incorrectKey));
        expect(controller.getCurrentUserFailedAttempts(), equals(1));
        
        // Second failed attempt
        final result2 = await controller.verifyParentalKeySecure('wrong-key');
        expect(result2.success, isFalse);
        expect(controller.getCurrentUserFailedAttempts(), equals(2));
        
        // Third failed attempt should lock out
        final result3 = await controller.verifyParentalKeySecure('wrong-key');
        expect(result3.success, isFalse);
        expect(result3.errorType, equals(ParentalVerificationErrorType.lockedOut));
        expect(controller.getCurrentUserFailedAttempts(), equals(3));
        expect(controller.isCurrentUserLockedOut(), isTrue);
      });

      test('should reset attempts on successful verification', () async {
        const userId = 'test-user-id';
        
        // Setup mock for mixed verification results
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        
        // First, record some failed attempts
        when(mockDocSnapshot.get('parentalKey')).thenReturn('hashed-wrong-key');
        await controller.verifyParentalKeySecure('wrong-key');
        await controller.verifyParentalKeySecure('wrong-key');
        expect(controller.getCurrentUserFailedAttempts(), equals(2));
        
        // Then succeed
        when(mockDocSnapshot.get('parentalKey')).thenReturn(
          controller.hashParentalKey('correct-key')
        );
        final result = await controller.verifyParentalKeySecure('correct-key');
        
        expect(result.success, isTrue);
        expect(controller.getCurrentUserFailedAttempts(), equals(0));
        expect(controller.canCurrentUserAttemptVerification(), isTrue);
      });

      test('should handle authentication errors securely', () async {
        // Mock unauthenticated user
        when(mockAuth.currentUser).thenReturn(null);
        
        final result = await controller.verifyParentalKeySecure('any-key');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.authenticationError));
        expect(result.errorMessage, contains('not authenticated'));
      });

      test('should handle system errors gracefully', () async {
        // Setup mock to throw exception
        when(mockDocRef.get()).thenThrow(Exception('Database error'));
        
        final result = await controller.verifyParentalKeySecure('any-key');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.systemError));
        expect(result.errorMessage, contains('Verification error'));
      });
    });

    group('Security Question Verification', () {
      test('should verify security question correctly', () async {
        // Setup mock for successful security question verification
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.get('securityAnswer')).thenReturn(
          controller.hashSecurityAnswer('blue')
        );
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockDocRef.update(any)).thenAnswer((_) async => {});
        
        final result = await controller.verifySecurityQuestionSecure('blue', 'new-key');
        
        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
        
        // Verify that attempts were reset
        expect(controller.getCurrentUserFailedAttempts(), equals(0));
      });

      test('should reject incorrect security answers', () async {
        // Setup mock for incorrect security answer
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.get('securityAnswer')).thenReturn(
          controller.hashSecurityAnswer('blue')
        );
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        
        final result = await controller.verifySecurityQuestionSecure('red', 'new-key');
        
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Incorrect security answer'));
      });

      test('should handle missing consent data', () async {
        // Setup mock for missing consent document
        when(mockDocSnapshot.exists).thenReturn(false);
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        
        final result = await controller.verifySecurityQuestionSecure('any-answer', 'new-key');
        
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('No consent data found'));
      });
    });

    group('Security Statistics', () {
      test('should provide accurate security statistics', () {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Initial state
        var stats = controller.getCurrentUserSecurityStats();
        expect(stats['authenticated'], isTrue);
        expect(stats['canAttempt'], isTrue);
        expect(stats['failedAttempts'], equals(0));
        expect(stats['isLockedOut'], isFalse);
        
        // After failed attempts
        attemptService.recordFailedAttempt(userId);
        attemptService.recordFailedAttempt(userId);
        
        stats = controller.getCurrentUserSecurityStats();
        expect(stats['failedAttempts'], equals(2));
        expect(stats['attemptsRemaining'], equals(1));
        expect(stats['canAttempt'], isTrue);
        expect(stats['isLockedOut'], isFalse);
        
        // After lockout
        attemptService.recordFailedAttempt(userId);
        
        stats = controller.getCurrentUserSecurityStats();
        expect(stats['failedAttempts'], equals(3));
        expect(stats['canAttempt'], isFalse);
        expect(stats['isLockedOut'], isTrue);
        expect(stats['remainingLockoutTime'], isA<Duration>());
      });

      test('should handle unauthenticated user statistics', () {
        // Mock unauthenticated user
        when(mockAuth.currentUser).thenReturn(null);
        
        final stats = controller.getCurrentUserSecurityStats();
        
        expect(stats['authenticated'], isFalse);
        expect(stats['canAttempt'], isFalse);
        expect(stats['failedAttempts'], equals(0));
        expect(stats['isLockedOut'], isFalse);
      });
    });

    group('Hash Security', () {
      test('should hash parental keys consistently', () {
        const key = 'test-parental-key';
        
        final hash1 = controller.hashParentalKey(key);
        final hash2 = controller.hashParentalKey(key);
        
        expect(hash1, equals(hash2));
        expect(hash1, isNot(equals(key))); // Should be hashed, not plain text
        expect(hash1.length, greaterThan(32)); // SHA-256 produces long hashes
      });

      test('should hash different keys to different values', () {
        const key1 = 'key1';
        const key2 = 'key2';
        
        final hash1 = controller.hashParentalKey(key1);
        final hash2 = controller.hashParentalKey(key2);
        
        expect(hash1, isNot(equals(hash2)));
      });

      test('should hash security answers consistently', () {
        const answer = 'Blue';
        
        final hash1 = controller.hashSecurityAnswer(answer);
        final hash2 = controller.hashSecurityAnswer(answer);
        
        expect(hash1, equals(hash2));
        expect(hash1, isNot(equals(answer.toLowerCase())));
      });

      test('should normalize security answer case', () {
        const answer1 = 'Blue';
        const answer2 = 'BLUE';
        const answer3 = 'blue';
        
        final hash1 = controller.hashSecurityAnswer(answer1);
        final hash2 = controller.hashSecurityAnswer(answer2);
        final hash3 = controller.hashSecurityAnswer(answer3);
        
        expect(hash1, equals(hash2));
        expect(hash2, equals(hash3));
      });
    });

    group('Brute Force Protection', () {
      test('should prevent rapid successive attempts', () async {
        const userId = 'test-user-id';
        
        // Setup mock for failed verification
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.get('parentalKey')).thenReturn('hashed-wrong-key');
        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        
        // Rapid attempts should still be tracked correctly
        for (int i = 0; i < 5; i++) {
          await controller.verifyParentalKeySecure('wrong-key');
        }
        
        expect(controller.getCurrentUserFailedAttempts(), equals(5));
        expect(controller.isCurrentUserLockedOut(), isTrue);
        expect(controller.canCurrentUserAttemptVerification(), isFalse);
      });

      test('should maintain lockout across multiple verification attempts', () async {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        // Multiple verification attempts should all fail due to lockout
        for (int i = 0; i < 3; i++) {
          final result = await controller.verifyParentalKeySecure('any-key');
          expect(result.success, isFalse);
          expect(result.errorType, equals(ParentalVerificationErrorType.lockedOut));
        }
        
        expect(controller.isCurrentUserLockedOut(), isTrue);
      });

      test('should enforce lockout duration', () {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        final remainingTime = controller.getCurrentUserRemainingLockoutTime();
        expect(remainingTime.inSeconds, greaterThan(0));
        expect(remainingTime.inSeconds, lessThanOrEqualTo(300)); // 5 minutes max
      });
    });

    group('Manual Security Management', () {
      test('should allow manual attempt reset', () {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Record failed attempts
        attemptService.recordFailedAttempt(userId);
        attemptService.recordFailedAttempt(userId);
        expect(controller.getCurrentUserFailedAttempts(), equals(2));
        
        // Manual reset
        controller.resetCurrentUserAttempts();
        expect(controller.getCurrentUserFailedAttempts(), equals(0));
        expect(controller.canCurrentUserAttemptVerification(), isTrue);
      });

      test('should reset locked out users', () {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Lock out user
        for (int i = 0; i < AttemptLimitingService.MAX_ATTEMPTS; i++) {
          attemptService.recordFailedAttempt(userId);
        }
        
        expect(controller.isCurrentUserLockedOut(), isTrue);
        
        // Manual reset should unlock
        controller.resetCurrentUserAttempts();
        expect(controller.isCurrentUserLockedOut(), isFalse);
        expect(controller.canCurrentUserAttemptVerification(), isTrue);
      });
    });

    group('Error Handling Security', () {
      test('should not leak sensitive information in error messages', () async {
        // Test various error scenarios
        when(mockAuth.currentUser).thenReturn(null);
        var result = await controller.verifyParentalKeySecure('any-key');
        expect(result.errorMessage, isNot(contains('database')));
        expect(result.errorMessage, isNot(contains('hash')));
        
        // Reset auth mock
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockDocRef.get()).thenThrow(Exception('Internal database error'));
        result = await controller.verifyParentalKeySecure('any-key');
        expect(result.errorMessage, contains('Verification error'));
        expect(result.errorMessage, isNot(contains('Internal database error')));
      });

      test('should handle concurrent access safely', () async {
        const userId = 'test-user-id';
        final attemptService = AttemptLimitingService();
        
        // Simulate concurrent failed attempts
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(Future(() => attemptService.recordFailedAttempt(userId)));
        }
        
        await Future.wait(futures);
        
        // Should still maintain correct state
        expect(controller.getCurrentUserFailedAttempts(), equals(10));
        expect(controller.isCurrentUserLockedOut(), isTrue);
      });
    });
  });
}