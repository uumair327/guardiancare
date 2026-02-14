import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';

class SendEmailVerification extends UseCase<void, NoParams> {

  SendEmailVerification(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return repository.sendEmailVerification();
  }
}
