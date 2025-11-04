import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/report/models/report_form_state.dart';

void main() {
  group('ReportFormState Tests', () {
    late ReportFormState formState;
    late List<String> sampleQuestions;

    setUp(() {
      sampleQuestions = [
        'Question 1: Is this happening at school?',
        'Question 2: Does it involve physical contact?',
        'Question 3: Has this happened before?',
        'Question 4: Are there witnesses?',
        'Question 5: Do you feel safe?',
      ];
      
      formState = ReportFormState(
        caseName: 'Test Case',
        questions: sampleQuestions,
      );
    });

    tearDown(() {
      formState.dispose();
    });

    group('Initialization', () {
      test('should initialize with correct case name and questions', () {
        expect(formState.caseName, equals('Test Case'));
        expect(formState.questions, equals(sampleQuestions));
        expect(formState.totalCount, equals(5));
      });

      test('should initialize all checkboxes as unchecked', () {
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(formState.getCheckboxState(i), isFalse);
        }
        expect(formState.selectedCount, equals(0));
        expect(formState.hasSelections, isFalse);
      });

      test('should initialize with clean state', () {
        expect(formState.isDirty, isFalse);
        expect(formState.isSubmitting, isFalse);
        expect(formState.validationError, isNull);
      });
    });

    group('Checkbox State Management', () {
      test('should update checkbox state correctly', () {
        formState.updateCheckboxState(0, true);
        expect(formState.getCheckboxState(0), isTrue);
        expect(formState.selectedCount, equals(1));
        expect(formState.hasSelections, isTrue);
        expect(formState.isDirty, isTrue);
      });

      test('should handle multiple checkbox updates', () {
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);
        formState.updateCheckboxState(4, true);

        expect(formState.getCheckboxState(0), isTrue);
        expect(formState.getCheckboxState(1), isFalse);
        expect(formState.getCheckboxState(2), isTrue);
        expect(formState.getCheckboxState(3), isFalse);
        expect(formState.getCheckboxState(4), isTrue);
        expect(formState.selectedCount, equals(3));
      });

      test('should toggle checkbox state correctly', () {
        expect(formState.getCheckboxState(0), isFalse);
        
        formState.toggleCheckboxState(0);
        expect(formState.getCheckboxState(0), isTrue);
        
        formState.toggleCheckboxState(0);
        expect(formState.getCheckboxState(0), isFalse);
      });

      test('should handle invalid checkbox indices gracefully', () {
        expect(() => formState.updateCheckboxState(-1, true), throwsArgumentError);
        expect(() => formState.updateCheckboxState(10, true), throwsArgumentError);
        
        // Getting invalid indices should return false
        expect(formState.getCheckboxState(-1), isFalse);
        expect(formState.getCheckboxState(10), isFalse);
      });

      test('should not trigger change notification for same value', () {
        int notificationCount = 0;
        formState.addListener(() => notificationCount++);

        formState.updateCheckboxState(0, false); // Same as initial value
        expect(notificationCount, equals(0));

        formState.updateCheckboxState(0, true); // Different value
        expect(notificationCount, equals(1));

        formState.updateCheckboxState(0, true); // Same as current value
        expect(notificationCount, equals(1));
      });
    });

    group('Bulk Operations', () {
      test('should select all checkboxes', () {
        formState.selectAll();
        
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(formState.getCheckboxState(i), isTrue);
        }
        expect(formState.selectedCount, equals(sampleQuestions.length));
        expect(formState.isDirty, isTrue);
      });

      test('should deselect all checkboxes', () {
        // First select some checkboxes
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);
        expect(formState.selectedCount, equals(2));

        // Then deselect all
        formState.deselectAll();
        
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(formState.getCheckboxState(i), isFalse);
        }
        expect(formState.selectedCount, equals(0));
      });

      test('should not trigger notification if no changes in bulk operations', () {
        int notificationCount = 0;
        formState.addListener(() => notificationCount++);

        // Deselect all when already deselected
        formState.deselectAll();
        expect(notificationCount, equals(0));

        // Select all
        formState.selectAll();
        expect(notificationCount, equals(1));

        // Select all again when already selected
        formState.selectAll();
        expect(notificationCount, equals(1));
      });
    });

    group('Selected Data Retrieval', () {
      test('should return correct selected indices', () {
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);
        formState.updateCheckboxState(4, true);

        final selectedIndices = formState.selectedIndices;
        expect(selectedIndices, equals([0, 2, 4]));
      });

      test('should return correct selected questions', () {
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);

        final selectedQuestions = formState.selectedQuestions;
        expect(selectedQuestions, equals([
          'Question 1: Is this happening at school?',
          'Question 3: Has this happened before?',
        ]));
      });

      test('should return empty lists when nothing selected', () {
        expect(formState.selectedIndices, isEmpty);
        expect(formState.selectedQuestions, isEmpty);
      });
    });

    group('Form Validation', () {
      test('should fail validation when no items selected', () {
        final isValid = formState.validateForm();
        expect(isValid, isFalse);
        expect(formState.validationError, isNotNull);
        expect(formState.validationError, contains('at least one item'));
      });

      test('should pass validation when items are selected', () {
        formState.updateCheckboxState(0, true);
        
        final isValid = formState.validateForm();
        expect(isValid, isTrue);
        expect(formState.validationError, isNull);
      });

      test('should clear validation error when checkbox state changes', () {
        // Trigger validation error
        formState.validateForm();
        expect(formState.validationError, isNotNull);

        // Change checkbox state should clear error
        formState.updateCheckboxState(0, true);
        expect(formState.validationError, isNull);
      });
    });

    group('Submission State', () {
      test('should manage submission state correctly', () {
        expect(formState.isSubmitting, isFalse);

        formState.setSubmissionState(true);
        expect(formState.isSubmitting, isTrue);

        formState.setSubmissionState(false);
        expect(formState.isSubmitting, isFalse);
      });

      test('should trigger notification on submission state change', () {
        int notificationCount = 0;
        formState.addListener(() => notificationCount++);

        formState.setSubmissionState(true);
        expect(notificationCount, equals(1));

        formState.setSubmissionState(false);
        expect(notificationCount, equals(2));

        // Same value should not trigger notification
        formState.setSubmissionState(false);
        expect(notificationCount, equals(2));
      });
    });

    group('Error Handling', () {
      test('should manage validation errors correctly', () {
        expect(formState.validationError, isNull);

        formState.setValidationError('Test error');
        expect(formState.validationError, equals('Test error'));

        formState.setValidationError(null);
        expect(formState.validationError, isNull);
      });

      test('should trigger notification on validation error change', () {
        int notificationCount = 0;
        formState.addListener(() => notificationCount++);

        formState.setValidationError('Error message');
        expect(notificationCount, equals(1));

        formState.setValidationError(null);
        expect(notificationCount, equals(2));

        // Same value should not trigger notification
        formState.setValidationError(null);
        expect(notificationCount, equals(2));
      });
    });

    group('Form Clearing', () {
      test('should clear all form data', () {
        // Set up some state
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);
        formState.setValidationError('Test error');
        formState.setSubmissionState(true);

        // Clear form
        formState.clearForm();

        // Verify everything is cleared
        expect(formState.selectedCount, equals(0));
        expect(formState.isDirty, isFalse);
        expect(formState.validationError, isNull);
        expect(formState.isSubmitting, isFalse);
        
        for (int i = 0; i < sampleQuestions.length; i++) {
          expect(formState.getCheckboxState(i), isFalse);
        }
      });
    });

    group('Persistence (toMap/loadFromMap)', () {
      test('should serialize state to map correctly', () {
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);

        final map = formState.toMap();
        
        expect(map['caseName'], equals('Test Case'));
        expect(map['selectedCount'], equals(2));
        expect(map['isDirty'], isTrue);
        expect(map['checkboxStates'], isA<Map<String, dynamic>>());
        expect(map['timestamp'], isA<String>());
      });

      test('should deserialize state from map correctly', () {
        final testMap = {
          'caseName': 'Test Case',
          'checkboxStates': {
            '0': true,
            '2': true,
            '4': true,
          },
          'isDirty': true,
          'selectedCount': 3,
          'timestamp': DateTime.now().toIso8601String(),
        };

        formState.loadFromMap(testMap);

        expect(formState.getCheckboxState(0), isTrue);
        expect(formState.getCheckboxState(1), isFalse);
        expect(formState.getCheckboxState(2), isTrue);
        expect(formState.getCheckboxState(3), isFalse);
        expect(formState.getCheckboxState(4), isTrue);
        expect(formState.selectedCount, equals(3));
        expect(formState.isDirty, isTrue);
      });

      test('should handle invalid map data gracefully', () {
        final invalidMap = {
          'checkboxStates': {
            'invalid': 'not_boolean',
            '100': true, // Out of range index
          },
          'isDirty': 'not_boolean',
        };

        // Should not throw
        expect(() => formState.loadFromMap(invalidMap), returnsNormally);
        
        // Should maintain valid state
        expect(formState.selectedCount, equals(0));
      });

      test('should handle empty or null map data', () {
        formState.loadFromMap({});
        expect(formState.selectedCount, equals(0));
        
        formState.loadFromMap({'checkboxStates': null});
        expect(formState.selectedCount, equals(0));
      });
    });

    group('Form Summary', () {
      test('should generate correct summary', () {
        formState.updateCheckboxState(0, true);
        formState.updateCheckboxState(2, true);

        final summary = formState.getSummary();
        
        expect(summary.caseName, equals('Test Case'));
        expect(summary.totalQuestions, equals(5));
        expect(summary.selectedCount, equals(2));
        expect(summary.selectedQuestions.length, equals(2));
        expect(summary.isDirty, isTrue);
        expect(summary.hasValidationError, isFalse);
        expect(summary.completionPercentage, equals(0.4)); // 2/5
        expect(summary.isComplete, isTrue);
      });

      test('should generate summary with validation error', () {
        formState.setValidationError('Test error');

        final summary = formState.getSummary();
        
        expect(summary.hasValidationError, isTrue);
        expect(summary.validationError, equals('Test error'));
        expect(summary.statusMessage, equals('Test error'));
      });

      test('should generate correct status messages', () {
        // No selections
        var summary = formState.getSummary();
        expect(summary.statusMessage, equals('No items selected'));

        // Some selections
        formState.updateCheckboxState(0, true);
        summary = formState.getSummary();
        expect(summary.statusMessage, equals('1 of 5 items selected'));

        // All selections
        formState.selectAll();
        summary = formState.getSummary();
        expect(summary.statusMessage, equals('All items selected'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty questions list', () {
        final emptyFormState = ReportFormState(
          caseName: 'Empty Case',
          questions: [],
        );

        expect(emptyFormState.totalCount, equals(0));
        expect(emptyFormState.selectedCount, equals(0));
        expect(emptyFormState.hasSelections, isFalse);
        expect(emptyFormState.selectedIndices, isEmpty);
        expect(emptyFormState.selectedQuestions, isEmpty);

        final summary = emptyFormState.getSummary();
        expect(summary.completionPercentage, equals(0.0));

        emptyFormState.dispose();
      });

      test('should handle single question', () {
        final singleFormState = ReportFormState(
          caseName: 'Single Case',
          questions: ['Single question'],
        );

        expect(singleFormState.totalCount, equals(1));
        
        singleFormState.updateCheckboxState(0, true);
        expect(singleFormState.selectedCount, equals(1));
        expect(singleFormState.getSummary().completionPercentage, equals(1.0));

        singleFormState.dispose();
      });

      test('should handle very long question text', () {
        final longQuestion = 'This is a very long question ' * 50;
        final longFormState = ReportFormState(
          caseName: 'Long Case',
          questions: [longQuestion],
        );

        longFormState.updateCheckboxState(0, true);
        expect(longFormState.selectedQuestions.first, equals(longQuestion));

        longFormState.dispose();
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners on state changes', () {
        int notificationCount = 0;
        formState.addListener(() => notificationCount++);

        formState.updateCheckboxState(0, true);
        expect(notificationCount, equals(1));

        formState.selectAll();
        expect(notificationCount, equals(2));

        formState.clearForm();
        expect(notificationCount, equals(3));
      });

      test('should handle multiple listeners', () {
        int listener1Count = 0;
        int listener2Count = 0;
        
        void listener1() => listener1Count++;
        void listener2() => listener2Count++;

        formState.addListener(listener1);
        formState.addListener(listener2);

        formState.updateCheckboxState(0, true);
        
        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));

        formState.removeListener(listener1);
        formState.updateCheckboxState(1, true);
        
        expect(listener1Count, equals(1)); // Should not increase
        expect(listener2Count, equals(2)); // Should increase
      });
    });
  });

  group('ReportFormSummary Tests', () {
    test('should calculate completion percentage correctly', () {
      const summary = ReportFormSummary(
        caseName: 'Test',
        totalQuestions: 10,
        selectedCount: 3,
        selectedQuestions: [],
        isDirty: false,
        hasValidationError: false,
      );

      expect(summary.completionPercentage, equals(0.3));
    });

    test('should handle zero total questions', () {
      const summary = ReportFormSummary(
        caseName: 'Test',
        totalQuestions: 0,
        selectedCount: 0,
        selectedQuestions: [],
        isDirty: false,
        hasValidationError: false,
      );

      expect(summary.completionPercentage, equals(0.0));
      expect(summary.isComplete, isFalse);
    });

    test('should determine completion status correctly', () {
      const incompleteSum = ReportFormSummary(
        caseName: 'Test',
        totalQuestions: 5,
        selectedCount: 0,
        selectedQuestions: [],
        isDirty: false,
        hasValidationError: false,
      );

      const completeSum = ReportFormSummary(
        caseName: 'Test',
        totalQuestions: 5,
        selectedCount: 3,
        selectedQuestions: [],
        isDirty: false,
        hasValidationError: false,
      );

      expect(incompleteSum.isComplete, isFalse);
      expect(completeSum.isComplete, isTrue);
    });
  });
}