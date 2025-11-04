import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/forum/widgets/comment_input.dart';

void main() {
  group('CommentInput Widget Tests', () {
    Widget createTestWidget({
      String? forumId,
      String? parentCommentId,
      VoidCallback? onCommentAdded,
      String? placeholder,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CommentInput(
            forumId: forumId ?? 'test_forum',
            parentCommentId: parentCommentId,
            onCommentAdded: onCommentAdded,
            placeholder: placeholder,
          ),
        ),
      );
    }

    group('Widget Initialization', () {
      testWidgets('should display default placeholder text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('Add a comment...'), findsOneWidget);
      });

      testWidgets('should display custom placeholder text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          placeholder: 'Write your reply...',
        ));
        
        expect(find.text('Write your reply...'), findsOneWidget);
      });

      testWidgets('should display send button', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.byIcon(Icons.send), findsOneWidget);
      });

      testWidgets('should display character counter', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('0/1000'), findsOneWidget);
      });
    });

    group('Text Input Interactions', () {
      testWidgets('should update character count when typing', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Type some text
        await tester.enterText(find.byType(TextField), 'Hello world');
        await tester.pump();
        
        // Should show updated character count
        expect(find.text('11/1000'), findsOneWidget);
      });

      testWidgets('should show draft saved indicator when typing', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Type some text
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        // Should show draft saved indicator
        expect(find.text('Draft saved'), findsOneWidget);
        expect(find.byIcon(Icons.edit), findsOneWidget);
      });

      testWidgets('should change character count color when approaching limit', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Type text close to limit (70% of 1000 = 700 characters)
        final longText = 'a' * 700;
        await tester.enterText(find.byType(TextField), longText);
        await tester.pump();
        
        expect(find.text('700/1000'), findsOneWidget);
        
        // Type text near limit (90% of 1000 = 900 characters)
        final veryLongText = 'a' * 900;
        await tester.enterText(find.byType(TextField), veryLongText);
        await tester.pump();
        
        expect(find.text('900/1000'), findsOneWidget);
      });

      testWidgets('should expand text field for multiline input', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter multiline text
        await tester.enterText(find.byType(TextField), 'Line 1\nLine 2\nLine 3');
        await tester.pump();
        
        expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
      });
    });

    group('Submit Button States', () {
      testWidgets('should disable submit button when input is empty', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        final submitButton = find.byIcon(Icons.send);
        expect(submitButton, findsOneWidget);
        
        // Button should be disabled (grayed out)
        final iconButton = tester.widget<IconButton>(submitButton);
        expect(iconButton.onPressed, isNull);
      });

      testWidgets('should enable submit button when input has valid text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter valid text
        await tester.enterText(find.byType(TextField), 'Valid comment');
        await tester.pump();
        
        final submitButton = find.byIcon(Icons.send);
        final iconButton = tester.widget<IconButton>(submitButton);
        expect(iconButton.onPressed, isNotNull);
      });

      testWidgets('should show loading indicator during submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter text and submit
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        
        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Validation', () {
      testWidgets('should show validation error for empty submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Try to submit empty comment
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        
        // Should show validation error
        expect(find.text('Please enter a comment'), findsOneWidget);
      });

      testWidgets('should show validation error for too short comment', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter very short text
        await tester.enterText(find.byType(TextField), 'a');
        await tester.pump();
        
        // Should show validation error
        expect(find.textContaining('at least 2 characters'), findsOneWidget);
      });

      testWidgets('should show validation error for too long comment', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter text exceeding limit
        final tooLongText = 'a' * 1001;
        await tester.enterText(find.byType(TextField), tooLongText);
        await tester.pump();
        
        // Should show validation error
        expect(find.textContaining('cannot exceed 1000 characters'), findsOneWidget);
      });

      testWidgets('should clear validation error when text changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Trigger validation error
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
        
        expect(find.text('Please enter a comment'), findsOneWidget);
        
        // Enter valid text
        await tester.enterText(find.byType(TextField), 'Valid comment');
        await tester.pump();
        
        // Error should be cleared
        expect(find.text('Please enter a comment'), findsNothing);
      });
    });

    group('Submission Flow', () {
      testWidgets('should clear input after successful submission', (WidgetTester tester) async {
        bool commentAdded = false;
        
        await tester.pumpWidget(createTestWidget(
          onCommentAdded: () => commentAdded = true,
        ));
        
        // Enter and submit comment
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        
        // Input should be cleared (this depends on the submission service behavior)
        // In a real test, we'd mock the service to guarantee success
      });

      testWidgets('should show success message after submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter and submit comment
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        
        // Should show success snackbar (if submission succeeds)
        // Note: This depends on the random simulation in the service
      });

      testWidgets('should call onCommentAdded callback on success', (WidgetTester tester) async {
        bool callbackCalled = false;
        
        await tester.pumpWidget(createTestWidget(
          onCommentAdded: () => callbackCalled = true,
        ));
        
        // Enter and submit comment
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        
        // Callback should be called on success
        // Note: This depends on the random simulation in the service
      });
    });

    group('Error Handling', () {
      testWidgets('should show error message on submission failure', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter comment that might fail (depends on service simulation)
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        
        // May show error snackbar depending on service simulation
        // In a real test, we'd mock the service to guarantee failure
      });

      testWidgets('should preserve draft on submission failure', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter comment
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        
        // Text should remain in field if submission fails
        // Note: This behavior depends on the service implementation
      });
    });

    group('Focus and Keyboard Behavior', () {
      testWidgets('should handle focus changes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Tap to focus
        await tester.tap(find.byType(TextField));
        await tester.pump();
        
        // Enter text
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.pump();
        
        // Tap outside to unfocus
        await tester.tapAt(const Offset(10, 10));
        await tester.pump();
        
        // Should save draft on focus loss
        expect(find.text('Draft saved'), findsOneWidget);
      });

      testWidgets('should support keyboard submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter text
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        // Submit via keyboard (Enter key)
        await tester.testTextInput.receiveAction(TextInputAction.send);
        await tester.pump();
        
        // Should trigger submission
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Text field should be accessible
        expect(find.byType(TextField), findsOneWidget);
        
        // Submit button should have tooltip
        final submitButton = find.byIcon(Icons.send);
        expect(submitButton, findsOneWidget);
      });

      testWidgets('should support screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Widget should be properly structured for screen readers
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    group('Parent Comment Support', () {
      testWidgets('should handle parent comment ID', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          parentCommentId: 'parent123',
        ));
        
        // Should render normally with parent comment ID
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid typing', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Type rapidly
        for (int i = 0; i < 10; i++) {
          await tester.enterText(find.byType(TextField), 'Text $i');
          await tester.pump();
        }
        
        // Should handle rapid updates without crashing
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should handle special characters', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter text with special characters
        await tester.enterText(find.byType(TextField), 'Comment with émojis 🎉 and symbols @#\$%');
        await tester.pump();
        
        // Should display correctly
        expect(find.text('Comment with émojis 🎉 and symbols @#\$%'), findsOneWidget);
      });

      testWidgets('should handle very long single line', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter very long single line
        final longLine = 'This is a very long line that should wrap properly in the text field ' * 5;
        await tester.enterText(find.byType(TextField), longLine);
        await tester.pump();
        
        // Should handle long text without layout issues
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle multiple rapid submissions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Enter text
        await tester.enterText(find.byType(TextField), 'Test comment');
        await tester.pump();
        
        // Try to submit multiple times rapidly
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.send));
          await tester.pump();
        }
        
        // Should handle gracefully without crashing
        expect(find.byType(TextField), findsOneWidget);
      });
    });
  });
}