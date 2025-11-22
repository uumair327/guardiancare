import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class GetComments {
  final ForumRepository repository;

  GetComments(this.repository);

  Stream<Either<Failure, List<CommentEntity>>> call(GetCommentsParams params) {
    return repository.getComments(params.forumId);
  }
}

class GetCommentsParams extends Equatable {
  final String forumId;

  const GetCommentsParams({required this.forumId});

  @override
  List<Object> get props => [forumId];
}
