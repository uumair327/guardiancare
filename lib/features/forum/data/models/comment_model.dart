import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';

/// Data model for Comment that extends the domain entity
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.forumId,
    required super.text,
    required super.createdAt,
    super.parentId,
  });

  /// Create CommentModel from Firestore document
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      forumId: map['forumId'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      parentId: map['parentId'] as String?,
    );
  }

  /// Convert CommentModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'forumId': forumId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      if (parentId != null) 'parentId': parentId,
    };
  }

  /// Create a copy with updated fields
  CommentModel copyWith({
    String? id,
    String? userId,
    String? forumId,
    String? text,
    DateTime? createdAt,
    String? parentId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      forumId: forumId ?? this.forumId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
    );
  }
}
