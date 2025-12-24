import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';
import 'package:guardiancare/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting user profile
class GetProfile implements UseCase<ProfileEntity, String> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(String uid) async {
    return await repository.getProfile(uid);
  }
}
