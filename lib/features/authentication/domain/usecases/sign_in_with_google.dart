import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class SignInWithGoogle extends UseCase<UserEntity, NoParams> {

  SignInWithGoogle(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return repository.signInWithGoogle();
  }
}
