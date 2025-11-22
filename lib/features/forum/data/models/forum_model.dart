import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';

/// Data model for Forum that extends the domain entity
class ForumModel extends ForumEntity {
  const ForumModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.category,
  });

  /// Create ForumModel from Firestore document
  factory ForumModel.fromMap(Map<String, dynamic> map) {
    return ForumModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      category: (map['category'] as String) == 'parent'
          ? ForumCategory.parent
          : ForumCategory.children,
    );
  }

  /// Convert ForumModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'category': category == ForumCategory.parent ? 'parent' : 'children',
    };
  }

  /// Create a copy with updated fields
  ForumModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    ForumCategory? category,
  }) {
    return ForumModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
