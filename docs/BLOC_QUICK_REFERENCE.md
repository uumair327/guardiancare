# BLoC Quick Reference Guide

Quick reference for using the new BLoC implementations in GuardianCare.

## How to Use BLoC Widgets

### Quiz Feature

**Old Way (Legacy):**
```dart
import 'package:guardiancare/src/features/quiz/screens/quiz_questions_page.dart';

// Use legacy version
QuizQuestionsPage(questions: questions)
```

**New Way (BLoC):**
```dart
import 'package:guardiancare/src/features/quiz/screens/quiz_questions_page_bloc.dart';

// Use BLoC version
QuizQuestionsPageBloc(questions: questions)
```

### Forum Feature

**Old Way (Legacy):**
```dart
import 'package:guardiancare/src/features/forum/widgets/comment_input.dart';

// Use legacy version
CommentInput(
  forumId: forumId,
  onCommentAdded: () => _refreshComments(),
)
```

**New Way (BLoC):**
```dart
import 'package:guardiancare/src/features/forum/widgets/comment_input_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_bloc.dart';

// Provide BLoC and use BLoC version
BlocProvider(
  create: (_) => CommentBloc()..add(LoadComments(forumId)),
  child: CommentInputBloc(
    forumId: forumId,
    onCommentAdded: () => _refreshComments(),
  ),
)
```

### Report Feature

**Old Way (Legacy):**
```dart
import 'package:guardiancare/src/features/report/screens/case_questions_page.dart';

// Use legacy version
CaseQuestionsPage(caseName, questions)
```

**New Way (BLoC):**
```dart
import 'package:guardiancare/src/features/report/screens/case_questions_page_bloc.dart';

// Use BLoC version (BLoC is provided internally)
CaseQuestionsPageBloc(caseName, questions)
```

### Consent Feature

**Old Way (Legacy):**
```dart
import 'package:guardiancare/src/features/consent/screens/consent_form.dart';

// Use legacy version
ConsentForm(
  controller: controller,
  onSubmit: () => _handleSubmit(),
  consentController: consentController,
)
```

**New Way (BLoC):**
```dart
import 'package:guardiancare/src/features/consent/screens/consent_form_bloc.dart';

// Use BLoC version (BLoC is provided internally)
ConsentFormBloc(
  controller: controller,
  onSubmit: () => _handleSubmit(),
  consentController: consentController,
)
```

## BLoC Events Reference

### QuizBloc Events
```dart
// Select an answer
context.read<QuizBloc>().add(AnswerSelected(questionIndex, answer));

// Mark feedback as shown
context.read<QuizBloc>().add(FeedbackShown(questionIndex));

// Navigate to question
context.read<QuizBloc>().add(NavigateToQuestion(questionIndex));

// Next/Previous question
context.read<QuizBloc>().add(const NextQuestion());
context.read<QuizBloc>().add(const PreviousQuestion());

// Complete quiz
context.read<QuizBloc>().add(const QuizCompleted());

// Reset quiz
context.read<QuizBloc>().add(const QuizReset());
```

### CommentBloc Events
```dart
// Load comments
context.read<CommentBloc>().add(LoadComments(postId));

// Submit comment
context.read<CommentBloc>().add(SubmitComment(postId, content));

// Delete comment
context.read<CommentBloc>().add(DeleteComment(commentId));

// Refresh comments
context.read<CommentBloc>().add(RefreshComments(postId));
```

### ReportBloc Events
```dart
// Create new report
context.read<ReportBloc>().add(CreateReport(caseName, questions));

// Load existing report
context.read<ReportBloc>().add(LoadReport(caseName));

// Update answer
context.read<ReportBloc>().add(UpdateAnswer(questionIndex, isChecked));

// Save report
context.read<ReportBloc>().add(const SaveReport());

// Delete report
context.read<ReportBloc>().add(DeleteReport(caseName));

// Load saved reports
context.read<ReportBloc>().add(const LoadSavedReports());

// Clear report
context.read<ReportBloc>().add(const ClearReport());
```

### ConsentBloc Events
```dart
// Validate individual fields
context.read<ConsentBloc>().add(ValidateChildName(name));
context.read<ConsentBloc>().add(ValidateChildAge(age));
context.read<ConsentBloc>().add(ValidateParentName(name));
context.read<ConsentBloc>().add(ValidateParentEmail(email));
context.read<ConsentBloc>().add(ValidateParentalKey(key));
context.read<ConsentBloc>().add(ValidateSecurityQuestion(question));
context.read<ConsentBloc>().add(ValidateSecurityAnswer(answer));

// Validate all fields
context.read<ConsentBloc>().add(ValidateAllFields({
  'childName': nameController.text,
  'parentEmail': emailController.text,
  // ... other fields
}));

// Reset validation
context.read<ConsentBloc>().add(const ResetValidation());
```

## BLoC State Handling

### Using BlocBuilder
```dart
BlocBuilder<QuizBloc, QuizState>(
  builder: (context, state) {
    // Access state properties
    final currentQuestion = state.currentQuestionIndex;
    final isAnswered = state.selectedAnswers.containsKey(currentQuestion);
    
    return YourWidget();
  },
)
```

### Using BlocListener
```dart
BlocListener<CommentBloc, CommentState>(
  listener: (context, state) {
    if (state is CommentSubmitted) {
      // Handle success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment submitted!')),
      );
    } else if (state is CommentError) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

### Using BlocConsumer (Builder + Listener)
```dart
BlocConsumer<ReportBloc, ReportState>(
  listener: (context, state) {
    // Handle side effects
    if (state is ReportSaved) {
      Navigator.pop(context);
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state is ReportLoading) {
      return CircularProgressIndicator();
    }
    return YourWidget();
  },
)
```

## Accessing State

### Get Current State
```dart
final quizState = context.read<QuizBloc>().state;
final currentQuestion = quizState.currentQuestionIndex;
```

### Watch State Changes
```dart
final quizState = context.watch<QuizBloc>().state;
// Widget rebuilds when state changes
```

### Select Specific State Property
```dart
final currentQuestion = context.select(
  (QuizBloc bloc) => bloc.state.currentQuestionIndex,
);
// Only rebuilds when currentQuestionIndex changes
```

## Common Patterns

### Loading State
```dart
if (state is ReportLoading) {
  return Center(child: CircularProgressIndicator());
}
```

### Error State
```dart
if (state is CommentError) {
  return ErrorWidget(message: state.message);
}
```

### Success State
```dart
if (state is ReportSaved) {
  return SuccessWidget();
}
```

### Conditional Rendering
```dart
BlocBuilder<QuizBloc, QuizState>(
  builder: (context, state) {
    return ElevatedButton(
      onPressed: state.selectedAnswers.containsKey(currentIndex)
          ? () => _submit()
          : null,
      child: Text('Submit'),
    );
  },
)
```

## Logging

All BLoC widgets use AppLogger for debugging:

```dart
import 'package:guardiancare/src/core/logging/app_logger.dart';

// Log BLoC events
AppLogger.bloc('QuizBloc', 'AnswerSelected', state: 'Question 0: Answer A');

// Log features
AppLogger.feature('Quiz', 'Quiz completed with 8/10 correct');

// Log errors
AppLogger.error('Forum', 'Failed to submit comment', error: e);

// Log debug info
AppLogger.debug('Report', 'Form state updated');
```

## Migration Checklist

When migrating a screen to use BLoC:

- [ ] Import BLoC version instead of legacy
- [ ] Replace ChangeNotifierProvider with BlocProvider
- [ ] Replace Consumer with BlocBuilder
- [ ] Replace method calls with event dispatches
- [ ] Add BlocListener for side effects
- [ ] Update tests to use BLoC
- [ ] Test thoroughly
- [ ] Remove legacy imports

## Tips

1. **Always provide BLoC at the top level** of your widget tree
2. **Use BlocConsumer** when you need both listener and builder
3. **Use context.read** for one-time actions (dispatching events)
4. **Use context.watch** for reactive updates
5. **Use context.select** for optimized rebuilds
6. **Add logging** for better debugging
7. **Handle all state types** (loading, success, error)
8. **Test state transitions** independently

## Resources

- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Flutter BLoC Package](https://pub.dev/packages/flutter_bloc)
- [Migration Guide](./BLOC_MIGRATION_GUIDE.md)
- [Complete Documentation](./BLOC_MIGRATION_COMPLETE.md)

## Support

For questions or issues:
1. Check the migration guide
2. Review existing BLoC implementations
3. Check the complete documentation
4. Consult the team

---

**Last Updated**: [Current Date]
**Version**: 1.0
**Status**: Production Ready ✅
