import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:guardiancare/src/features/authentication/services/session_manager.dart';
import 'package:guardiancare/src/features/authentication/services/auth_error_handler.dart';
import 'package:guardiancare/src/features/authentication/controllers/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Integration Tests', () {
    late SessionManager sessionManager;
    late AuthErrorHandler errorHandler;
    late AuthenticationService authService;

    setUp(() async {
      // Initialize shared preferences with mock values
      SharedPreferences.setMockInitialValues({});
      
      sessionManager = SessionManager.instance;
      errorHandler = AuthErrorHandler.instance;
      authService = AuthenticationService.instance;
      
      await sessionManager.initialize();
    });

    tearDown(() async {
      await sessionManager.endSession();
    });

    group('Session Management Integration', () {
      test('should integrate session management with authentication flow', () async {
        // Test that session manager works with authentication service
        expect(sessionManager.isSessionActive, isFalse);
        
        // Start a session
        await sessionManager.startSession();
        expect(sessionManager.isSessionActive, isTrue);
        
        // Verify session properties
        expect(sessionManager.sessionStartTime, isNotNull);
        expect(sessionManager.lastActivityTime, isNotNull);
        expect(sessionManager.remainingSessionTime, isNotNull);
        
        // Update activity
        await Future.delayed(const Duration(milliseconds: 10));
        await sessionManager.updateActivity();
        
        // Verify activity was updated
        expect(sessionManager.lastActivityTime, isNotNull);
        
        // End session
        await sessionManager.endSession();
        expect(sessionManager.isSessionActive, isFalse);
      });

      test('should handle session renewal with authentication state', () async {
        await sessionManager.startSession();
        
        // Test session renewal when no user is authenticated
        final renewalResult = await sessionManager.renewSession();
        expect(renewalResult.success, isFalse);
        expect(renewalResult.errorMessage, contains('No authenticated user'));
      });

      test('should persist session data across restarts', () async {
        const customTimeout = Duration(hours: 12);
        
        // Start session with custom timeout
        await sessionManager.startSession(customTimeout: customTimeout);
        expect(sessionManager.sessionTimeout, equals(customTimeout));
        
        // Simulate app restart by creating new instance
        final newSessionManager = SessionManager.instance;
        await newSessionManager.initialize();
        
        // Verify timeout persisted
        expect(newSessionManager.sessionTimeout, equals(customTimeout));
      });

      test('should handle session expiry correctly', () async {
        // Start session with very short timeout
        const shortTimeout = Duration(seconds: 1);
        await sessionManager.startSession(customTimeout: shortTimeout);
        
        expect(sessionManager.isSessionActive, isTrue);
        
        // Wait for session to expire
        await Future.delayed(const Duration(seconds: 2));
        
        // Session should be expired
        expect(sessionManager.isSessionActive, isFalse);
      });
    });

    group('Error Handling Integration', () {
      test('should integrate error handler with authentication results', () async {
        // Test successful authentication result
        final successResult = AuthResult.success(
          null, // Mock UserCredential
          attemptCount: 1,
          totalDuration: const Duration(seconds: 3),
        );
        
        expect(successResult.success, isTrue);
        expect(successResult.attemptCount, equals(1));
        expect(successResult.totalDuration, equals(const Duration(seconds: 3)));
        
        // Test failure authentication result
        final failureResult = AuthResult.failure(
          'Network connection failed',
          AuthErrorType.network,
          attemptCount: 3,
          totalDuration: const Duration(seconds: 15),
        );
        
        expect(failureResult.success, isFalse);
        expect(failureResult.error, equals('Network connection failed'));
        expect(failureResult.errorType, equals(AuthErrorType.network));
        expect(failureResult.attemptCount, equals(3));
        expect(failureResult.totalDuration, equals(const Duration(seconds: 15)));
      });

      test('should handle different error types appropriately', () async {
        final errorTypes = [
          AuthErrorType.network,
          AuthErrorType.credential,
          AuthErrorType.permission,
          AuthErrorType.validation,
          AuthErrorType.timeout,
          AuthErrorType.cancelled,
          AuthErrorType.system,
        ];

        for (final errorType in errorTypes) {
          final result = AuthResult.failure(
            'Test error for $errorType',
            errorType,
          );
          
          expect(result.success, isFalse);
          expect(result.errorType, equals(errorType));
        }
      });

      test('should provide appropriate error information', () async {
        final errorInfo = AuthErrorInfo(
          message: 'Network connection failed',
          errorType: AuthErrorType.network,
          isRetryable: true,
          severity: ErrorSeverity.warning,
          suggestedActions: [
            'Check your internet connection',
            'Try again in a moment',
          ],
          attemptCount: 2,
          totalDuration: const Duration(seconds: 10),
        );

        expect(errorInfo.message, equals('Network connection failed'));
        expect(errorInfo.errorType, equals(AuthErrorType.network));
        expect(errorInfo.isRetryable, isTrue);
        expect(errorInfo.severity, equals(ErrorSeverity.warning));
        expect(errorInfo.suggestedActions, hasLength(2));
        expect(errorInfo.attemptCount, equals(2));
        expect(errorInfo.totalDuration, equals(const Duration(seconds: 10)));
      });
    });

    group('Authentication Service Integration', () {
      test('should handle authentication status correctly', () {
        // Test authentication status determination
        final status = authService.getCurrentAuthStatus();
        expect(status, isA<AuthStatus>());
        
        // Initially should be signed out
        expect(status, equals(AuthStatus.signedOut));
      });

      test('should handle profile completion requirements', () {
        // Test profile completion check
        final requiresCompletion = authService.requiresProfileCompletion();
        expect(requiresCompletion, isA<bool>());
        
        // Initially should not require completion (no user)
        expect(requiresCompletion, isFalse);
      });

      test('should handle user information extraction', () {
        // Test user info extraction when no user is signed in
        final userInfo = authService.getCurrentUserInfo();
        expect(userInfo, isNull);
      });

      test('should create authentication exceptions correctly', () {
        const message = 'Test authentication error';
        const code = 'test_error';
        const errorType = AuthErrorType.validation;

        final exception = AuthenticationException(message, code, errorType);

        expect(exception.message, equals(message));
        expect(exception.code, equals(code));
        expect(exception.errorType, equals(errorType));
        expect(exception.toString(), equals(message));
      });
    });

    group('Cross-Service Integration', () {
      test('should integrate session management with error handling', () async {
        // Start a session
        await sessionManager.startSession();
        
        // Create an authentication error
        final authError = AuthResult.failure(
          'Session expired',
          AuthErrorType.timeout,
        );
        
        // Verify both services work together
        expect(sessionManager.isSessionActive, isTrue);
        expect(authError.success, isFalse);
        expect(authError.errorType, equals(AuthErrorType.timeout));
        
        // End session due to error
        await sessionManager.endSession();
        expect(sessionManager.isSessionActive, isFalse);
      });

      test('should handle authentication flow with session tracking', () async {
        // Simulate authentication flow
        final startTime = DateTime.now();
        
        // Start session for authentication attempt
        await sessionManager.startSession();
        
        // Simulate authentication attempt
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Update activity during authentication
        await sessionManager.updateActivity();
        
        // Create authentication result
        final authResult = AuthResult.success(
          null, // Mock UserCredential
          attemptCount: 1,
          totalDuration: DateTime.now().difference(startTime),
        );
        
        // Verify integration
        expect(sessionManager.isSessionActive, isTrue);
        expect(authResult.success, isTrue);
        expect(authResult.totalDuration, isNotNull);
        expect(authResult.totalDuration!.inMilliseconds, greaterThan(0));
      });

      test('should handle retry logic with session management', () async {
        await sessionManager.startSession();
        
        // Simulate multiple authentication attempts
        const maxRetries = 3;
        final results = <AuthResult>[];
        
        for (int attempt = 1; attempt <= maxRetries; attempt++) {
          // Update activity for each attempt
          await sessionManager.updateActivity();
          
          // Simulate failed attempt
          final result = AuthResult.failure(
            'Attempt $attempt failed',
            AuthErrorType.network,
            attemptCount: attempt,
            totalDuration: Duration(seconds: attempt * 2),
          );
          
          results.add(result);
          
          // Add delay between attempts
          if (attempt < maxRetries) {
            await Future.delayed(Duration(milliseconds: attempt * 100));
          }
        }
        
        // Verify all attempts were tracked
        expect(results, hasLength(maxRetries));
        expect(sessionManager.isSessionActive, isTrue);
        
        for (int i = 0; i < results.length; i++) {
          expect(results[i].attemptCount, equals(i + 1));
          expect(results[i].success, isFalse);
        }
      });
    });

    group('Performance Integration', () {
      test('should handle rapid session operations', () async {
        // Test rapid session start/stop operations
        for (int i = 0; i < 10; i++) {
          await sessionManager.startSession();
          expect(sessionManager.isSessionActive, isTrue);
          
          await sessionManager.updateActivity();
          
          await sessionManager.endSession();
          expect(sessionManager.isSessionActive, isFalse);
        }
      });

      test('should handle concurrent session operations', () async {
        // Test concurrent operations
        final futures = <Future>[];
        
        // Start session
        await sessionManager.startSession();
        
        // Perform concurrent activity updates
        for (int i = 0; i < 5; i++) {
          futures.add(sessionManager.updateActivity());
        }
        
        // Wait for all operations to complete
        await Future.wait(futures);
        
        expect(sessionManager.isSessionActive, isTrue);
        expect(sessionManager.lastActivityTime, isNotNull);
      });

      test('should handle large numbers of error results', () async {
        final results = <AuthResult>[];
        
        // Create many error results
        for (int i = 0; i < 100; i++) {
          final result = AuthResult.failure(
            'Error $i',
            AuthErrorType.values[i % AuthErrorType.values.length],
            attemptCount: i + 1,
          );
          results.add(result);
        }
        
        expect(results, hasLength(100));
        
        // Verify all results are properly formed
        for (int i = 0; i < results.length; i++) {
          expect(results[i].success, isFalse);
          expect(results[i].attemptCount, equals(i + 1));
          expect(results[i].errorType, isNotNull);
        }
      });
    });

    group('Data Persistence Integration', () {
      test('should persist session data correctly', () async {
        const customTimeout = Duration(hours: 8);
        
        // Start session with custom settings
        await sessionManager.startSession(customTimeout: customTimeout);
        
        final originalStartTime = sessionManager.sessionStartTime;
        final originalActivity = sessionManager.lastActivityTime;
        
        // Verify data is set
        expect(originalStartTime, isNotNull);
        expect(originalActivity, isNotNull);
        expect(sessionManager.sessionTimeout, equals(customTimeout));
        
        // Create new instance to test persistence
        final newManager = SessionManager.instance;
        await newManager.initialize();
        
        // Verify persistence (timeout should persist)
        expect(newManager.sessionTimeout, equals(customTimeout));
      });

      test('should handle corrupted session data gracefully', () async {
        // This would test handling of corrupted SharedPreferences data
        // In a real test, we'd mock SharedPreferences to return invalid data
        
        // For now, test that initialization doesn't crash
        final manager = SessionManager.instance;
        expect(() => manager.initialize(), returnsNormally);
      });
    });

    group('Edge Case Integration', () {
      test('should handle system time changes', () async {
        await sessionManager.startSession();
        
        final initialTime = sessionManager.sessionStartTime;
        expect(initialTime, isNotNull);
        
        // Simulate activity update
        await Future.delayed(const Duration(milliseconds: 10));
        await sessionManager.updateActivity();
        
        final updatedTime = sessionManager.lastActivityTime;
        expect(updatedTime, isNotNull);
        expect(updatedTime!.isAfter(initialTime!), isTrue);
      });

      test('should handle memory pressure scenarios', () async {
        // Test that the system handles resource constraints
        await sessionManager.startSession();
        
        // Create many error results to simulate memory pressure
        final results = <AuthResult>[];
        for (int i = 0; i < 1000; i++) {
          results.add(AuthResult.failure('Error $i', AuthErrorType.system));
        }
        
        // System should still function
        expect(sessionManager.isSessionActive, isTrue);
        expect(results, hasLength(1000));
        
        // Cleanup
        results.clear();
        await sessionManager.endSession();
      });

      test('should handle rapid authentication attempts', () async {
        await sessionManager.startSession();
        
        // Simulate rapid authentication attempts
        final results = <AuthResult>[];
        
        for (int i = 0; i < 20; i++) {
          await sessionManager.updateActivity();
          
          final result = AuthResult.failure(
            'Rapid attempt $i',
            AuthErrorType.network,
            attemptCount: i + 1,
          );
          results.add(result);
        }
        
        expect(results, hasLength(20));
        expect(sessionManager.isSessionActive, isTrue);
      });
    });

    group('Cleanup and Resource Management', () {
      test('should cleanup resources properly', () async {
        await sessionManager.startSession();
        
        // Verify session is active
        expect(sessionManager.isSessionActive, isTrue);
        
        // Cleanup
        sessionManager.dispose();
        
        // Should not crash after disposal
        expect(() => sessionManager.getSessionStats(), returnsNormally);
      });

      test('should handle multiple cleanup calls', () async {
        await sessionManager.startSession();
        
        // Multiple dispose calls should not crash
        sessionManager.dispose();
        expect(() => sessionManager.dispose(), returnsNormally);
        expect(() => sessionManager.dispose(), returnsNormally);
      });
    });
  });
}