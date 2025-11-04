import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';
import 'package:guardiancare/src/features/consent/widgets/security_status_indicator.dart';
import 'package:guardiancare/src/features/consent/widgets/parental_control_dashboard.dart';
import 'package:guardiancare/src/features/consent/screens/enhanced_password_dialog.dart';
import 'package:guardiancare/src/features/consent/screens/enhanced_reset_dialog.dart';

void main() {
  group('Parental Control Security Integration Tests', () {
    late AttemptLimitingService attemptService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      attemptService = AttemptLimitingService.instance;
      await attemptService.initialize();
      await attemptService.resetAllData();
    });

    tearDown(() async {
      await attemptService.resetAllData();
    });

    group('SecurityStatusIndicator Widget Tests', () {
      testWidgets('should display secure status correctly', (WidgetTester tester) async {
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
            ),
          ),
        );

        expect(find.text('Security Status: Good'), findsOneWidget);
        expect(find.byIcon(Icons.security), findsOneWidget);
        expect(find.text('Your parental controls are secure and ready for verification.'), findsOneWidget);
      });

      testWidgets('should display warning status after failed attempts', (WidgetTester tester) async {
        // Record failed attempts
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
            ),
          ),
        );

        expect(find.text('Security Warning'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
        expect(find.text('1 attempt remaining'), findsOneWidget);
      });

      testWidgets('should display locked status when locked out', (WidgetTester tester) async {
        // Trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
            ),
          ),
        );

        expect(find.text('Account Locked'), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
        expect(find.textContaining('Time remaining:'), findsOneWidget);
        expect(find.text('Failed attempts: 3/3'), findsOneWidget);
      });

      testWidgets('should handle tap events correctly', (WidgetTester tester) async {
        bool tapped = false;
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(SecurityStatusIndicator));
        expect(tapped, isTrue);
      });
    });

    group('CompactSecurityStatusIndicator Widget Tests', () {
      testWidgets('should display compact secure status', (WidgetTester tester) async {
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompactSecurityStatusIndicator(
                attemptStatus: attemptStatus,
              ),
            ),
          ),
        );

        expect(find.text('Secure'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should display compact warning status', (WidgetTester tester) async {
        await attemptService.recordFailedAttempt();
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompactSecurityStatusIndicator(
                attemptStatus: attemptStatus,
              ),
            ),
          ),
        );

        expect(find.text('2 attempts left'), findsOneWidget);
        expect(find.byIcon(Icons.warning), findsOneWidget);
      });

      testWidgets('should display compact locked status', (WidgetTester tester) async {
        // Trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompactSecurityStatusIndicator(
                attemptStatus: attemptStatus,
              ),
            ),
          ),
        );

        expect(find.textContaining('Locked'), findsOneWidget);
        expect(find.byIcon(Icons.block), findsOneWidget);
      });
    });

    group('EnhancedPasswordDialog Widget Tests', () {
      testWidgets('should display password input for normal state', (WidgetTester tester) async {
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) {},
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        expect(find.text('Parental Verification'), findsOneWidget);
        expect(find.text('Please enter your parental key to continue:'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Verify'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
      });

      testWidgets('should display warning for failed attempts', (WidgetTester tester) async {
        await attemptService.recordFailedAttempt();
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) {},
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        expect(find.text('2 attempts remaining'), findsOneWidget);
        expect(find.textContaining('Previous attempts failed'), findsOneWidget);
      });

      testWidgets('should display lockout information when locked', (WidgetTester tester) async {
        // Trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) {},
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        expect(find.text('Account Locked'), findsOneWidget);
        expect(find.textContaining('temporarily locked'), findsOneWidget);
        expect(find.textContaining('Time remaining:'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
        
        // Should not show verify button when locked
        expect(find.text('Verify'), findsNothing);
      });

      testWidgets('should handle password submission', (WidgetTester tester) async {
        String? submittedPassword;
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) => submittedPassword = password,
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        // Enter password
        await tester.enterText(find.byType(TextField), 'testpassword');
        await tester.tap(find.text('Verify'));
        await tester.pump();

        expect(submittedPassword, equals('testpassword'));
      });

      testWidgets('should toggle password visibility', (WidgetTester tester) async {
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) {},
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        // Find the visibility toggle button
        final visibilityButton = find.byIcon(Icons.visibility_off);
        expect(visibilityButton, findsOneWidget);

        // Tap to show password
        await tester.tap(visibilityButton);
        await tester.pump();

        // Should now show visibility icon
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('EnhancedResetDialog Widget Tests', () {
      testWidgets('should display reset form correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedResetDialog(
                onSubmit: (answer, newPassword) {},
                onCancel: () {},
              ),
            ),
          ),
        );

        expect(find.text('Reset Parental Key'), findsOneWidget);
        expect(find.text('Security Question:'), findsOneWidget);
        expect(find.text('What is your mother\'s maiden name?'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(3)); // Answer, new password, confirm password
        expect(find.text('Reset Key'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('should validate form fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedResetDialog(
                onSubmit: (answer, newPassword) {},
                onCancel: () {},
              ),
            ),
          ),
        );

        // Try to submit without filling fields
        await tester.tap(find.text('Reset Key'));
        await tester.pump();

        expect(find.text('Security answer is required'), findsOneWidget);
        expect(find.text('New parental key is required'), findsOneWidget);
      });

      testWidgets('should validate password confirmation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedResetDialog(
                onSubmit: (answer, newPassword) {},
                onCancel: () {},
              ),
            ),
          ),
        );

        // Fill in different passwords
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'security answer');
        await tester.enterText(textFields.at(1), 'password1');
        await tester.enterText(textFields.at(2), 'password2');

        await tester.tap(find.text('Reset Key'));
        await tester.pump();

        expect(find.text('Parental keys do not match'), findsOneWidget);
      });

      testWidgets('should handle successful form submission', (WidgetTester tester) async {
        String? submittedAnswer;
        String? submittedPassword;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedResetDialog(
                onSubmit: (answer, newPassword) {
                  submittedAnswer = answer;
                  submittedPassword = newPassword;
                },
                onCancel: () {},
              ),
            ),
          ),
        );

        // Fill in valid form
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'security answer');
        await tester.enterText(textFields.at(1), 'newpassword123');
        await tester.enterText(textFields.at(2), 'newpassword123');

        await tester.tap(find.text('Reset Key'));
        await tester.pump();

        expect(submittedAnswer, equals('security answer'));
        expect(submittedPassword, equals('newpassword123'));
      });
    });

    group('Integration Flow Tests', () {
      testWidgets('should show progressive security warnings', (WidgetTester tester) async {
        // Start with clean state
        var attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SecurityStatusIndicator(
                    attemptStatus: attemptStatus,
                    showDetails: true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Should show secure status
        expect(find.text('Security Status: Good'), findsOneWidget);

        // Record first failed attempt
        await attemptService.recordFailedAttempt();
        attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SecurityStatusIndicator(
                    attemptStatus: attemptStatus,
                    showDetails: true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Should show warning
        expect(find.text('Security Warning'), findsOneWidget);
        expect(find.text('2 attempts remaining'), findsOneWidget);

        // Record more failed attempts to trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SecurityStatusIndicator(
                    attemptStatus: attemptStatus,
                    showDetails: true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Should show locked status
        expect(find.text('Account Locked'), findsOneWidget);
        expect(find.textContaining('Time remaining:'), findsOneWidget);
      });

      testWidgets('should handle security recovery flow', (WidgetTester tester) async {
        // Trigger lockout
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        await attemptService.recordFailedAttempt();
        
        var attemptStatus = await attemptService.getAttemptStatus();
        expect(attemptStatus.isLockedOut, isTrue);

        // Simulate successful recovery
        await attemptService.recordSuccessfulAttempt();
        attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
            ),
          ),
        );

        // Should be back to secure state
        expect(find.text('Security Status: Good'), findsOneWidget);
        expect(attemptStatus.failedAttempts, equals(0));
        expect(attemptStatus.isLockedOut, isFalse);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper accessibility labels', (WidgetTester tester) async {
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) {},
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        // Check for semantic labels
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Parental Key'), findsOneWidget);
        
        // Buttons should be accessible
        expect(find.text('Verify'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Forgot Password?'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (WidgetTester tester) async {
        final attemptStatus = await attemptService.getAttemptStatus();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedPasswordDialog(
                attemptStatus: attemptStatus,
                onSubmit: (password) {},
                onCancel: () {},
                onForgotPassword: () {},
              ),
            ),
          ),
        );

        // Should be able to focus on text field
        await tester.tap(find.byType(TextField));
        await tester.pump();
        
        // Enter text via keyboard
        await tester.enterText(find.byType(TextField), 'test');
        expect(find.text('test'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle rapid state changes efficiently', (WidgetTester tester) async {
        var attemptStatus = await attemptService.getAttemptStatus();
        
        // Create widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
            ),
          ),
        );

        // Rapidly change state multiple times
        for (int i = 0; i < 5; i++) {
          await attemptService.recordFailedAttempt();
          attemptStatus = await attemptService.getAttemptStatus();
          
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SecurityStatusIndicator(
                  attemptStatus: attemptStatus,
                  showDetails: true,
                ),
              ),
            ),
          );
          
          await tester.pump();
        }

        // Should handle rapid updates without issues
        expect(find.byType(SecurityStatusIndicator), findsOneWidget);
      });
    });
  });
}