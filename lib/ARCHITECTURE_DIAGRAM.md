# GuardianCare - Clean Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                          │
│                    (UI, Widgets, State Management)                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │   Pages      │  │   Widgets    │  │    BLoC      │            │
│  │              │  │              │  │              │            │
│  │ - LoginPage  │  │ - VideoCard  │  │ - AuthBloc   │            │
│  │ - HomePage   │  │ - ForumItem  │  │ - QuizBloc   │            │
│  │ - QuizPage   │  │ - Carousel   │  │ - ForumBloc  │            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│                                                                     │
│                           ↓ depends on ↓                           │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                               │
│                  (Business Logic, Pure Dart)                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │  Entities    │  │  Use Cases   │  │ Repositories │            │
│  │              │  │              │  │ (Interfaces) │            │
│  │ - UserEntity │  │ - SignIn     │  │ - AuthRepo   │            │
│  │ - QuizEntity │  │ - SaveReport │  │ - QuizRepo   │            │
│  │ - VideoEntity│  │ - GetVideos  │  │ - VideoRepo  │            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│                                                                     │
│                           ↑ implements ↑                           │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                │
│              (Data Sources, Models, Repository Impl)                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │   Models     │  │ Repositories │  │ Data Sources │            │
│  │              │  │     Impl     │  │              │            │
│  │ - UserModel  │  │ - AuthRepoIm │  │ - Remote DS  │            │
│  │ - QuizModel  │  │ - QuizRepoIm │  │ - Local DS   │            │
│  │ - VideoModel │  │ - VideoRepoIm│  │ - Cache DS   │            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│                                                                     │
│                           ↓ uses ↓                                 │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                          CORE LAYER                                 │
│                  (Infrastructure, Services)                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │   Database   │  │   Network    │  │     DI       │            │
│  │              │  │              │  │              │            │
│  │ - SQLite     │  │ - Firebase   │  │ - GetIt      │            │
│  │ - Hive       │  │ - HTTP       │  │ - Container  │            │
│  │ - Storage    │  │ - NetworkInfo│  │ - Injection  │            │
│  └──────────────┘  └──────────────┘  └──────────────┘            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Feature Module Structure

```
lib/features/authentication/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart (interface)
│   └── usecases/
│       ├── sign_in_with_email.dart
│       ├── sign_up_with_email.dart
│       ├── sign_in_with_google.dart
│       └── sign_out.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── repositories/
│   │   └── auth_repository_impl.dart
│   └── datasources/
│       └── auth_remote_datasource.dart
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   ├── signup_page.dart
    │   └── password_reset_page.dart
    ├── widgets/
    │   └── (reusable widgets)
    └── bloc/
        ├── auth_bloc.dart
        ├── auth_event.dart
        └── auth_state.dart
```

## Data Flow Example: User Login

```
┌─────────────────────────────────────────────────────────────────────┐
│ 1. USER ACTION                                                      │
│    User taps "Login" button                                         │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 2. PRESENTATION LAYER                                               │
│    LoginPage → AuthBloc.add(SignInWithEmailRequested)              │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 3. DOMAIN LAYER                                                     │
│    AuthBloc → SignInWithEmail(usecase)                             │
│    UseCase → AuthRepository(interface)                              │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 4. DATA LAYER                                                       │
│    AuthRepositoryImpl → AuthRemoteDataSource                        │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 5. CORE LAYER                                                       │
│    AuthRemoteDataSource → Firebase Auth                             │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│ 6. RESPONSE FLOW (Reverse)                                          │
│    Firebase → DataSource → Repository → UseCase → BLoC → UI        │
│    Either<Failure, UserEntity>                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Storage Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      STORAGE MANAGER                                │
│                   (Unified Interface)                               │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
        ┌────────────────────┼────────────────────┐
        ↓                    ↓                    ↓
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│SharedPrefs   │    │     Hive     │    │    SQLite    │
│              │    │              │    │              │
│ - Settings   │    │ - Sessions   │    │ - Quiz Data  │
│ - Flags      │    │ - Reports    │    │ - History    │
│ - Simple KV  │    │ - Cache      │    │ - Analytics  │
└──────────────┘    └──────────────┘    └──────────────┘
```

## Dependency Injection Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         main.dart                                   │
│                    await init()                                     │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                   injection_container.dart                          │
│                                                                     │
│  1. Register Core Services                                          │
│     - SharedPreferences                                             │
│     - Firebase instances                                            │
│     - Storage services (Hive, SQLite)                              │
│                                                                     │
│  2. Register Feature Dependencies                                   │
│     For each feature:                                               │
│       - Data Sources (with injected services)                       │
│       - Repositories (with injected data sources)                   │
│       - Use Cases (with injected repositories)                      │
│       - BLoCs (with injected use cases)                            │
└─────────────────────────────────────────────────────────────────────┘
```

## BLoC Pattern Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                            UI                                       │
│                    (Stateless Widget)                               │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
                    BlocBuilder/BlocListener
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          BLoC                                       │
│                                                                     │
│  Events ──→ BLoC Logic ──→ States                                  │
│              ↓                                                      │
│         Use Cases                                                   │
│              ↓                                                      │
│         Repositories                                                │
└─────────────────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Data Source                                    │
│                  try { ... } catch (e)                              │
│                  throw CacheException()                             │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                      Repository                                     │
│              Either<Failure, Success>                               │
│              Left(CacheFailure()) or Right(data)                    │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       Use Case                                      │
│              Either<Failure, Success>                               │
│              Pass through or transform                              │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                         BLoC                                        │
│              result.fold(                                           │
│                (failure) => emit(ErrorState()),                     │
│                (success) => emit(SuccessState())                    │
│              )                                                      │
└────────────────────────────┬────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────────┐
│                          UI                                         │
│              Show error message or success UI                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Testing Pyramid

```
                    ┌──────────┐
                    │    E2E   │  (Few)
                    │  Tests   │
                ┌───┴──────────┴───┐
                │   Integration    │  (Some)
                │      Tests       │
            ┌───┴──────────────────┴───┐
            │      Unit Tests          │  (Many)
            │  (BLoC, UseCase, Repo)   │
        ┌───┴──────────────────────────┴───┐
        │         Widget Tests             │  (Many)
        │      (UI Components)             │
        └──────────────────────────────────┘
```

## Key Principles

1. **Dependency Rule**: Dependencies point inward
2. **Separation of Concerns**: Each layer has a specific responsibility
3. **Testability**: Easy to mock and test each layer
4. **Maintainability**: Changes in one layer don't affect others
5. **Scalability**: Easy to add new features following the same pattern

## Benefits

✅ **Independent of Frameworks**: Business logic doesn't depend on Flutter
✅ **Testable**: Each layer can be tested independently
✅ **Independent of UI**: UI can change without affecting business logic
✅ **Independent of Database**: Can switch storage solutions easily
✅ **Independent of External Services**: Can swap Firebase for another service

## File Naming Conventions

- **Entities**: `*_entity.dart`
- **Models**: `*_model.dart`
- **Repositories**: `*_repository.dart` (interface), `*_repository_impl.dart` (implementation)
- **Use Cases**: `verb_noun.dart` (e.g., `get_user.dart`, `save_report.dart`)
- **Data Sources**: `*_datasource.dart` (interface), `*_datasource_impl.dart` (implementation)
- **BLoC**: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- **Pages**: `*_page.dart`
- **Widgets**: `*_widget.dart`
