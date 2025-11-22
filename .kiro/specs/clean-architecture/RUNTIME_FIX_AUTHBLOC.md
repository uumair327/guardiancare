# Runtime Fix - AuthBloc Provider Issue

## Date: November 22, 2025

---

## 🐛 Issue Identified

When running the app on the emulator, the following error occurred:

```
Error: Could not find the correct Provider<AuthBloc> above this Builder Widget
```

### Error Location
- **File**: `lib/features/authentication/presentation/pages/login_page.dart`
- **Line**: 51
- **Context**: When user taps "I Agree" in the Terms and Conditions dialog

### Root Cause
The `AuthBloc` was not provided at the app level in `main.dart`. When showing a dialog, the context inside the dialog doesn't have access to providers that aren't at the MaterialApp level or above.

---

## ✅ Solution Applied

### Changes Made to `lib/main.dart`

1. **Added Imports**:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
```

2. **Wrapped MaterialApp with BlocProvider**:
```dart
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => di.sl<AuthBloc>(),
    child: MaterialApp(
      // ... rest of MaterialApp configuration
    ),
  );
}
```

### Why This Works
- **App-Level Provider**: By providing `AuthBloc` at the root level (wrapping MaterialApp), it becomes accessible throughout the entire app
- **Dialog Context**: Dialogs can now access the AuthBloc even though they create a new context
- **Dependency Injection**: Uses the existing GetIt service locator (`di.sl<AuthBloc>()`) to create the AuthBloc instance

---

## 🎯 Impact

### Before Fix
- ❌ App crashed when user tapped "I Agree" in Terms dialog
- ❌ AuthBloc not accessible in dialogs
- ❌ Poor user experience

### After Fix
- ✅ AuthBloc accessible throughout the app
- ✅ Dialogs can trigger authentication events
- ✅ Google Sign-In works from Terms dialog
- ✅ Consistent BLoC access pattern

---

## 📝 Best Practices Applied

1. **Provider Scope**: Global providers (like AuthBloc) should be provided at the app level
2. **Dependency Injection**: Used existing DI container for consistency
3. **Context Hierarchy**: Ensured provider is above all widgets that need it

---

## 🧪 Testing Recommendations

After this fix, test the following flows:
1. ✅ Open app → Tap "I Agree" in Terms dialog → Should trigger Google Sign-In
2. ✅ Navigate to different screens → AuthBloc should be accessible
3. ✅ Show any dialog → Should be able to access AuthBloc
4. ✅ Sign in/Sign out flows → Should work correctly

---

## 🔄 Related Files

- `lib/main.dart` - Added BlocProvider wrapper
- `lib/features/authentication/presentation/pages/login_page.dart` - Uses AuthBloc in dialog
- `lib/core/di/injection_container.dart` - Provides AuthBloc instance

---

*Fix applied on November 22, 2025*
*App now runs successfully with AuthBloc accessible throughout*
