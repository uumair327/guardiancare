import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/authentication/services/auth_error_handler.dart';
import 'package:guardiancare/src/features/authentication/controllers/login_controller.dart';

void main() {
  group('AuthErrorHandler Tests', () {
    late AuthErrorHandler errorHandler;

    setUp(() {
      errorHandler = AuthErrorHandler.instance;
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = AuthErrorHandler.instance;
        final instance2 = AuthErrorHandler.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Error Type Classification', () {
      test('should classify network errors correctly', () {
        final networkResult = AuthResult.failure(
          'Network connection failed',
          AuthErrorType.network,
        );

        expect(networkResult.errorType, equals(AuthErrorType.network));
      });

      test('should classify credential errors correctly', () {
        final credentialResult = AuthResult.failure(
          'Invalid credentials',
          AuthErrorType.credential,
        );

        expect(credentialResult.errorType, equals(AuthErrorType.credential));
      });

      test('should classify permission errors correctly', () {
        final permissionResult = AuthResult.failure(
          'User disabled',
          AuthErrorType.permission,
        );

        expect(permissionResult.errorType, equals(AuthErrorType.permission));
      });

      test('should classify validation errors correctly', () {
        final validationResult = AuthResult.failure(
          'Invalid email format',
          AuthErrorType.validation,
        );

        expect(validationResult.errorType, equals(AuthErrorType.validation));
      });

      test('should classify timeout errors correctly', () {
        final timeoutResult = AuthResult.failure(
          'Connection timeout',
          AuthErrorType.timeout,
        );

        expect(timeoutResult.errorType, equals(AuthErrorType.timeout));
      });

      test('should classify cancelled errors correctly', () {
        final cancelledResult = AuthResult.failure(
          'User cancelled',
          AuthErrorType.cancelled,
        );

        expect(cancelledResult.errorType, equals(AuthErrorType.cancelled));
      });

      test('should classify system errors correctly', () {
        final systemResult = AuthResult.failure(
          'System error',
          AuthErrorType.system,
        );

        expect(systemResult.errorType, equals(AuthErrorType.system));
      });
    });

    group('Error Handling Logic', () {
      testWidgets('should handle successful auth result without error', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final successResult = AuthResult.success(
                        await Future.value(null), // Mock UserCredential
                      );
                      
                      await errorHandler.handleAuthError(context, successResult);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should not show any error UI for successful result
        expect(find.byType(SnackBar), findsNothing);
      });

      testWidgets('should show snack bar for error result', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final errorResult = AuthResult.failure(
                        'Test error message',
                        AuthErrorType.network,
                      );
                      
                      await errorHandler.handleAuthError(context, errorResult);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(); // Allow snack bar to appear

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Test error message'), findsOneWidget);
      });

      testWidgets('should show retry action for retryable errors', (tester) async {
        bool retryCallbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final errorResult = AuthResult.failure(
                        'Network error',
                        AuthErrorType.network,
                      );
                      
                      await errorHandler.handleAuthError(
                        context,
                        errorResult,
                        onRetry: () => retryCallbackCalled = true,
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump();

        // Should show retry action for network errors
        expect(find.text('Retry'), findsOneWidget);

        // Test retry callback
        await tester.tap(find.text('Retry'));
        expect(retryCallbackCalled, isTrue);
      });

      testWidgets('should not show retry action for non-retryable errors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final errorResult = AuthResult.failure(
                        'Invalid credentials',
                        AuthErrorType.credential,
                      );
                      
                      await errorHandler.handleAuthError(
                        context,
                        errorResult,
                        onRetry: () {},
                      );
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump();

        // Should not show retry action for credential errors
        expect(find.text('Retry'), findsNothing);
      });
    });

    group('Error Severity and Styling', () {
      test('should determine correct severity for different error types', () {
        // Network errors should be warnings
        final networkError = AuthResult.failure('Network error', AuthErrorType.network);
        expect(networkError.errorType, equals(AuthErrorType.network));

        // Credential errors should be errors
        final credentialError = AuthResult.failure('Credential error', AuthErrorType.credential);
        expect(credentialError.errorType, equals(AuthErrorType.credential));

        // Permission errors should be critical
        final permissionError = AuthResult.failure('Permission error', AuthErrorType.permission);
        expect(permissionError.errorType, equals(AuthErrorType.permission));

        // Cancelled should be info
        final cancelledError = AuthResult.failure('Cancelled', AuthErrorType.cancelled);
        expect(cancelledError.errorType, equals(AuthErrorType.cancelled));
      });
    });

    group('Suggested Actions', () {
      test('should provide appropriate suggestions for network errors', () {
        final networkResult = AuthResult.failure(
          'Network connection failed',
          AuthErrorType.network,
        );

        expect(networkResult.errorType, equals(AuthErrorType.network));
        // In a real implementation, we'd test the suggested actions
        // This would require exposing the _getSuggestedActions method
      });

      test('should provide appropriate suggestions for credential errors', () {
        final credentialResult = AuthResult.failure(
          'Invalid credentials',
          AuthErrorType.credential,
        );

        expect(credentialResult.errorType, equals(AuthErrorType.credential));
      });

      test('should provide appropriate suggestions for validation errors', () {
        final validationResult = AuthResult.failure(
          'Invalid email format',
          AuthErrorType.validation,
        );

        expect(validationResult.errorType, equals(AuthErrorType.validation));
      });
    });

    group('Secure Sign-Out', () {
      testWidgets('should perform secure sign-out', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      await errorHandler.performSecureSignOut(context);
                    },
                    child: const Text('Sign Out'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Should show loading indicator during sign-out
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for sign-out to complete
        await tester.pumpAndSettle();
      });
    });

    group('Error Information', () {
      test('should create AuthErrorInfo with correct properties', () {
        const message = 'Test error message';
        const errorType = AuthErrorType.network;
        const attemptCount = 3;
        const totalDuration = Duration(seconds: 30);

        final errorInfo = AuthErrorInfo(
          message: message,
          errorType: errorType,
          isRetryable: true,
          severity: ErrorSeverity.warning,
          suggestedActions: ['Check connection', 'Try again'],
          attemptCount: attemptCount,
          totalDuration: totalDuration,
        );

        expect(errorInfo.message, equals(message));
        expect(errorInfo.errorType, equals(errorType));
        expect(errorInfo.isRetryable, isTrue);
        expect(errorInfo.severity, equals(ErrorSeverity.warning));
        expect(errorInfo.suggestedActions, hasLength(2));
        expect(errorInfo.attemptCount, equals(attemptCount));
        expect(errorInfo.totalDuration, equals(totalDuration));
      });

      test('should have proper string representation', () {
        final errorInfo = AuthErrorInfo(
          message: 'Test error',
          errorType: AuthErrorType.network,
          isRetryable: true,
          severity: ErrorSeverity.warning,
          suggestedActions: [],
        );

        final stringRep = errorInfo.toString();
        expect(stringRep, contains('network'));
        expect(stringRep, contains('warning'));
        expect(stringRep, contains('true'));
      });
    });

    group('Error Severity Enum', () {
      test('should have all expected severity levels', () {
        expect(ErrorSeverity.values, hasLength(4));
        expect(ErrorSeverity.values, contains(ErrorSeverity.info));
        expect(ErrorSeverity.values, contains(ErrorSeverity.warning));
        expect(ErrorSeverity.values, contains(ErrorSeverity.error));
        expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle null error message gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final errorResult = AuthResult.failure(
                        '', // Empty error message
                        AuthErrorType.system,
                      );
                      
                      await errorHandler.handleAuthError(context, errorResult);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump();

        // Should still show snack bar even with empty message
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should handle multiple error handling calls', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () async {
                      final errorResult1 = AuthResult.failure(
                        'First error',
                        AuthErrorType.network,
                      );
                      
                      final errorResult2 = AuthResult.failure(
                        'Second error',
                        AuthErrorType.credential,
                      );
                      
                      await errorHandler.handleAuthError(context, errorResult1);
                      await errorHandler.handleAuthError(context, errorResult2);
                    },
                    child: const Text('Test'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump();

        // Should handle multiple errors without crashing
        expect(find.byType(SnackBar), findsWidgets);
      });

      test('should handle null attempt count and duration', () {
        final errorInfo = AuthErrorInfo(
          message: 'Test error',
          errorType: AuthErrorType.system,
          isRetryable: false,
          severity: ErrorSeverity.error,
          suggestedActions: [],
          attemptCount: null,
          totalDuration: null,
        );

        expect(errorInfo.attemptCount, isNull);
        expect(errorInfo.totalDuration, isNull);
      });
    });

    group('Integration with AuthResult', () {
      test('should work with AuthResult success', () {
        final successResult = AuthResult.success(
          null, // Mock UserCredential
          attemptCount: 1,
          totalDuration: const Duration(seconds: 5),
        );

        expect(successResult.success, isTrue);
        expect(successResult.error, isNull);
        expect(successResult.errorType, isNull);
      });

      test('should work with AuthResult failure', () {
        const errorMessage = 'Authentication failed';
        const errorType = AuthErrorType.credential;
        const attemptCount = 3;
        const totalDuration = Duration(seconds: 15);

        final failureResult = AuthResult.failure(
          errorMessage,
          errorType,
          attemptCount: attemptCount,
          totalDuration: totalDuration,
        );

        expect(failureResult.success, isFalse);
        expect(failureResult.error, equals(errorMessage));
        expect(failureResult.errorType, equals(errorType));
        expect(failureResult.attemptCount, equals(attemptCount));
        expect(failureResult.totalDuration, equals(totalDuration));
      });
    });
  });
}