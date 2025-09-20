import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Forum extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;

  const Forum({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Forum.fromMap(Map<String, dynamic> map) {
    return Forum(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Forum copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Forum(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, userId, title, description, createdAt];

  @override
  String toString() {
    return 'Forum(id: $id, userId: $userId, title: $title, description: $description, createdAt: $createdAt)';
  }
}
