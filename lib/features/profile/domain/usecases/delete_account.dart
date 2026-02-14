import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Use case for deleting user account
class DeleteAccount implements UseCase<void, String> {

  DeleteAccount(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(String uid) async {
    return repository.deleteAccount(uid);
  }
}
