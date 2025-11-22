---
title: Flutter Clean Architecture Refactoring
status: draft
created: 2024-11-22
---

# Flutter Clean Architecture Refactoring

## Overview
Restructure the GuardianCare Flutter project to follow Clean Architecture principles with clear separation of concerns across Domain, Data, and Presentation layers.

## Goals
- Implement proper Clean Architecture with clear layer boundaries
- Improve testability and maintainability
- Separate business logic from UI and data sources
- Make the codebase more scalable and easier to understand

## Clean Architecture Structure

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   ├── network/
│   │   ├── network_info.dart
│   ├── usecases/
│   │   ├── usecase.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── logger.dart
│   └── di/
│       ├── injection_container.dart
│
├── features/
│   ├── authentication/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in.dart
│   │   │       ├── sign_up.dart
│   │   │       └── sign_out.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── signup_page.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── social_login_buttons.dart
│   │
│   ├── forum/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── [other features...]
│
└── main.dart
```

## Layer Responsibilities

### 1. Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single-responsibility business logic operations
- **No dependencies** on other layers

### 2. Data Layer
- **Models**: Data transfer objects extending entities
- **Data Sources**: Remote (API, Firebase) and Local (SharedPreferences, SQLite)
- **Repository Implementations**: Concrete implementations of domain repositories
- Depends only on Domain layer

### 3. Presentation Layer
- **BLoC/Cubit**: State management
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components
- Depends on Domain layer (use cases)

## Migration Strategy

### Phase 1: Core Setup
- [ ] Create core directory structure
- [ ] Define base UseCase class
- [ ] Define Failure and Exception classes
- [ ] Set up dependency injection

### Phase 2: Feature Migration (Priority Order)
1. [ ] Authentication feature
2. [ ] Forum feature
3. [ ] Home feature
4. [ ] Profile feature
5. [ ] Learn feature
6. [ ] Quiz feature
7. [ ] Emergency feature
8. [ ] Report feature
9. [ ] Explore feature
10. [ ] Consent feature

### Phase 3: Testing & Validation
- [ ] Add unit tests for use cases
- [ ] Add repository tests
- [ ] Add BLoC tests
- [ ] Integration testing

## Implementation Details

### UseCase Base Class
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
```

### Repository Pattern
```dart
// Domain layer - Abstract
abstract class AuthRepository {
  Future<Either<Failure, User>> signIn(String email, String password);
  Future<Either<Failure, User>> signUp(String email, String password);
  Future<Either<Failure, void>> signOut();
}

// Data layer - Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  // Implementation...
}
```

### Dependency Injection
Use `get_it` for service locator pattern or `injectable` for code generation.

## Benefits
1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Clear separation of concerns
3. **Scalability**: Easy to add new features
4. **Flexibility**: Easy to swap implementations (e.g., change from Firebase to REST API)
5. **Team Collaboration**: Different teams can work on different layers

## Dependencies to Add
```yaml
dependencies:
  dartz: ^0.10.1  # For Either type
  get_it: ^7.6.0  # Dependency injection
  equatable: ^2.0.5  # Value equality
  
dev_dependencies:
  mockito: ^5.4.0  # For testing
  build_runner: ^2.4.0
```

## Notes
- Keep existing functionality working during migration
- Migrate one feature at a time
- Write tests as you migrate
- Update documentation as you go
