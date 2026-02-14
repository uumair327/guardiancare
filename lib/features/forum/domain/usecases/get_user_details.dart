import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/forum/domain/entities/user_details_entity.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class GetUserDetails extends UseCase<UserDetailsEntity, GetUserDetailsParams> {

  GetUserDetails(this.repository);
  final ForumRepository repository;

  @override
  Future<Either<Failure, UserDetailsEntity>> call(GetUserDetailsParams params) async {
    return repository.getUserDetails(params.userId);
  }
}

class GetUserDetailsParams extends Equatable {

  const GetUserDetailsParams({required this.userId});
  final String userId;

  @override
  List<Object> get props => [userId];
}
