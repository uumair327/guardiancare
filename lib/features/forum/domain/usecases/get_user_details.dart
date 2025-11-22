import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/forum/domain/entities/user_details_entity.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class GetUserDetails extends UseCase<UserDetailsEntity, GetUserDetailsParams> {
  final ForumRepository repository;

  GetUserDetails(this.repository);

  @override
  Future<Either<Failure, UserDetailsEntity>> call(GetUserDetailsParams params) async {
    return await repository.getUserDetails(params.userId);
  }
}

class GetUserDetailsParams extends Equatable {
  final String userId;

  const GetUserDetailsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
