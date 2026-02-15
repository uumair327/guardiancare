import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';

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
  const ForumsLoaded({
    this.parentForums = const [],
    this.childrenForums = const [],
    this.isLoadingParent = false,
    this.isLoadingChildren = false,
    this.error,
  });

  final List<ForumEntity> parentForums;
  final List<ForumEntity> childrenForums;
  final bool isLoadingParent;
  final bool isLoadingChildren;
  final String? error;

  @override
  List<Object?> get props => [
        parentForums,
        childrenForums,
        isLoadingParent,
        isLoadingChildren,
        error,
      ];

  ForumsLoaded copyWith({
    List<ForumEntity>? parentForums,
    List<ForumEntity>? childrenForums,
    bool? isLoadingParent,
    bool? isLoadingChildren,
    String? error,
  }) {
    return ForumsLoaded(
      parentForums: parentForums ?? this.parentForums,
      childrenForums: childrenForums ?? this.childrenForums,
      isLoadingParent: isLoadingParent ?? this.isLoadingParent,
      isLoadingChildren: isLoadingChildren ?? this.isLoadingChildren,
      error: error,
    );
  }
}

class CommentsLoaded extends ForumState {
  const CommentsLoaded(this.comments, this.forumId);
  final List<CommentEntity> comments;
  final String forumId;

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
  const ForumError(this.message, {this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class ForumCreated extends ForumState {
  const ForumCreated(this.forumId);
  final String forumId;

  @override
  List<Object> get props => [forumId];
}

class ForumDeleted extends ForumState {
  const ForumDeleted();
}
