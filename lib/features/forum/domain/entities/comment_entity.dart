import 'package:equatable/equatable.dart';

/// Domain entity representing a comment on a forum post
class CommentEntity extends Equatable {

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.forumId,
    required this.text,
    required this.createdAt,
  });
  final String id;
  final String userId;
  final String forumId;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, forumId, text, createdAt];
}
