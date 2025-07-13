enum ForumCategory { parent, children }

class Forum {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final ForumCategory category;

  Forum({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.category,
  });

  factory Forum.fromMap(Map<String, dynamic> map) {
    return Forum(
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
}
