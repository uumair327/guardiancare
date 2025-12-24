import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class LoadForums extends ForumEvent {
  final ForumCategory category;

  const LoadForums(this.category);

  @override
  List<Object> get props => [category];
}

class LoadComments extends ForumEvent {
  final String forumId;

  const LoadComments(this.forumId);

  @override
  List<Object> get props => [forumId];
}

class SubmitComment extends ForumEvent {
  final String forumId;
  final String text;

  const SubmitComment({
    required this.forumId,
    required this.text,
  });

  @override
  List<Object> get props => [forumId, text];
}

class CreateForum extends ForumEvent {
  final String title;
  final String description;
  final ForumCategory category;

  const CreateForum({
    required this.title,
    required this.description,
    required this.category,
  });

  @override
  List<Object> get props => [title, description, category];
}

class DeleteForum extends ForumEvent {
  final String forumId;

  const DeleteForum(this.forumId);

  @override
  List<Object> get props => [forumId];
}

class DeleteComment extends ForumEvent {
  final String forumId;
  final String commentId;

  const DeleteComment({
    required this.forumId,
    required this.commentId,
  });

  @override
  List<Object> get props => [forumId, commentId];
}

class RefreshForums extends ForumEvent {
  final ForumCategory category;

  const RefreshForums(this.category);

  @override
  List<Object> get props => [category];
}
