import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class AddComment extends UseCase<void, AddCommentParams> {
  final ForumRepository repository;

  AddComment(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCommentParams params) async {
    return await repository.addComment(
      forumId: params.forumId,
      text: params.text,
      userId: params.userId,
    );
  }
}

class AddCommentParams extends Equatable {
  final String forumId;
  final String text;
  final String userId;

  const AddCommentParams({
    required this.forumId,
    required this.text,
    required this.userId,
  });

  @override
  List<Object> get props => [forumId, text, userId];
}
