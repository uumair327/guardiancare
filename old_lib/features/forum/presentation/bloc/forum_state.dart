import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';

abstract class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {
  const ForumInitial();
}

class ForumLoading extends ForumState {
  const ForumLoading();
}

class ForumsLoaded extends ForumState {
  final List<ForumEntity> forums;
  final ForumCategory category;

  const ForumsLoaded(this.forums, this.category);

  @override
  List<Object> get props => [forums, category];
}

class CommentsLoaded extends ForumState {
  final List<CommentEntity> comments;
  final String forumId;

  const CommentsLoaded(this.comments, this.forumId);

  @override
  List<Object> get props => [comments, forumId];
}

class CommentSubmitting extends ForumState {
  const CommentSubmitting();
}

class CommentSubmitted extends ForumState {
  const CommentSubmitted();
}

class ForumError extends ForumState {
  final String message;
  final String? code;

  const ForumError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ForumCreated extends ForumState {
  final String forumId;

  const ForumCreated(this.forumId);

  @override
  List<Object> get props => [forumId];
}

class ForumDeleted extends ForumState {
  const ForumDeleted();
}
