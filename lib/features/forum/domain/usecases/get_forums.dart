import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class GetForums {
  final ForumRepository repository;

  GetForums(this.repository);

  Stream<Either<Failure, List<ForumEntity>>> call(GetForumsParams params) {
    return repository.getForums(params.category);
  }
}

class GetForumsParams extends Equatable {
  final ForumCategory category;

  const GetForumsParams({required this.category});

  @override
  List<Object> get props => [category];
}
