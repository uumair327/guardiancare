import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class ReloadUser implements UseCase<void, NoParams> {

  ReloadUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.reloadUser();
  }
}
