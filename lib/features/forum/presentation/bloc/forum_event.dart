import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';

abstract class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object?> get props => [];
}

class LoadForums extends ForumEvent {

  const LoadForums(this.category);
  final ForumCategory category;

  @override
  List<Object> get props => [category];
}

class LoadComments extends ForumEvent {

  const LoadComments(this.forumId);
  final String forumId;

  @override
  List<Object> get props => [forumId];
}

class SubmitComment extends ForumEvent {

  const SubmitComment({
    required this.forumId,
    required this.text,
  });
  final String forumId;
  final String text;

  @override
  List<Object> get props => [forumId, text];
}

class CreateForum extends ForumEvent {

  const CreateForum({
    required this.title,
    required this.description,
    required this.category,
  });
  final String title;
  final String description;
  final ForumCategory category;

  @override
  List<Object> get props => [title, description, category];
}

class DeleteForum extends ForumEvent {

  const DeleteForum(this.forumId);
  final String forumId;

  @override
  List<Object> get props => [forumId];
}

class DeleteComment extends ForumEvent {

  const DeleteComment({
    required this.forumId,
    required this.commentId,
  });
  final String forumId;
  final String commentId;

  @override
  List<Object> get props => [forumId, commentId];
}

class RefreshForums extends ForumEvent {

  const RefreshForums(this.category);
  final ForumCategory category;

  @override
  List<Object> get props => [category];
}
