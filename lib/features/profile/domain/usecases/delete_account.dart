import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Use case for deleting user account
class DeleteAccountParams {

  DeleteAccountParams({required this.uid, this.password});
  final String uid;
  final String? password;
}

/// Use case for deleting user account
class DeleteAccount implements UseCase<void, DeleteAccountParams> {
  DeleteAccount(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) async {
    return repository.deleteAccount(params.uid, password: params.password);
  }
}
