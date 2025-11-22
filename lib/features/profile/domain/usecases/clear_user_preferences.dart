import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Use case for clearing user preferences
class ClearUserPreferences implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  ClearUserPreferences(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearUserPreferences();
  }
}
