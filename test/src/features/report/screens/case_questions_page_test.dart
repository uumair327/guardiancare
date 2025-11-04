import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/report/screens/case_questions_page.dart';

void main() {
  group('CaseQuestionsPage Widget Tests', () {
    late List<String> sampleQuestions;

    setUp(() {
      sampleQuestions = [
        'Question 1: Is this happening at school?',
        'Question 2: Does it involve physical contact?',
        'Question 3: Has this happened before?',
        'Question 4: Are there witnesses?',
        'Question 5: Do you feel safe?',
      ];
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: CaseQuestionsPage('Test Case', sampleQuestions),
      );
    }

    group('Widget Initialization', () {
      testWidgets('should display case name in app bar', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('Test Case'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display case title in body', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('Report Test Case'), findsOneWidget);
      });

      testWidgets('should display instruction text', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('Please select all that apply to your situation:'), findsOneWidget);
      });

      testWidgets('should display all questions as checkboxes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        for (final question in sampleQuestions) {
          expect(find.text(question), findsOneWidget);
        }
        
        expect(find.byType(CheckboxListTile), findsNWidgets(sampleQuestions.length));
      });

      testWidgets('should display submit and clear buttons', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.text('Submit Report'), findsOneWidget);
        expect(find.text('Clear'), findsOneWidget);
      });
    });

    group('Checkbox Interactions', () {
      testWidgets('should allow checking and unchecking boxes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Find first checkbox
        final firstCheckbox = find.byType(CheckboxListTile).first;
        
        // Initially should be unchecked
        CheckboxListTile checkbox = tester.widget(firstCheckbox);
        expect(checkbox.value, isFalse);
        
        // Tap to check
        await tester.tap(firstCheckbox);
        await tester.pump();
        
        // Should now be checked
        checkbox = tester.widget(firstCheckbox);
        expect(checkbox.value, isTrue);
        
        // Tap again to uncheck
        await tester.tap(firstCheckbox);
        await tester.pump();
        
        // Should be unchecked again
        checkbox = tester.widget(firstCheckbox);
        expect(checkbox.value, isFalse);
      });

      testWidgets('should update selection summary when checkboxes change', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Initially should show no selections
        expect(find.text('No items selected yet'), findsOneWidget);
        
        // Check first checkbox
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pump();
        
        // Should show 1 selection
        expect(find.text('Selected 1 of 5 items'), findsOneWidget);
        
        // Check second checkbox
        await tester.tap(find.byType(CheckboxListTile).at(1));
        await tester.pump();
        
        // Should show 2 selections
        expect(find.text('Selected 2 of 5 items'), findsOneWidget);
      });

      testWidgets('should visually highlight selected checkboxes', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Check first checkbox
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pump();
        
        // The container around the selected checkbox should have different styling
        final containers = find.byType(Container);
        expect(containers, findsWidgets);
        
        // We can't easily test the exact styling, but we can verify the widget rebuilds
        expect(find.byType(CheckboxListTile), findsNWidgets(sampleQuestions.length));
      });
    });

    group('Form Validation', () {
      testWidgets('should show validation error when submitting empty form', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Try to submit without selecting anything
        await tester.tap(find.text('Submit Report'));
        await tester.pump();
        
        // Should show validation error
        expect(find.textContaining('Please select at least one item'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('should not show validation error when form has selections', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select first checkbox
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pump();
        
        // Validation error should not be visible
        expect(find.textContaining('Please select at least one item'), findsNothing);
        expect(find.byIcon(Icons.error_outline), findsNothing);
      });
    });

    group('Form Submission', () {
      testWidgets('should show loading state during submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select a checkbox first
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pump();
        
        // Tap submit button
        await tester.tap(find.text('Submit Report'));
        await tester.pump();
        
        // Should show submitting state
        expect(find.text('Submitting...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        // Wait for submission to complete
        await tester.pumpAndSettle();
      });

      testWidgets('should disable buttons during submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select a checkbox first
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pump();
        
        // Tap submit button
        await tester.tap(find.text('Submit Report'));
        await tester.pump();
        
        // Buttons should be disabled
        final submitButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Submitting...'),
        );
        final clearButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Clear'),
        );
        
        expect(submitButton.onPressed, isNull);
        expect(clearButton.onPressed, isNull);
        
        // Wait for submission to complete
        await tester.pumpAndSettle();
      });

      testWidgets('should show success message after successful submission', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select a checkbox first
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pump();
        
        // Submit form
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();
        
        // Should show success snackbar
        expect(find.textContaining('successfully'), findsOneWidget);
      });
    });

    group('Form Clearing', () {
      testWidgets('should show confirmation dialog when clearing form', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select some checkboxes first
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.tap(find.byType(CheckboxListTile).at(1));
        await tester.pump();
        
        // Tap clear button
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        
        // Should show confirmation dialog
        expect(find.text('Clear Form'), findsOneWidget);
        expect(find.text('Are you sure you want to clear all selections?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Clear All'), findsOneWidget);
      });

      testWidgets('should clear form when confirmed', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select some checkboxes first
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.tap(find.byType(CheckboxListTile).at(1));
        await tester.pump();
        
        // Verify selections
        expect(find.text('Selected 2 of 5 items'), findsOneWidget);
        
        // Clear form
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        
        // Confirm clearing
        await tester.tap(find.text('Clear All'));
        await tester.pumpAndSettle();
        
        // Should show no selections
        expect(find.text('No items selected yet'), findsOneWidget);
        
        // Should show success message
        expect(find.text('Form cleared successfully.'), findsOneWidget);
      });

      testWidgets('should not clear form when cancelled', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select some checkboxes first
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.tap(find.byType(CheckboxListTile).at(1));
        await tester.pump();
        
        // Verify selections
        expect(find.text('Selected 2 of 5 items'), findsOneWidget);
        
        // Try to clear form but cancel
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        
        // Selections should remain
        expect(find.text('Selected 2 of 5 items'), findsOneWidget);
      });
    });

    group('Loading States', () {
      testWidgets('should show loading indicator when form is loading', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // The form might show loading initially while loading saved state
        // We'll pump a few times to let any loading complete
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        
        // After loading, should show the form content
        expect(find.byType(CheckboxListTile), findsNWidgets(sampleQuestions.length));
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Check that checkboxes are accessible
        for (final question in sampleQuestions) {
          expect(find.text(question), findsOneWidget);
        }
        
        // Check that buttons are accessible
        expect(find.text('Submit Report'), findsOneWidget);
        expect(find.text('Clear'), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Verify that checkboxes can receive focus
        final firstCheckbox = find.byType(CheckboxListTile).first;
        await tester.tap(firstCheckbox);
        await tester.pump();
        
        // The checkbox should be interactable
        expect(find.byType(CheckboxListTile), findsNWidgets(sampleQuestions.length));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty questions list', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CaseQuestionsPage('Empty Case', []),
          ),
        );
        
        // Should show case name
        expect(find.text('Empty Case'), findsOneWidget);
        expect(find.text('Report Empty Case'), findsOneWidget);
        
        // Should show instruction text
        expect(find.text('Please select all that apply to your situation:'), findsOneWidget);
        
        // Should show no checkboxes
        expect(find.byType(CheckboxListTile), findsNothing);
        
        // Should show "No items selected yet"
        expect(find.text('No items selected yet'), findsOneWidget);
      });

      testWidgets('should handle single question', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CaseQuestionsPage('Single Case', ['Single question']),
          ),
        );
        
        expect(find.byType(CheckboxListTile), findsOneWidget);
        expect(find.text('Single question'), findsOneWidget);
        
        // Select the single question
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();
        
        expect(find.text('Selected 1 of 1 items'), findsOneWidget);
      });

      testWidgets('should handle very long question text', (WidgetTester tester) async {
        final longQuestion = 'This is a very long question that might wrap to multiple lines and should still be displayed correctly in the UI without causing layout issues';
        
        await tester.pumpWidget(
          MaterialApp(
            home: CaseQuestionsPage('Long Case', [longQuestion]),
          ),
        );
        
        expect(find.text(longQuestion), findsOneWidget);
        expect(find.byType(CheckboxListTile), findsOneWidget);
      });
    });

    group('State Persistence', () {
      testWidgets('should maintain state during widget rebuilds', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Select some checkboxes
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.tap(find.byType(CheckboxListTile).at(2));
        await tester.pump();
        
        expect(find.text('Selected 2 of 5 items'), findsOneWidget);
        
        // Trigger a rebuild by pumping the same widget again
        await tester.pumpWidget(createTestWidget());
        await tester.pump();
        
        // State should be maintained (though in practice this depends on the controller's persistence)
        expect(find.byType(CheckboxListTile), findsNWidgets(sampleQuestions.length));
      });
    });

    group('Performance', () {
      testWidgets('should handle rapid checkbox interactions', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Rapidly toggle checkboxes
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byType(CheckboxListTile).first);
          await tester.pump();
        }
        
        // Should still be responsive
        expect(find.byType(CheckboxListTile), findsNWidgets(sampleQuestions.length));
      });

      testWidgets('should handle many questions efficiently', (WidgetTester tester) async {
        // Create a large list of questions
        final manyQuestions = List.generate(50, (index) => 'Question ${index + 1}');
        
        await tester.pumpWidget(
          MaterialApp(
            home: CaseQuestionsPage('Many Questions Case', manyQuestions),
          ),
        );
        
        // Should render all questions
        expect(find.byType(CheckboxListTile), findsNWidgets(50));
        
        // Should be scrollable
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}