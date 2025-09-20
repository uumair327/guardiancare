import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String userId;
  final String forumId;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.forumId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      forumId: map['forumId'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'forumId': forumId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? userId,
    String? forumId,
    String? text,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      forumId: forumId ?? this.forumId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, userId, forumId, text, createdAt];

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId, forumId: $forumId, text: $text, createdAt: $createdAt)';
  }
}
