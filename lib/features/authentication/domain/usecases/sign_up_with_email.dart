import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class SignUpWithEmail extends UseCase<UserEntity, SignUpParams> {

  SignUpWithEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      role: params.role,
    );
  }
}

class SignUpParams extends Equatable {

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });
  final String email;
  final String password;
  final String displayName;
  final String role;

  @override
  List<Object> get props => [email, password, displayName, role];
}
