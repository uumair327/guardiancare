# BLoC Migration Guide

This guide helps you migrate from Provider/ChangeNotifier to BLoC pattern in the GuardianCare app.

## Overview

We've migrated from Provider/ChangeNotifier to BLoC (Business Logic Component) pattern for better state management, testability, and maintainability.

## Migration Status

### ✅ Completed
- **Learn Feature**: Already using LearnBloc
- **Quiz Feature**: QuizBloc created (replaces QuizStateManager)
- **Forum Feature**: CommentBloc created (replaces CommentController)
- **Report Feature**: ReportBloc created (replaces ReportFormController)
- **Consent Feature**: ConsentBloc created (replaces ConsentFormValidationService)

### 🔄 In Progress
- UI widgets still using legacy Provider/ChangeNotifier
- Need to update widget implementations

### ❌ Legacy (To be removed after migration)
- `QuizStateManager` (use `QuizBloc` instead)
- `CommentController` (use `CommentBloc` instead)
- `ReportFormController` (use `ReportBloc` instead)
- `ConsentFormValidationService` validation state (use `ConsentBloc` instead)

## Migration Examples

### Quiz Feature Migration

#### Before (Provider/ChangeNotifier):
```dart
// Old way with Provider
class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizStateManager(),
      child: Consumer<QuizStateManager>(
        builder: (context, quizState, child) {
          return Text('Question ${quizState.currentQuestionIndex}');
        },
      ),
    );
  }
}

// Selecting an answer
context.read<QuizStateManager>().selectAnswer(0, 'Answer A');
```

#### After (BLoC):
```dart
// New way with BLoC
class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(),
      child: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          return Text('Question ${state.currentQuestionIndex}');
        },
      ),
    );
  }
}

// Selecting an answer
context.read<QuizBloc>().add(AnswerSelected(0, 'Answer A'));
```

### Forum Feature Migration

#### Before (Provider/ChangeNotifier):
```dart
// Old way
ChangeNotifierProvider(
  create: (_) => CommentController(),
  child: Consumer<CommentController>(
    builder: (context, controller, child) {
      if (controller.isLoading) {
        return CircularProgressIndicator();
      }
      return ListView(children: controller.comments);
    },
  ),
);

// Submitting a comment
await context.read<CommentController>().submitComment(postId, content);
```

#### After (BLoC):
```dart
// New way
BlocProvider(
  create: (_) => CommentBloc()..add(LoadComments(postId)),
  child: BlocBuilder<CommentBloc, CommentState>(
    builder: (context, state) {
      if (state is CommentLoading) {
        return CircularProgressIndicator();
      }
      if (state is CommentLoaded) {
        return ListView(children: state.comments);
      }
      return SizedBox();
    },
  ),
);

// Submitting a comment
context.read<CommentBloc>().add(SubmitComment(postId, content));
```

### Report Feature Migration

#### Before (Provider/ChangeNotifier):
```dart
// Old way
ChangeNotifierProvider(
  create: (_) => ReportFormController(),
  child: Consumer<ReportFormController>(
    builder: (context, controller, child) {
      return Checkbox(
        value: controller.currentFormState?.isAnswerChecked(0) ?? false,
        onChanged: (value) => controller.updateAnswer(0, value ?? false),
      );
    },
  ),
);
```

#### After (BLoC):
```dart
// New way
BlocProvider(
  create: (_) => ReportBloc()..add(CreateReport(caseName, questions)),
  child: BlocBuilder<ReportBloc, ReportState>(
    builder: (context, state) {
      if (state is ReportLoaded) {
        return Checkbox(
          value: state.formState.isAnswerChecked(0),
          onChanged: (value) {
            context.read<ReportBloc>().add(UpdateAnswer(0, value ?? false));
          },
        );
      }
      return SizedBox();
    },
  ),
);
```

### Consent Feature Migration

#### Before (Provider/ChangeNotifier):
```dart
// Old way
ChangeNotifierProvider(
  create: (_) => ConsentFormValidationService.instance,
  child: Consumer<ConsentFormValidationService>(
    builder: (context, validator, child) {
      return TextField(
        decoration: InputDecoration(
          errorText: validator.childNameError,
        ),
        onChanged: (value) => validator.validateChildName(value),
      );
    },
  ),
);
```

#### After (BLoC):
```dart
// New way
BlocProvider(
  create: (_) => ConsentBloc(),
  child: BlocBuilder<ConsentBloc, ConsentState>(
    builder: (context, state) {
      return TextField(
        decoration: InputDecoration(
          errorText: state.childNameError,
        ),
        onChanged: (value) {
          context.read<ConsentBloc>().add(ValidateChildName(value));
        },
      );
    },
  ),
);
```

## Key Differences

### State Management
- **Provider**: Uses `notifyListeners()` to trigger rebuilds
- **BLoC**: Uses events and states with clear transitions

### Accessing State
- **Provider**: `context.watch<T>()` or `Consumer<T>`
- **BLoC**: `BlocBuilder<B, S>` or `context.watch<B>()`

### Triggering Actions
- **Provider**: Call methods directly on the provider
- **BLoC**: Dispatch events using `bloc.add(Event())`

### Testing
- **Provider**: Mock the provider class
- **BLoC**: Test events → states transitions independently

## Benefits of BLoC

1. **Separation of Concerns**: Business logic is completely separated from UI
2. **Testability**: Easy to test state transitions without UI
3. **Predictability**: Clear event → state flow
4. **Debugging**: BLoC observer can log all events and states
5. **Reusability**: BLoCs can be reused across different widgets
6. **Type Safety**: Strongly typed events and states

## Migration Checklist

For each feature:
- [ ] Create BLoC with events and states
- [ ] Update widgets to use BlocProvider
- [ ] Replace Consumer with BlocBuilder
- [ ] Replace method calls with event dispatches
- [ ] Add BLoC tests
- [ ] Remove legacy ChangeNotifier class
- [ ] Update documentation

## Common Patterns

### Loading States
```dart
// BLoC handles loading states explicitly
if (state is DataLoading) {
  return CircularProgressIndicator();
}
if (state is DataLoaded) {
  return DataWidget(state.data);
}
if (state is DataError) {
  return ErrorWidget(state.message);
}
```

### Form Validation
```dart
// Dispatch validation events
context.read<ConsentBloc>().add(ValidateAllFields({
  'childName': nameController.text,
  'childAge': ageController.text,
  // ...
}));

// Listen to validation state
BlocBuilder<ConsentBloc, ConsentState>(
  builder: (context, state) {
    return ElevatedButton(
      onPressed: state.isValid ? _submit : null,
      child: Text('Submit'),
    );
  },
);
```

### Navigation After Success
```dart
BlocListener<CommentBloc, CommentState>(
  listener: (context, state) {
    if (state is CommentSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment submitted!')),
      );
      Navigator.pop(context);
    }
  },
  child: CommentForm(),
);
```

## Resources

- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Flutter BLoC Package](https://pub.dev/packages/flutter_bloc)
- [BLoC Architecture](https://bloclibrary.dev/#/architecture)

## Questions?

If you have questions about the migration, check the existing `LearnBloc` implementation as a reference or consult the team.
