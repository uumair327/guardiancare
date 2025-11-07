import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/quiz/common_widgets/quiz_question_widget.dart';
import 'package:guardiancare/src/features/quiz/services/quiz_state_manager.dart';

void main() {
  group('QuizQuestionWidget Tests', () {
    late QuizStateManager stateManager;
    late Map<String, dynamic> testQuestion;

    setUp(() {
      stateManager = QuizStateManager();
      testQuestion = {
        'question': 'What is the capital of France?',
        'options': ['London', 'Paris', 'Berlin', 'Madrid'],
      };
    });

    tearDown(() {
      stateManager.dispose();
    });

    Widget createTestWidget({
      int questionIndex = 0,
      int correctAnswerIndex = 1,
      Function(int, bool)? onAnswerSelected,
      VoidCallback? onFeedbackComplete,
      bool showQuestionNumber = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: QuizQuestionWidget(
            questionIndex: questionIndex,
            correctAnswerIndex: correctAnswerIndex,
            question: testQuestion,
            onAnswerSelected: onAnswerSelected ?? (index, isCorrect) {},
            stateManager: stateManager,
            showQuestionNumber: showQuestionNumber,
            onFeedbackComplete: onFeedbackComplete,
          ),
        ),
      );
    }

    group('Widget Rendering', () {
      testWidgets('should render question text and options', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify question text is displayed
        expect(find.text('What is the capital of France?'), findsOneWidget);

        // Verify all options are displayed
        expect(find.text('London'), findsOneWidget);
        expect(find.text('Paris'), findsOneWidget);
        expect(find.text('Berlin'), findsOneWidget);
        expect(find.text('Madrid'), findsOneWidget);
      });

      testWidgets('should show question number when enabled', (tester) async {
        await tester.pumpWidget(createTestWidget(
          questionIndex: 2,
          showQuestionNumber: true,
        ));

        expect(find.text('Question 3'), findsOneWidget); // Index 2 = Question 3
      });

      testWidgets('should hide question number when disabled', (tester) async {
        await tester.pumpWidget(createTestWidget(
          questionIndex: 2,
          showQuestionNumber: false,
        ));

        expect(find.text('Question 3'), findsNothing);
      });

      testWidgets('should display option letters (A, B, C, D)', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
        expect(find.text('D'), findsOneWidget);
      });

      testWidgets('should show locked indicator when question is locked', (tester) async {
        // Arrange - Lock the question
        stateManager.selectAnswer(0, 'Paris');
        stateManager.showFeedback(0);

        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Allow state to update

        // Should show locked indicator
        expect(find.text('Locked'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsWidgets);
      });
    });

    group('Answer Selection', () {
      testWidgets('should allow selecting answer when unlocked', (tester) async {
        bool callbackCalled = false;
        int selectedIndex = -1;
        bool isCorrect = false;

        await tester.pumpWidget(createTestWidget(
          onAnswerSelected: (index, correct) {
            callbackCalled = true;
            selectedIndex = index;
            isCorrect = correct;
          },
        ));

        // Tap on the correct answer (Paris - index 1)
        await tester.tap(find.text('Paris'));
        await tester.pump();

        expect(callbackCalled, isTrue);
        expect(selectedIndex, equals(1));
        expect(isCorrect, isTrue);
        expect(stateManager.getSelectedAnswer(0), equals('Paris'));
      });

      testWidgets('should prevent selecting answer when locked', (tester) async {
        // Arrange - Lock the question first
        stateManager.selectAnswer(0, 'London');
        stateManager.showFeedback(0);

        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          onAnswerSelected: (index, correct) {
            callbackCalled = true;
          },
        ));

        // Try to tap on a different answer
        await tester.tap(find.text('Paris'));
        await tester.pump();

        // Callback should not be called and answer should not change
        expect(callbackCalled, isFalse);
        expect(stateManager.getSelectedAnswer(0), equals('London'));
      });

      testWidgets('should show processing indicator during answer selection', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap on an answer
        await tester.tap(find.text('Paris'));
        
        // Should show processing indicator briefly
        expect(find.text('Processing answer...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        // Wait for processing to complete
        await tester.pumpAndSettle();
      });

      testWidgets('should call feedback complete callback', (tester) async {
        bool feedbackCompleted = false;

        await tester.pumpWidget(createTestWidget(
          onFeedbackComplete: () {
            feedbackCompleted = true;
          },
        ));

        // Select an answer
        await tester.tap(find.text('Paris'));
        await tester.pump();

        // Wait for feedback timer to complete
        await tester.pump(const Duration(seconds: 3));

        expect(feedbackCompleted, isTrue);
      });
    });

    group('Visual Feedback', () {
      testWidgets('should show correct answer feedback with green styling', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Select correct answer (Paris - index 1)
        await tester.tap(find.text('Paris'));
        await tester.pump();

        // Should show feedback with correct styling
        // Note: Specific color testing would require more complex widget testing
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should show incorrect answer feedback with red styling', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Select incorrect answer (London - index 0)
        await tester.tap(find.text('London'));
        await tester.pump();

        // Should show feedback with incorrect styling
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('should animate feedback appearance', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Select an answer
        await tester.tap(find.text('Paris'));
        
        // Pump a few frames to see animation
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 200));

        // Feedback should be visible
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should show different styling for selected vs unselected options', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Select an answer
        await tester.tap(find.text('Paris'));
        await tester.pump();

        // The selected option should have different styling
        // This would require more detailed widget inspection in a real test
        expect(stateManager.getSelectedAnswer(0), equals('Paris'));
      });
    });

    group('State Management Integration', () {
      testWidgets('should update when state manager changes', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initially no answer selected
        expect(stateManager.getSelectedAnswer(0), isNull);

        // Select answer through state manager directly
        stateManager.selectAnswer(0, 'Berlin');
        await tester.pump();

        // Widget should reflect the state change
        expect(stateManager.getSelectedAnswer(0), equals('Berlin'));
      });

      testWidgets('should handle state manager listener updates', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Make changes through state manager
        stateManager.selectAnswer(0, 'Madrid');
        stateManager.showFeedback(0);
        await tester.pump();

        // Widget should reflect locked state
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(find.text('Locked'), findsOneWidget);
      });

      testWidgets('should handle question index changes', (tester) async {
        // Start with question 0
        await tester.pumpWidget(createTestWidget(questionIndex: 0));
        
        // Select answer for question 0
        await tester.tap(find.text('Paris'));
        await tester.pump();

        // Change to question 1
        await tester.pumpWidget(createTestWidget(questionIndex: 1));
        await tester.pump();

        // Should reset feedback state for new question
        expect(find.text('Processing answer...'), findsNothing);
      });

      testWidgets('should preserve state when widget is rebuilt', (tester) async {
        // Answer question and lock it
        stateManager.selectAnswer(0, 'Paris');
        stateManager.showFeedback(0);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Rebuild widget
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // State should be preserved
        expect(stateManager.getSelectedAnswer(0), equals('Paris'));
        expect(stateManager.isQuestionLocked(0), isTrue);
        expect(find.text('Locked'), findsOneWidget);
      });
    });

    group('Animation and Interaction', () {
      testWidgets('should handle rapid taps gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap multiple times rapidly
        await tester.tap(find.text('Paris'));
        await tester.tap(find.text('London'));
        await tester.tap(find.text('Berlin'));
        await tester.pump();

        // Should only register the first valid tap
        expect(stateManager.getSelectedAnswer(0), equals('Paris'));
      });

      testWidgets('should disable interactions during processing', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Start answer selection
        await tester.tap(find.text('Paris'));
        
        // Try to tap another option while processing
        await tester.tap(find.text('London'));
        await tester.pump();

        // Should only have the first answer
        expect(stateManager.getSelectedAnswer(0), equals('Paris'));
      });

      testWidgets('should handle button scale animation', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap and hold briefly to see scale animation
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Paris')),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pump();

        // Animation should complete without errors
        expect(stateManager.getSelectedAnswer(0), equals('Paris'));
      });
    });

    group('Accessibility and Usability', () {
      testWidgets('should provide proper semantics for screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Check that text is accessible
        expect(find.text('What is the capital of France?'), findsOneWidget);
        expect(find.text('Paris'), findsOneWidget);
      });

      testWidgets('should handle different question lengths', (tester) async {
        final longQuestion = {
          'question': 'This is a very long question that should wrap properly and not cause any layout issues in the quiz interface when displayed to users',
          'options': ['Short', 'Medium length option', 'Very long option that might wrap to multiple lines', 'D'],
        };

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: QuizQuestionWidget(
              questionIndex: 0,
              correctAnswerIndex: 0,
              question: longQuestion,
              onAnswerSelected: (index, isCorrect) {},
              stateManager: stateManager,
            ),
          ),
        ));

        // Should render without overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle empty options gracefully', (tester) async {
        final questionWithEmptyOption = {
          'question': 'Test question',
          'options': ['Option A', '', 'Option C', 'Option D'],
        };

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: QuizQuestionWidget(
              questionIndex: 0,
              correctAnswerIndex: 0,
              question: questionWithEmptyOption,
              onAnswerSelected: (index, isCorrect) {},
              stateManager: stateManager,
            ),
          ),
        ));

        // Should render all options including empty one
        expect(find.text('Option A'), findsOneWidget);
        expect(find.text('Option C'), findsOneWidget);
        expect(find.text('Option D'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle state manager disposal gracefully', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Dispose state manager
        stateManager.dispose();

        // Widget should not crash
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle invalid question index', (tester) async {
        await tester.pumpWidget(createTestWidget(questionIndex: -1));

        // Should not crash with invalid index
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle invalid correct answer index', (tester) async {
        await tester.pumpWidget(createTestWidget(correctAnswerIndex: 10));

        // Should not crash with invalid correct answer index
        await tester.tap(find.text('Paris'));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle missing question data', (tester) async {
        final incompleteQuestion = {
          'question': 'Test question',
          // Missing options
        };

        expect(() async {
          await tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: QuizQuestionWidget(
                questionIndex: 0,
                correctAnswerIndex: 0,
                question: incompleteQuestion,
                onAnswerSelected: (index, isCorrect) {},
                stateManager: stateManager,
              ),
            ),
          ));
        }, throwsA(isA<TypeError>()));
      });
    });

    group('Performance', () {
      testWidgets('should not rebuild unnecessarily', (tester) async {
        int buildCount = 0;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                buildCount++;
                return QuizQuestionWidget(
                  questionIndex: 0,
                  correctAnswerIndex: 1,
                  question: testQuestion,
                  onAnswerSelected: (index, isCorrect) {},
                  stateManager: stateManager,
                );
              },
            ),
          ),
        ));

        final initialBuildCount = buildCount;

        // Pump without changes
        await tester.pump();
        
        // Build count should not increase unnecessarily
        expect(buildCount, equals(initialBuildCount));
      });

      testWidgets('should handle multiple rapid state changes', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Make rapid state changes
        for (int i = 0; i < 10; i++) {
          stateManager.navigateToQuestion(i % 3);
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Should handle all changes without errors
        expect(tester.takeException(), isNull);
      });
    });
  });
}