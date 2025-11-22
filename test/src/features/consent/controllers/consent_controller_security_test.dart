import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  User,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
import 'consent_controller_security_test.mocks.dart';

void main() {
  group('ConsentController Security Tests', () {
    late ConsentController controller;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockFirebaseFirestore mockFirestore;
    late AttemptLimitingService attemptService;

    setUp(() async {
      // Setup SharedPreferences for AttemptLimitingService
      SharedPreferences.setMockInitialValues({});
      
      // Initialize mocks
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockFirestore = MockFirebaseFirestore();
      
      // Setup mock user
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockAuth.currentUser).thenReturn(mockUser);

      // Initialize services
      attemptService = AttemptLimitingService.instance;
      await attemptService.initialize();
      await attemptService.resetAllData();
      
      controller = ConsentController();
    });

    tearDown(() async {
      await attemptService.resetAllData();
    });

    group('Parental Key Verification Security', () {
      test('should handle correct parental key verification', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        
        // Hash of 'testkey123'
        final hashedKey = controller.hashParentalKey('testkey123');
        when(mockDoc.get('parentalKey')).thenReturn(hashedKey);

        // Verify correct key
        final result = await controller.verifyParentalKeySecure('testkey123');
        
        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
        expect(result.errorType, isNull);
      });

      test('should handle incorrect parental key verification', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        
        // Hash of 'correctkey'
        final hashedKey = controller.hashParentalKey('correctkey');
        when(mockDoc.get('parentalKey')).thenReturn(hashedKey);

        // Verify incorrect key
        final result = await controller.verifyParentalKeySecure('wrongkey');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.incorrectKey));
        expect(result.failedAttempts, equals(1));
        expect(result.attemptsRemaining, equals(2));
      });

      test('should trigger lockout after max failed attempts', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        
        final hashedKey = controller.hashParentalKey('correctkey');
        when(mockDoc.get('parentalKey')).thenReturn(hashedKey);

        // First two failed attempts
        await controller.verifyParentalKeySecure('wrongkey1');
        await controller.verifyParentalKeySecure('wrongkey2');
        
        // Third attempt should trigger lockout
        final result = await controller.verifyParentalKeySecure('wrongkey3');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.lockedOut));
        expect(result.isLockedOut, isTrue);
        expect(result.remainingLockoutTime, isNotNull);
      });

      test('should prevent verification when locked out', () async {
        // Trigger lockout first
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();

        // Attempt verification while locked out
        final result = await controller.verifyParentalKeySecure('anykey');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.lockedOut));
        expect(result.isLockedOut, isTrue);
      });

      test('should reset attempts on successful verification', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        
        final hashedKey = controller.hashParentalKey('correctkey');
        when(mockDoc.get('parentalKey')).thenReturn(hashedKey);

        // Record some failed attempts
        await controller.verifyParentalKeySecure('wrongkey1');
        await controller.verifyParentalKeySecure('wrongkey2');
        
        // Verify failed attempts were recorded
        expect(await attemptService.getFailedAttempts(), equals(2));
        
        // Successful verification should reset attempts
        final result = await controller.verifyParentalKeySecure('correctkey');
        
        expect(result.success, isTrue);
        expect(await attemptService.getFailedAttempts(), equals(0));
        expect(await attemptService.isLockedOut(), isFalse);
      });
    });

    group('Security Question Verification', () {
      test('should handle correct security answer', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        when(mockDocRef.update(any)).thenAnswer((_) async => {});
        
        // Hash of 'correct answer'
        final hashedAnswer = controller.hashSecurityAnswer('correct answer');
        when(mockDoc.get('securityAnswer')).thenReturn(hashedAnswer);

        // Verify correct answer
        final result = await controller.verifySecurityQuestionSecure(
          'correct answer',
          'newpassword123',
        );
        
        expect(result.success, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should handle incorrect security answer', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        
        final hashedAnswer = controller.hashSecurityAnswer('correct answer');
        when(mockDoc.get('securityAnswer')).thenReturn(hashedAnswer);

        // Verify incorrect answer
        final result = await controller.verifySecurityQuestionSecure(
          'wrong answer',
          'newpassword123',
        );
        
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Incorrect security answer'));
      });

      test('should reset attempts after successful password reset', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        when(mockDocRef.update(any)).thenAnswer((_) async => {});
        
        final hashedAnswer = controller.hashSecurityAnswer('correct answer');
        when(mockDoc.get('securityAnswer')).thenReturn(hashedAnswer);

        // Record some failed attempts first
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        expect(await attemptService.getFailedAttempts(), equals(2));

        // Successful password reset should clear attempts
        final result = await controller.verifySecurityQuestionSecure(
          'correct answer',
          'newpassword123',
        );
        
        expect(result.success, isTrue);
        expect(await attemptService.getFailedAttempts(), equals(0));
      });
    });

    group('Security Statistics and Status', () {
      test('should provide correct security statistics for clean state', () async {
        final stats = await controller.getCurrentUserSecurityStats();
        
        expect(stats['authenticated'], isTrue);
        expect(stats['canAttempt'], isTrue);
        expect(stats['failedAttempts'], equals(0));
        expect(stats['attemptsRemaining'], equals(3));
        expect(stats['isLockedOut'], isFalse);
        expect(stats['maxAttempts'], equals(3));
        expect(stats['lockoutDurationMinutes'], equals(5));
      });

      test('should provide correct security statistics with failed attempts', () async {
        // Record some failed attempts
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        final stats = await controller.getCurrentUserSecurityStats();
        
        expect(stats['authenticated'], isTrue);
        expect(stats['canAttempt'], isTrue);
        expect(stats['failedAttempts'], equals(2));
        expect(stats['attemptsRemaining'], equals(1));
        expect(stats['isLockedOut'], isFalse);
      });

      test('should provide correct security statistics when locked out', () async {
        // Trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        final stats = await controller.getCurrentUserSecurityStats();
        
        expect(stats['authenticated'], isTrue);
        expect(stats['canAttempt'], isFalse);
        expect(stats['failedAttempts'], equals(3));
        expect(stats['attemptsRemaining'], equals(0));
        expect(stats['isLockedOut'], isTrue);
      });

      test('should handle unauthenticated user correctly', () async {
        // Mock unauthenticated state
        when(mockAuth.currentUser).thenReturn(null);
        
        final stats = await controller.getCurrentUserSecurityStats();
        
        expect(stats['authenticated'], isFalse);
        expect(stats['canAttempt'], isFalse);
        expect(stats['failedAttempts'], equals(0));
        expect(stats['isLockedOut'], isFalse);
      });
    });

    group('Enhanced Verification with Logging', () {
      test('should log verification attempts', () async {
        // Setup mock Firestore response
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(true);
        
        final hashedKey = controller.hashParentalKey('correctkey');
        when(mockDoc.get('parentalKey')).thenReturn(hashedKey);

        // This should log the verification attempt
        final result = await controller.verifyParentalKeyWithLogging(
          'correctkey',
          context: 'test_verification',
        );
        
        expect(result.success, isTrue);
        // Note: In a real implementation, you might want to capture and verify log output
      });

      test('should handle authentication errors in enhanced verification', () async {
        // Mock unauthenticated state
        when(mockAuth.currentUser).thenReturn(null);
        
        final result = await controller.verifyParentalKeyWithLogging('anykey');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.authenticationError));
      });
    });

    group('Helper Methods', () {
      test('should check if current user can attempt verification', () async {
        expect(await controller.canCurrentUserAttemptVerification(), isTrue);
        
        // After lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        expect(await controller.canCurrentUserAttemptVerification(), isFalse);
      });

      test('should get current user failed attempts', () async {
        expect(await controller.getCurrentUserFailedAttempts(), equals(0));
        
        await attemptService.recordFailedAttempt();
        expect(await controller.getCurrentUserFailedAttempts(), equals(1));
        
        await attemptService.recordFailedAttempt();
        expect(await controller.getCurrentUserFailedAttempts(), equals(2));
      });

      test('should get current user lockout status', () async {
        expect(await controller.isCurrentUserLockedOut(), isFalse);
        
        // Trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        expect(await controller.isCurrentUserLockedOut(), isTrue);
      });

      test('should reset current user attempts', () async {
        // Record some attempts
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        expect(await controller.getCurrentUserFailedAttempts(), equals(2));
        
        // Reset attempts
        await controller.resetCurrentUserAttempts();
        expect(await controller.getCurrentUserFailedAttempts(), equals(0));
      });
    });

    group('Error Handling', () {
      test('should handle Firestore errors gracefully', () async {
        // Setup mock to throw error
        final mockCollection = MockCollectionReference();
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenThrow(Exception('Firestore error'));

        final result = await controller.verifyParentalKeySecure('anykey');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(ParentalVerificationErrorType.systemError));
        expect(result.errorMessage, contains('Verification error'));
      });

      test('should handle missing consent document', () async {
        // Setup mock for non-existent document
        final mockDoc = MockDocumentSnapshot();
        final mockDocRef = MockDocumentReference();
        final mockCollection = MockCollectionReference();
        
        when(mockFirestore.collection('consents')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDocRef);
        when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
        when(mockDoc.exists).thenReturn(false);

        final result = await controller.verifySecurityQuestionSecure(
          'any answer',
          'newpassword',
        );
        
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('No consent data found'));
      });
    });

    group('Password Hashing Security', () {
      test('should hash passwords consistently', () {
        final password = 'testpassword123';
        final hash1 = controller.hashParentalKey(password);
        final hash2 = controller.hashParentalKey(password);
        
        expect(hash1, equals(hash2));
        expect(hash1, isNot(equals(password))); // Should be hashed, not plain text
      });

      test('should hash different passwords differently', () {
        final hash1 = controller.hashParentalKey('password1');
        final hash2 = controller.hashParentalKey('password2');
        
        expect(hash1, isNot(equals(hash2)));
      });

      test('should hash security answers consistently', () {
        final answer = 'My Answer';
        final hash1 = controller.hashSecurityAnswer(answer);
        final hash2 = controller.hashSecurityAnswer(answer);
        
        expect(hash1, equals(hash2));
      });

      test('should handle case insensitive security answers', () {
        final hash1 = controller.hashSecurityAnswer('My Answer');
        final hash2 = controller.hashSecurityAnswer('my answer');
        
        expect(hash1, equals(hash2)); // Should be case insensitive
      });
    });
  });
}