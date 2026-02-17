# Bloc & Cubit Audit Report

**Date**: 2026-02-18  
**Scope**: All 9 Blocs + 3 Cubits in `lib/features/`  
**Status**: ✅ All violations fixed

---

## Violations Found & Fixed

### 🔴 CRITICAL — DIP Violation (Dependency Inversion Principle)

#### 1. ✅ FIXED — `ForumBloc` depended on `FirebaseAuth` directly
- **Files**: `forum_bloc.dart`, `injection_container.dart`
- **Was**: `import 'package:firebase_auth/firebase_auth.dart'` + `final FirebaseAuth firebaseAuth`
- **Now**: `import 'package:guardiancare/core/backend/backend.dart'` + `final IAuthService authService`
- **Impact**: ForumBloc now works with any backend (Firebase, Supabase, sync mode)

### 🟡 MODERATE — Architecture Violations

#### 2. ✅ FIXED — `ExploreCubit` had dead event classes
- **Was**: `explore_event.dart` existed with event classes but `ExploreCubit` never used them
- **Now**: `explore_event.dart` deleted, barrel export updated

#### 3. ✅ FIXED — `UserStatsCubit` had inline state classes
- **Was**: States mixed in same file as Cubit (violated project conventions)
- **Now**: States extracted to `user_stats_state.dart`, Cubit imports the new file

#### 4. ✅ FIXED — `ConsentBloc` had business logic in Bloc
- **Was**: `minKeyLength = 4` and validation rules hard-coded in Bloc
- **Now**: `ParentalKeyValidator` created in domain layer (`domain/validators/`), injected into Bloc

---

## Clean Files (No Violations)

| Bloc/Cubit | Status | Notes |
|---|---|---|
| `AuthBloc` | ✅ Clean | Uses use cases only, no direct deps |
| `EmergencyBloc` | ✅ Clean | Uses use cases only |
| `HomeBloc` | ✅ Clean | Uses use cases, handles streams properly |
| `LearnBloc` | ✅ Clean | Uses use cases only |
| `ProfileBloc` | ✅ Clean | Uses use cases + abstract `AuthRepository` |
| `QuizBloc` | ✅ Clean | Uses abstract `IAuthService` port correctly |
| `ReportBloc` | ✅ Clean | Uses use cases only |
| `VideoPlayerCubit` | ✅ Clean | Pure UI state management, no deps |

---

## Files Modified

| File | Action | Reason |
|---|---|---|
| `features/forum/presentation/bloc/forum_bloc.dart` | 📝 Modified | Replace `FirebaseAuth` → `IAuthService` |
| `core/di/injection_container.dart` | 📝 Modified | Update DI: `firebaseAuth: sl()` → `authService: sl<IAuthService>()` |
| `features/explore/presentation/bloc/explore_event.dart` | 🗑️ Deleted | Dead code (Cubits don't use events) |
| `features/explore/presentation/bloc/bloc.dart` | 📝 Modified | Remove dead export |
| `features/profile/presentation/bloc/user_stats_cubit.dart` | 📝 Modified | Extract state classes to own file |
| `features/profile/presentation/bloc/user_stats_state.dart` | ✨ Created | Extracted states (project convention) |
| `features/profile/presentation/bloc/bloc.dart` | 📝 Modified | Add new state export |
| `features/consent/presentation/bloc/consent_bloc.dart` | 📝 Modified | Delegate validation to domain-layer validator |
| `features/consent/domain/validators/parental_key_validator.dart` | ✨ Created | Domain-layer validation logic |

## Compilation Result

```
flutter analyze: 0 errors, 0 warnings, 66 info-level lints (all pre-existing)
```
