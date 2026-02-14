import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

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

    test('should pass correct parameters to repository', () async {
      // Arrange
      when(mockRepository.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => const Right(tUser));

      // Act
      await useCase(const SignInParams(email: tEmail, password: tPassword));

      // Assert
      verify(mockRepository.signInWithEmailAndPassword(
        email: tEmail,
        password: tPassword,
      ));
    });
  });
}
