import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class SignOut extends UseCase<void, NoParams> {

  SignOut(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.signOut();
  }
}
