# Clean Architecture Implementation Guide

## Overview
This document explains the Clean Architecture implementation in the GuardianCare Flutter project.

## Architecture Layers

### 1. Domain Layer (Business Logic)
**Location**: `lib/features/{feature}/domain/`

The innermost layer containing business logic and rules. It has NO dependencies on other layers.

**Components**:
- **Entities** (`entities/`): Pure Dart classes representing business objects
- **Repositories** (`repositories/`): Abstract interfaces defining data operations
- **Use Cases** (`usecases/`): Single-responsibility business logic operations

**Example**:
```dart
// Entity
class UserEntity extends Equatable {
  final String uid;
  final String email;
  // ...
}

// Repository Interface
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
}

// Use Case
class SignInWithEmail extends UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;
  
  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}
```

### 2. Data Layer
**Location**: `lib/features/{feature}/data/`

Handles data operations and implements domain repositories.

**Components**:
- **Models** (`models/`): Data transfer objects that extend entities
- **Data Sources** (`datasources/`): Remote (Firebase, API) and Local (SharedPreferences, SQLite)
- **Repository Implementations** (`repositories/`): Concrete implementations

**Example**:
```dart
// Model
class UserModel extends UserEntity {
  factory UserModel.fromFirebaseUser(User user) { ... }
  Map<String, dynamic> toJson() { ... }
}

// Data Source
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  
  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}

// Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signIn(email, password);
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
```

### 3. Presentation Layer
**Location**: `lib/features/{feature}/presentation/`

Handles UI and state management.

**Components**:
- **BLoC/Cubit** (`bloc/`): State management
- **Pages** (`pages/`): Screen-level widgets
- **Widgets** (`widgets/`): Reusable UI components

**Example**:
```dart
// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInUseCase;
  
  AuthBloc({required this.signInUseCase}) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
  }
  
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}

// Page
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: LoginView(),
    );
  }
}
```

## Core Components

### Error Handling
**Location**: `lib/core/error/`

- **Failures**: Used in the domain layer (returned by repositories)
- **Exceptions**: Used in the data layer (thrown by data sources)

```dart
// Failure (Domain)
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Exception (Data)
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
```

### Use Cases
**Location**: `lib/core/usecases/`

Base class for all use cases:
```dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```

### Dependency Injection
**Location**: `lib/core/di/`

Using `get_it` for service locator pattern:
```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Register dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerFactory(() => AuthBloc(signInUseCase: sl()));
}
```

## Benefits

1. **Testability**: Each layer can be tested independently with mocks
2. **Maintainability**: Clear separation of concerns
3. **Scalability**: Easy to add new features following the same pattern
4. **Flexibility**: Easy to swap implementations (e.g., Firebase → REST API)
5. **Independence**: Business logic doesn't depend on frameworks or UI

## Migration Checklist

For each feature:

- [ ] Create domain layer
  - [ ] Define entities
  - [ ] Define repository interfaces
  - [ ] Create use cases
- [ ] Create data layer
  - [ ] Create models
  - [ ] Create data sources
  - [ ] Implement repositories
- [ ] Create presentation layer
  - [ ] Create BLoC/Cubit
  - [ ] Create pages
  - [ ] Create widgets
- [ ] Register dependencies in DI container
- [ ] Write tests
  - [ ] Use case tests
  - [ ] Repository tests
  - [ ] BLoC tests

## Testing Example

```dart
// Use Case Test
void main() {
  late SignInWithEmail useCase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmail(mockRepository);
  });
  
  test('should return UserEntity when sign in is successful', () async {
    // Arrange
    final tUser = UserEntity(uid: '123', email: 'test@test.com');
    when(mockRepository.signInWithEmailAndPassword(
      email: any,
      password: any,
    )).thenAnswer((_) async => Right(tUser));
    
    // Act
    final result = await useCase(
      SignInParams(email: 'test@test.com', password: 'password'),
    );
    
    // Assert
    expect(result, Right(tUser));
    verify(mockRepository.signInWithEmailAndPassword(
      email: 'test@test.com',
      password: 'password',
    ));
  });
}
```

## Best Practices

1. **Keep entities pure**: No dependencies on frameworks
2. **One use case = one operation**: Single Responsibility Principle
3. **Use Either type**: For explicit error handling
4. **Dependency injection**: Use constructor injection
5. **Test each layer**: Unit tests for domain, integration tests for data
6. **Immutable data**: Use const constructors and copyWith methods
7. **Clear naming**: Use descriptive names for use cases (e.g., `SignInWithEmail`)

## Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture by Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Dartz Package](https://pub.dev/packages/dartz)
- [Get It Package](https://pub.dev/packages/get_it)
