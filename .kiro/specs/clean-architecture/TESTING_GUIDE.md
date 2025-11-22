# Clean Architecture Testing Guide

## 📋 Overview

This guide explains how to write tests for each layer of the Clean Architecture implementation in the GuardianCare project.

---

## 🎯 Testing Strategy

### Test Pyramid

```
        ┌─────────────┐
        │   E2E Tests │  ← Few, slow, expensive
        └─────────────┘
       ┌───────────────┐
       │ Widget Tests  │  ← Some, medium speed
       └───────────────┘
      ┌─────────────────┐
      │Integration Tests│  ← Some, medium speed
      └─────────────────┘
     ┌───────────────────┐
     │   Unit Tests      │  ← Many, fast, cheap
     └───────────────────┘
```

### Coverage Goals
- **Use Cases**: 100% coverage
- **Repositories**: 90%+ coverage
- **BLoC**: 90%+ coverage
- **Widgets**: 70%+ coverage

---

## 🧪 Unit Testing

### 1. Testing Use Cases

Use cases should be tested in isolation by mocking the repository.

**Example: Testing SignInWithEmail**

```dart
// test/features/authentication/domain/usecases/sign_in_with_email_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_email.dart';

import 'sign_in_with_email_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignInWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmail(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    uid: '123',
    email: tEmail,
    displayName: 'Test User',
  );

  group('SignInWithEmail', () {
    test('should return UserEntity when sign in is successful', () async {
      // Arrange
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(mockRepository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return AuthFailure when sign in fails', () async {
      // Arrange
      const tFailure = AuthFailure('Invalid credentials');
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(mockRepository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const tFailure = NetworkFailure('No internet connection');
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(
        const SignInParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(tFailure));
    });
  });
}
```

**Generate Mocks:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 2. Testing Repositories

Repositories should be tested by mocking data sources and network info.

**Example: Testing AuthRepositoryImpl**

```dart
// test/features/authentication/data/repositories/auth_repository_impl_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/network/network_info.dart';
import 'package:guardiancare/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:guardiancare/features/authentication/data/models/user_model.dart';
import 'package:guardiancare/features/authentication/data/repositories/auth_repository_impl.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, NetworkInfo])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUserModel = UserModel(
    uid: '123',
    email: tEmail,
    displayName: 'Test User',
  );

  group('signInWithEmailAndPassword', () {
    test('should check if device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => tUserModel);

      // Act
      await repository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      );

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return UserModel when sign in is successful', () async {
        // Arrange
        when(mockRemoteDataSource.signInWithEmailAndPassword(any, any))
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Right(tUserModel));
        verify(mockRemoteDataSource.signInWithEmailAndPassword(
          tEmail,
          tPassword,
        ));
      });

      test('should return AuthFailure when sign in throws AuthException',
          () async {
        // Arrange
        when(mockRemoteDataSource.signInWithEmailAndPassword(any, any))
            .thenThrow(AuthException('Invalid credentials'));

        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Left(AuthFailure('Invalid credentials')));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when device is offline', () async {
        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, const Left(NetworkFailure('No internet connection')));
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });
}
```

---

### 3. Testing BLoC

BLoC should be tested by mocking use cases.

**Example: Testing AuthBloc**

```dart
// test/features/authentication/presentation/bloc/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/usecases/get_current_user.dart';
import 'package:guardiancare/features/authentication/domain/usecases/send_password_reset_email.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_out.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_event.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  SignInWithEmail,
  SignUpWithEmail,
  SignInWithGoogle,
  SignOut,
  GetCurrentUser,
  SendPasswordResetEmail,
])
void main() {
  late AuthBloc bloc;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignUpWithEmail mockSignUpWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockSendPasswordResetEmail mockSendPasswordResetEmail;

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignUpWithEmail = MockSignUpWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    mockSendPasswordResetEmail = MockSendPasswordResetEmail();

    bloc = AuthBloc(
      signInWithEmail: mockSignInWithEmail,
      signUpWithEmail: mockSignUpWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
      getCurrentUser: mockGetCurrentUser,
      sendPasswordResetEmail: mockSendPasswordResetEmail,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    uid: '123',
    email: tEmail,
    displayName: 'Test User',
  );

  group('SignInWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when sign in is successful',
      build: () {
        when(mockSignInWithEmail(any))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(mockSignInWithEmail(
          const SignInParams(email: tEmail, password: tPassword),
        ));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(mockSignInWithEmail(any))
            .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SignInWithEmailRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );
  });

  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when user is signed in',
      build: () {
        when(mockGetCurrentUser(any))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when user is not signed in',
      build: () {
        when(mockGetCurrentUser(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
```

**Add bloc_test dependency:**
```yaml
dev_dependencies:
  bloc_test: ^9.1.0
```

---

## 🔗 Integration Testing

Integration tests verify that multiple components work together correctly.

**Example: Repository Integration Test**

```dart
// test/features/authentication/integration/auth_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_email.dart';

void main() {
  setUpAll(() async {
    await di.init();
  });

  group('Authentication Integration Tests', () {
    test('should be able to get repository from DI', () {
      final repository = di.sl<AuthRepository>();
      expect(repository, isNotNull);
    });

    test('should be able to get use case from DI', () {
      final useCase = di.sl<SignInWithEmail>();
      expect(useCase, isNotNull);
    });

    // Add more integration tests
  });
}
```

---

## 🎨 Widget Testing

Widget tests verify UI behavior.

**Example: Login Page Widget Test**

```dart
// test/features/authentication/presentation/pages/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_state.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: child,
      ),
    );
  }

  testWidgets('should show loading indicator when state is AuthLoading',
      (tester) async {
    // Arrange
    when(mockAuthBloc.state).thenReturn(const AuthLoading());
    when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Act
    await tester.pumpWidget(makeTestableWidget(
      const Scaffold(body: Center(child: CircularProgressIndicator())),
    ));

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show error message when state is AuthError',
      (tester) async {
    // Arrange
    const errorMessage = 'Invalid credentials';
    when(mockAuthBloc.state).thenReturn(const AuthError(errorMessage));
    when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Act
    await tester.pumpWidget(makeTestableWidget(
      const Scaffold(body: Center(child: Text(errorMessage))),
    ));

    // Assert
    expect(find.text(errorMessage), findsOneWidget);
  });
}
```

---

## 📝 Test Organization

### Directory Structure

```
test/
├── features/
│   ├── authentication/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── sign_in_with_email_test.dart
│   │   │   │   └── sign_up_with_email_test.dart
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository_impl_test.dart
│   │   │   └── models/
│   │   │       └── user_model_test.dart
│   │   ├── presentation/
│   │   │   ├── bloc/
│   │   │   │   └── auth_bloc_test.dart
│   │   │   └── pages/
│   │   │       └── login_page_test.dart
│   │   └── integration/
│   │       └── auth_integration_test.dart
│   └── forum/
│       └── ... (same structure)
└── core/
    ├── error/
    └── usecases/
```

---

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/authentication/domain/usecases/sign_in_with_email_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Generate Mocks
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ Testing Checklist

### For Each Use Case
- [ ] Test successful execution
- [ ] Test failure scenarios
- [ ] Test edge cases
- [ ] Verify repository method calls
- [ ] Check no unexpected interactions

### For Each Repository
- [ ] Test network connectivity checking
- [ ] Test successful data source calls
- [ ] Test exception handling
- [ ] Test failure mapping
- [ ] Verify data source interactions

### For Each BLoC
- [ ] Test each event handler
- [ ] Test state transitions
- [ ] Test error states
- [ ] Test loading states
- [ ] Verify use case calls

### For Each Widget
- [ ] Test UI rendering
- [ ] Test user interactions
- [ ] Test state changes
- [ ] Test navigation
- [ ] Test error display

---

## 🎯 Best Practices

1. **AAA Pattern**: Arrange, Act, Assert
2. **One Assertion Per Test**: Keep tests focused
3. **Descriptive Names**: Test names should describe what they test
4. **Mock External Dependencies**: Only test the unit under test
5. **Test Edge Cases**: Don't just test the happy path
6. **Keep Tests Fast**: Unit tests should run in milliseconds
7. **Independent Tests**: Tests should not depend on each other
8. **Clean Up**: Use setUp and tearDown properly

---

## 📚 Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [BLoC Test Documentation](https://pub.dev/packages/bloc_test)
- [Test Coverage](https://pub.dev/packages/coverage)

---

**Next Steps**: Start writing tests for authentication and forum features!
