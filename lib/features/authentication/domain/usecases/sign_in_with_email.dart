import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class SignInWithEmail extends UseCase<UserEntity, SignInParams> {

  SignInWithEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {

  const SignInParams({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
