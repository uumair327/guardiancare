import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/forum/domain/repositories/forum_repository.dart';

class AddComment extends UseCase<void, AddCommentParams> {
  AddComment(this.repository);
  final ForumRepository repository;

  @override
  Future<Either<Failure, void>> call(AddCommentParams params) async {
    return repository.addComment(
      forumId: params.forumId,
      text: params.text,
      userId: params.userId,
      parentId: params.parentId,
    );
  }
}

class AddCommentParams extends Equatable {
  const AddCommentParams({
    required this.forumId,
    required this.text,
    required this.userId,
    this.parentId,
  });
  final String forumId;
  final String text;
  final String userId;
  final String? parentId;

  @override
  List<Object?> get props => [forumId, text, userId, parentId];
}
