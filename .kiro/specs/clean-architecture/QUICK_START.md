# Clean Architecture Quick Start Guide

## What Has Been Done

### ✅ Core Infrastructure
1. **Dependencies Added**:
   - `dartz` - For functional programming (Either type)
   - `get_it` - Dependency injection
   - `injectable` - Code generation for DI

2. **Core Components Created**:
   - `lib/core/error/failures.dart` - Domain layer error handling
   - `lib/core/error/exceptions.dart` - Data layer error handling
   - `lib/core/usecases/usecase.dart` - Base class for all use cases
   - `lib/core/di/injection_container.dart` - Dependency injection setup
   - `lib/core/network/network_info.dart` - Network connectivity checking

3. **Authentication Feature (Example)**:
   - Domain layer entities, repositories, and use cases created
   - Data layer models created
   - Ready to implement data sources and repository

## Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── error/                     # Error handling
│   │   ├── failures.dart          # Domain failures
│   │   └── exceptions.dart        # Data exceptions
│   ├── usecases/                  # Base use case
│   │   └── usecase.dart
│   ├── di/                        # Dependency injection
│   │   └── injection_container.dart
│   └── network/                   # Network utilities
│       └── network_info.dart
│
├── features/                      # Feature modules
│   └── authentication/            # Example feature
│       ├── domain/                # Business logic (no dependencies)
│       │   ├── entities/          # Business objects
│       │   ├── repositories/      # Repository interfaces
│       │   └── usecases/          # Business operations
│       ├── data/                  # Data handling
│       │   ├── models/            # Data models
│       │   ├── datasources/       # API, Firebase, Local DB
│       │   └── repositories/      # Repository implementations
│       └── presentation/          # UI
│           ├── bloc/              # State management
│           ├── pages/             # Screens
│           └── widgets/           # UI components
│
└── main.dart
```

## Next Steps

### 1. Complete Authentication Feature

Create the data sources:

```dart
// lib/features/authentication/data/datasources/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String displayName, String role);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  
  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });
  
  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get user role from Firestore
      final userDoc = await firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      
      final role = userDoc.data()?['role'] as String?;
      
      return UserModel.fromFirebaseUser(credential.user!, role: role);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed', code: e.code);
    }
  }
  
  // Implement other methods...
}
```

Create the repository implementation:

```dart
// lib/features/authentication/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithEmailAndPassword(
          email,
          password,
        );
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } catch (e) {
        return Left(AuthFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
  
  // Implement other methods...
}
```

### 2. Update Dependency Injection

```dart
// lib/core/di/injection_container.dart
void _initAuthFeature() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  
  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );
}
```

### 3. Create BLoC

```dart
// lib/features/authentication/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  
  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
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
  
  // Implement other event handlers...
}
```

### 4. Update main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize dependency injection
  await init();
  
  runApp(MyApp());
}
```

### 5. Use in UI

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(CheckAuthStatus()),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return LoginForm(
            onSubmit: (email, password) {
              context.read<AuthBloc>().add(
                SignInRequested(email: email, password: password),
              );
            },
          );
        },
      ),
    );
  }
}
```

## Testing Example

```dart
// test/features/authentication/domain/usecases/sign_in_with_email_test.dart
void main() {
  late SignInWithEmail useCase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmail(mockRepository);
  });
  
  test('should return UserEntity when sign in is successful', () async {
    // Arrange
    final tUser = UserEntity(
      uid: '123',
      email: 'test@test.com',
      displayName: 'Test User',
    );
    
    when(mockRepository.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => Right(tUser));
    
    // Act
    final result = await useCase(
      SignInParams(email: 'test@test.com', password: 'password123'),
    );
    
    // Assert
    expect(result, Right(tUser));
    verify(mockRepository.signInWithEmailAndPassword(
      email: 'test@test.com',
      password: 'password123',
    ));
    verifyNoMoreInteractions(mockRepository);
  });
}
```

## Key Principles

1. **Dependency Rule**: Dependencies point inward (Presentation → Data → Domain)
2. **Single Responsibility**: Each class has one reason to change
3. **Dependency Inversion**: Depend on abstractions, not concretions
4. **Testability**: Each layer can be tested independently
5. **Separation of Concerns**: Business logic separate from UI and data

## Resources

- See `README.md` for detailed architecture explanation
- See `spec.md` for full migration plan
- See `tasks.md` for migration progress tracking
