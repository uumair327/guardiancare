import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class GetForums {

  GetForums(this.repository);
  final ForumRepository repository;

  Stream<Either<Failure, List<ForumEntity>>> call(GetForumsParams params) {
    return repository.getForums(params.category);
  }
}

class GetForumsParams extends Equatable {

  const GetForumsParams({required this.category});
  final ForumCategory category;

  @override
  List<Object> get props => [category];
}
