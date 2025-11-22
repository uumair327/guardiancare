import 'package:equatable/equatable.dart';

/// Enum for forum categories
enum ForumCategory { parent, children }

/// Domain entity representing a forum post
class ForumEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final ForumCategory category;

  const ForumEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.category,
  });

  @override
  List<Object?> get props => [id, userId, title, description, createdAt, category];
}
