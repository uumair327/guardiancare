# Developer Guide - Clean Architecture

## Quick Start for New Developers

This guide helps you understand and work with the Clean Architecture implementation in GuardianCare.

---

## Architecture Overview

```
lib/
├── core/                    # Shared functionality
│   ├── di/                 # Dependency injection
│   ├── error/              # Error handling
│   ├── network/            # Network utilities
│   └── usecases/           # Base use case
│
├── features/               # Feature modules
│   └── [feature_name]/
│       ├── domain/         # Business logic (pure Dart)
│       │   ├── entities/   # Business objects
│       │   ├── repositories/  # Interfaces
│       │   └── usecases/   # Business operations
│       │
│       ├── data/           # Data handling
│       │   ├── models/     # Data models
│       │   ├── datasources/  # Data sources
│       │   └── repositories/  # Implementations
│       │
│       └── presentation/   # UI layer
│           ├── bloc/       # State management
│           ├── pages/      # Screens
│           └── widgets/    # UI components
│
└── main.dart              # App entry point
```

---

## The Three Layers

### 1. Domain Layer (Business Logic)
**Location**: `lib/features/[feature]/domain/`
**Purpose**: Pure business logic, no dependencies on Flutter or external packages

**Components**:
- **Entities**: Business objects (e.g., `UserEntity`, `ForumEntity`)
- **Repositories**: Interfaces defining data operations
- **Use Cases**: Single business operations

**Example Entity**:
```dart
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  @override
  List<Object> get props => [uid, email, displayName];
}
```

**Example Use Case**:
```dart
class SignInWithEmail implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
```

### 2. Data Layer (Data Handling)
**Location**: `lib/features/[feature]/data/`
**Purpose**: Handle data from various sources (Firebase, local storage, APIs)

**Components**:
- **Models**: Extend entities with serialization
- **Data Sources**: Handle external data operations
- **Repository Implementations**: Implement domain interfaces

**Example Model**:
```dart
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }
}
```

**Example Data Source**:
```dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } catch (e) {
      throw ServerException('Sign in failed: ${e.toString()}');
    }
  }
}
```

### 3. Presentation Layer (UI)
**Location**: `lib/features/[feature]/presentation/`
**Purpose**: Display UI and manage state

**Components**:
- **BLoC**: State management
- **Events**: User actions
- **States**: UI states
- **Pages**: Screens
- **Widgets**: UI components

**Example BLoC**:
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;

  AuthBloc({required this.signInWithEmail}) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInWithEmail(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

---

## Adding a New Feature

### Step 1: Create Domain Layer

```bash
# Create directory structure
mkdir -p lib/features/my_feature/domain/{entities,repositories,usecases}
```

**1.1 Create Entity**:
```dart
// lib/features/my_feature/domain/entities/my_entity.dart
class MyEntity extends Equatable {
  final String id;
  final String name;

  const MyEntity({required this.id, required this.name});

  @override
  List<Object> get props => [id, name];
}
```

**1.2 Create Repository Interface**:
```dart
// lib/features/my_feature/domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<Either<Failure, MyEntity>> getItem(String id);
  Future<Either<Failure, void>> saveItem(MyEntity item);
}
```

**1.3 Create Use Case**:
```dart
// lib/features/my_feature/domain/usecases/get_item.dart
class GetItem implements UseCase<MyEntity, String> {
  final MyRepository repository;

  GetItem(this.repository);

  @override
  Future<Either<Failure, MyEntity>> call(String id) async {
    return await repository.getItem(id);
  }
}
```

### Step 2: Create Data Layer

```bash
# Create directory structure
mkdir -p lib/features/my_feature/data/{models,datasources,repositories}
```

**2.1 Create Model**:
```dart
// lib/features/my_feature/data/models/my_model.dart
class MyModel extends MyEntity {
  const MyModel({required super.id, required super.name});

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

**2.2 Create Data Source**:
```dart
// lib/features/my_feature/data/datasources/my_remote_datasource.dart
abstract class MyRemoteDataSource {
  Future<MyModel> getItem(String id);
}

class MyRemoteDataSourceImpl implements MyRemoteDataSource {
  final FirebaseFirestore firestore;

  MyRemoteDataSourceImpl({required this.firestore});

  @override
  Future<MyModel> getItem(String id) async {
    try {
      final doc = await firestore.collection('items').doc(id).get();
      return MyModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get item: ${e.toString()}');
    }
  }
}
```

**2.3 Create Repository Implementation**:
```dart
// lib/features/my_feature/data/repositories/my_repository_impl.dart
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;

  MyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MyEntity>> getItem(String id) async {
    try {
      final item = await remoteDataSource.getItem(id);
      return Right(item);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

### Step 3: Create Presentation Layer

```bash
# Create directory structure
mkdir -p lib/features/my_feature/presentation/{bloc,pages,widgets}
```

**3.1 Create Events**:
```dart
// lib/features/my_feature/presentation/bloc/my_event.dart
abstract class MyEvent extends Equatable {
  const MyEvent();
  @override
  List<Object?> get props => [];
}

class LoadItem extends MyEvent {
  final String id;
  const LoadItem(this.id);
  @override
  List<Object?> get props => [id];
}
```

**3.2 Create States**:
```dart
// lib/features/my_feature/presentation/bloc/my_state.dart
abstract class MyState extends Equatable {
  const MyState();
  @override
  List<Object?> get props => [];
}

class MyInitial extends MyState {}
class MyLoading extends MyState {}
class MyLoaded extends MyState {
  final MyEntity item;
  const MyLoaded(this.item);
  @override
  List<Object?> get props => [item];
}
class MyError extends MyState {
  final String message;
  const MyError(this.message);
  @override
  List<Object?> get props => [message];
}
```

**3.3 Create BLoC**:
```dart
// lib/features/my_feature/presentation/bloc/my_bloc.dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final GetItem getItem;

  MyBloc({required this.getItem}) : super(MyInitial()) {
    on<LoadItem>(_onLoadItem);
  }

  Future<void> _onLoadItem(LoadItem event, Emitter<MyState> emit) async {
    emit(MyLoading());
    final result = await getItem(event.id);
    result.fold(
      (failure) => emit(MyError(failure.message)),
      (item) => emit(MyLoaded(item)),
    );
  }
}
```

### Step 4: Register Dependencies

```dart
// lib/core/di/injection_container.dart

void _initMyFeature() {
  // Data sources
  sl.registerLazySingleton<MyRemoteDataSource>(
    () => MyRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<MyRepository>(
    () => MyRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetItem(sl()));

  // BLoC
  sl.registerFactory(() => MyBloc(getItem: sl()));
}

// Add to init() function
Future<void> init() async {
  // ... existing code
  _initMyFeature();
}
```

### Step 5: Use in UI

```dart
// lib/features/my_feature/presentation/pages/my_page.dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyBloc>()..add(LoadItem('123')),
      child: Scaffold(
        appBar: AppBar(title: Text('My Feature')),
        body: BlocBuilder<MyBloc, MyState>(
          builder: (context, state) {
            if (state is MyLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is MyLoaded) {
              return Text('Item: ${state.item.name}');
            } else if (state is MyError) {
              return Text('Error: ${state.message}');
            }
            return Container();
          },
        ),
      ),
    );
  }
}
```

---

## Common Patterns

### Error Handling

Always use `Either<Failure, T>`:

```dart
// Good ✅
Future<Either<Failure, User>> getUser(String id) async {
  try {
    final user = await dataSource.getUser(id);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}

// Bad ❌
Future<User> getUser(String id) async {
  return await dataSource.getUser(id); // Throws exception
}
```

### Dependency Injection

Always inject dependencies:

```dart
// Good ✅
class MyBloc extends Bloc<MyEvent, MyState> {
  final GetItem getItem;
  MyBloc({required this.getItem}) : super(MyInitial());
}

// Bad ❌
class MyBloc extends Bloc<MyEvent, MyState> {
  final getItem = GetItem(MyRepositoryImpl()); // Hard-coded
}
```

### State Management

Use BLoC for all state:

```dart
// Good ✅
BlocProvider(
  create: (context) => sl<MyBloc>(),
  child: MyPage(),
)

// Bad ❌
StatefulWidget with setState
```

---

## Testing

### Unit Test Example

```dart
void main() {
  late GetItem useCase;
  late MockMyRepository mockRepository;

  setUp(() {
    mockRepository = MockMyRepository();
    useCase = GetItem(mockRepository);
  });

  test('should return item when repository call is successful', () async {
    // Arrange
    final item = MyEntity(id: '1', name: 'Test');
    when(() => mockRepository.getItem('1'))
        .thenAnswer((_) async => Right(item));

    // Act
    final result = await useCase('1');

    // Assert
    expect(result, Right(item));
    verify(() => mockRepository.getItem('1')).called(1);
  });
}
```

---

## Best Practices

### DO ✅
- Keep entities pure (no external dependencies)
- Use interfaces for repositories
- Single responsibility for use cases
- Inject all dependencies
- Handle all errors with Either
- Use BLoC for state management
- Write tests for business logic

### DON'T ❌
- Put business logic in UI
- Use direct Firebase calls in UI
- Hard-code dependencies
- Throw exceptions without handling
- Mix state management patterns
- Skip error handling
- Ignore test coverage

---

## Troubleshooting

### Issue: Dependency not found
**Solution**: Check if dependency is registered in `injection_container.dart`

### Issue: BLoC not updating UI
**Solution**: Ensure you're using `BlocBuilder` or `BlocConsumer`

### Issue: Compilation error in use case
**Solution**: Check that repository interface matches implementation

### Issue: Firebase error not handled
**Solution**: Wrap Firebase calls in try-catch and return Either

---

## Resources

- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **BLoC Pattern**: https://bloclibrary.dev/
- **Dependency Injection**: https://pub.dev/packages/get_it
- **Error Handling**: https://pub.dev/packages/dartz

---

## Getting Help

1. Check feature documentation in `.kiro/specs/clean-architecture/`
2. Review existing feature implementations
3. Follow the patterns established in the codebase
4. Ask team members for clarification

---

**Happy Coding!** 🚀
