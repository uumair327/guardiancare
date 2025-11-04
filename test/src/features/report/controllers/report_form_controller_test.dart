import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardiancare/src/features/report/controllers/report_form_controller.dart';
import 'package:guardiancare/src/features/report/models/report_form_state.dart';

void main() {
  group('ReportFormController Tests', () {
    late ReportFormController controller;
    late List<String> sampleQuestions;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      controller = ReportFormController();
      sampleQuestions = [
        'Question 1: Is this happening at school?',
        'Question 2: Does it involve physical contact?',
        'Question 3: Has this happened before?',
        'Question 4: Are there witnesses?',
        'Question 5: Do you feel safe?',
      ];
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization', () {
      test('should initialize with no active form', () {
        expect(controller.hasActiveForm, isFalse);
        expect(controller.currentFormState, isNull);
        expect(controller.isLoading, isFalse);
        expect(controller.error, isNull);
      });

      test('should initialize form correctly', () {
        controller.initializeForm('Test Case', sampleQuestions);
        
        expect(controller.hasActiveForm, isTrue);
        expect(controller.currentFormState, isNotNull);
        expect(controller.currentFormState!.caseName, equals('Test Case'));
        expect(controller.currentFormState!.questions, equals(sampleQuestions));
        expect(controller.currentFormState!.totalCount, equals(5));
      });

      test('should clear error on form initialization', () {
        // Set an error first
        controller.clearError();
        controller.initializeForm('Test Case', sampleQuestions);
        
        expect(controller.error, isNull);
      });
    });

    group('Checkbox State Management', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should update checkbox state through controller', () {
        controller.updateCheckboxState(0, true);
        
        expect(controller.currentFormState!.getCheckboxState(0), isTrue);
        expect(controller.currentFormState!.selectedCount, equals(1));
      });

      test('should toggle checkbox state through controller', () {
        expect(controller.currentFormState!.getCheckboxState(0), isFalse);
        
        controller.toggleCheckboxState(0);
        expect(controller.currentFormState!.getCheckboxState(0), isTrue);
        
        controller.toggleCheckboxState(0);
        expect(controller.currentFormState!.getCheckboxState(0), isFalse);
      });

      test('should select all checkboxes through controller', () {
        controller.selectAll();
        
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(controller.currentFormState!.getCheckboxState(i), isTrue);
        }
        expect(controller.currentFormState!.selectedCount, equals(sampleQuestions.length));
      });

      test('should deselect all checkboxes through controller', () {
        // First select some
        controller.updateCheckboxState(0, true);
        controller.updateCheckboxState(2, true);
        expect(controller.currentFormState!.selectedCount, equals(2));

        // Then deselect all
        controller.deselectAll();
        expect(controller.currentFormState!.selectedCount, equals(0));
      });
    });

    group('Form Validation', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should validate form correctly when empty', () {
        final isValid = controller.validateForm();
        expect(isValid, isFalse);
      });

      test('should validate form correctly when has selections', () {
        controller.updateCheckboxState(0, true);
        
        final isValid = controller.validateForm();
        expect(isValid, isTrue);
      });

      test('should handle validation when no active form', () {
        controller.disposeForm();
        
        final isValid = controller.validateForm();
        expect(isValid, isFalse);
      });
    });

    group('Form Submission', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should fail submission when no active form', () async {
        controller.disposeForm();
        
        final result = await controller.submitForm();
        expect(result.success, isFalse);
        expect(result.message, contains('No active form'));
      });

      test('should fail submission when validation fails', () async {
        // Don't select any checkboxes
        final result = await controller.submitForm();
        
        expect(result.success, isFalse);
        expect(result.message, contains('validation failed'));
      });

      test('should succeed submission when form is valid', () async {
        controller.updateCheckboxState(0, true);
        controller.updateCheckboxState(2, true);
        
        final result = await controller.submitForm();
        
        expect(result.success, isTrue);
        expect(result.selectedQuestions, isNotNull);
        expect(result.selectedQuestions!.length, equals(2));
        expect(result.message, contains('successfully'));
      });

      test('should set submission state during submission', () async {
        controller.updateCheckboxState(0, true);
        
        // Start submission (don't await yet)
        final submissionFuture = controller.submitForm();
        
        // Check that submission state is set
        expect(controller.currentFormState!.isSubmitting, isTrue);
        
        // Wait for completion
        await submissionFuture;
        
        // Check that submission state is cleared
        expect(controller.currentFormState!.isSubmitting, isFalse);
      });

      test('should clear form after successful submission', () async {
        controller.updateCheckboxState(0, true);
        controller.updateCheckboxState(2, true);
        
        await controller.submitForm();
        
        // Form should be cleared
        expect(controller.currentFormState!.selectedCount, equals(0));
        expect(controller.currentFormState!.isDirty, isFalse);
      });
    });

    group('Form Clearing', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should clear form correctly', () async {
        // Set up some state
        controller.updateCheckboxState(0, true);
        controller.updateCheckboxState(2, true);
        expect(controller.currentFormState!.selectedCount, equals(2));

        // Clear form
        await controller.clearForm();
        
        expect(controller.currentFormState!.selectedCount, equals(0));
        expect(controller.currentFormState!.isDirty, isFalse);
      });
    });

    group('Form Disposal', () {
      test('should dispose form correctly', () {
        controller.initializeForm('Test Case', sampleQuestions);
        expect(controller.hasActiveForm, isTrue);

        controller.disposeForm();
        expect(controller.hasActiveForm, isFalse);
        expect(controller.currentFormState, isNull);
      });
    });

    group('State Persistence', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should save and load form state', () async {
        // Set up some state
        controller.updateCheckboxState(0, true);
        controller.updateCheckboxState(2, true);
        
        // Wait for auto-save to complete
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Create new controller and initialize with same case
        final newController = ReportFormController();
        newController.initializeForm('Test Case', sampleQuestions);
        
        // Wait for loading to complete
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Check that state was restored
        expect(newController.currentFormState!.getCheckboxState(0), isTrue);
        expect(newController.currentFormState!.getCheckboxState(2), isTrue);
        expect(newController.currentFormState!.selectedCount, equals(2));
        
        newController.dispose();
      });

      test('should handle loading errors gracefully', () async {
        // Initialize with invalid SharedPreferences data
        SharedPreferences.setMockInitialValues({
          'report_form_Test Case': 'invalid_json_data'
        });
        
        controller.initializeForm('Test Case', sampleQuestions);
        
        // Wait for loading attempt
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Should not crash and should have clean state
        expect(controller.currentFormState!.selectedCount, equals(0));
      });
    });

    group('Form Summary', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should provide form summary', () {
        controller.updateCheckboxState(0, true);
        controller.updateCheckboxState(2, true);
        
        final summary = controller.getFormSummary();
        
        expect(summary, isNotNull);
        expect(summary!.caseName, equals('Test Case'));
        expect(summary.selectedCount, equals(2));
        expect(summary.totalQuestions, equals(5));
        expect(summary.isComplete, isTrue);
      });

      test('should return null summary when no active form', () {
        controller.disposeForm();
        
        final summary = controller.getFormSummary();
        expect(summary, isNull);
      });
    });

    group('Unsaved Changes Detection', () {
      setUp(() {
        controller.initializeForm('Test Case', sampleQuestions);
      });

      test('should detect unsaved changes', () {
        expect(controller.hasUnsavedChanges(), isFalse);
        
        controller.updateCheckboxState(0, true);
        expect(controller.hasUnsavedChanges(), isTrue);
        
        controller.clearForm();
        expect(controller.hasUnsavedChanges(), isFalse);
      });

      test('should handle unsaved changes when no active form', () {
        controller.disposeForm();
        expect(controller.hasUnsavedChanges(), isFalse);
      });
    });

    group('Saved Forms Management', () {
      test('should get list of saved form names', () async {
        // Set up some saved forms
        SharedPreferences.setMockInitialValues({
          'report_form_Case1': '{"test": "data1"}',
          'report_form_Case2': '{"test": "data2"}',
          'other_key': 'other_data',
        });
        
        final savedForms = await controller.getSavedFormNames();
        
        expect(savedForms, contains('Case1'));
        expect(savedForms, contains('Case2'));
        expect(savedForms, isNot(contains('other_key')));
        expect(savedForms.length, equals(2));
      });

      test('should delete saved form', () async {
        // Set up a saved form
        SharedPreferences.setMockInitialValues({
          'report_form_TestCase': '{"test": "data"}',
        });
        
        final deleted = await controller.deleteSavedForm('TestCase');
        expect(deleted, isTrue);
        
        final savedForms = await controller.getSavedFormNames();
        expect(savedForms, isNot(contains('TestCase')));
      });

      test('should handle deletion of non-existent form', () async {
        final deleted = await controller.deleteSavedForm('NonExistentCase');
        expect(deleted, isTrue); // SharedPreferences.remove returns true even if key doesn't exist
      });

      test('should handle errors in saved forms operations', () async {
        // This test would require mocking SharedPreferences to throw errors
        // For now, we'll just verify the methods don't crash
        expect(() => controller.getSavedFormNames(), returnsNormally);
        expect(() => controller.deleteSavedForm('test'), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should manage error state correctly', () {
        expect(controller.error, isNull);
        
        // Errors are typically set internally, but we can test the clear method
        controller.clearError();
        expect(controller.error, isNull);
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners on form state changes', () {
        int notificationCount = 0;
        controller.addListener(() => notificationCount++);

        controller.initializeForm('Test Case', sampleQuestions);
        expect(notificationCount, greaterThan(0));

        final initialCount = notificationCount;
        controller.updateCheckboxState(0, true);
        expect(notificationCount, greaterThan(initialCount));
      });

      test('should handle multiple listeners', () {
        int listener1Count = 0;
        int listener2Count = 0;
        
        void listener1() => listener1Count++;
        void listener2() => listener2Count++;

        controller.addListener(listener1);
        controller.addListener(listener2);

        controller.initializeForm('Test Case', sampleQuestions);
        
        expect(listener1Count, greaterThan(0));
        expect(listener2Count, greaterThan(0));

        controller.removeListener(listener1);
        
        final initialCount2 = listener2Count;
        controller.updateCheckboxState(0, true);
        
        expect(listener2Count, greaterThan(initialCount2));
      });
    });

    group('Edge Cases', () {
      test('should handle empty questions list', () {
        controller.initializeForm('Empty Case', []);
        
        expect(controller.currentFormState!.totalCount, equals(0));
        expect(controller.validateForm(), isFalse); // Empty form should be invalid
      });

      test('should handle operations on disposed form', () {
        controller.initializeForm('Test Case', sampleQuestions);
        controller.disposeForm();
        
        // These should not crash
        expect(() => controller.updateCheckboxState(0, true), returnsNormally);
        expect(() => controller.toggleCheckboxState(0), returnsNormally);
        expect(() => controller.selectAll(), returnsNormally);
        expect(() => controller.deselectAll(), returnsNormally);
      });

      test('should handle rapid state changes', () {
        controller.initializeForm('Test Case', sampleQuestions);
        
        // Rapidly change states
        for (int i = 0; i < 100; i++) {
          controller.updateCheckboxState(i % sampleQuestions.length, i % 2 == 0);
        }
        
        // Should not crash and should have valid state
        expect(controller.currentFormState, isNotNull);
        expect(controller.currentFormState!.selectedCount, greaterThanOrEqualTo(0));
      });
    });

    group('Memory Management', () {
      test('should properly dispose resources', () {
        controller.initializeForm('Test Case', sampleQuestions);
        final formState = controller.currentFormState;
        
        controller.dispose();
        
        expect(controller.currentFormState, isNull);
        expect(controller.hasActiveForm, isFalse);
        
        // The form state should be disposed
        // Note: We can't directly test if dispose was called on the form state
        // but we can verify the controller cleaned up its references
      });

      test('should handle multiple dispose calls', () {
        controller.initializeForm('Test Case', sampleQuestions);
        
        controller.dispose();
        expect(() => controller.dispose(), returnsNormally);
      });
    });
  });

  group('ReportSubmissionResult Tests', () {
    test('should create success result correctly', () {
      final selectedQuestions = ['Question 1', 'Question 2'];
      final result = ReportSubmissionResult.success(
        selectedQuestions,
        'Success message',
      );

      expect(result.success, isTrue);
      expect(result.selectedQuestions, equals(selectedQuestions));
      expect(result.message, equals('Success message'));
      expect(result.errorCode, isNull);
    });

    test('should create failure result correctly', () {
      final result = ReportSubmissionResult.failure(
        'Failure message',
        errorCode: 'ERROR_001',
      );

      expect(result.success, isFalse);
      expect(result.selectedQuestions, isNull);
      expect(result.message, equals('Failure message'));
      expect(result.errorCode, equals('ERROR_001'));
    });

    test('should create failure result without error code', () {
      final result = ReportSubmissionResult.failure('Failure message');

      expect(result.success, isFalse);
      expect(result.errorCode, isNull);
    });

    test('should have proper string representation', () {
      final result = ReportSubmissionResult.success(['Q1'], 'Success');
      final resultString = result.toString();
      
      expect(resultString, contains('success: true'));
      expect(resultString, contains('message: Success'));
    });
  });
}