import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateProfile implements UseCase<void, ProfileEntity> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(ProfileEntity profile) async {
    return await repository.updateProfile(profile);
  }
}
