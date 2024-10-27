class Comment {
  String id;
  String userId;
  String forumId;
  String text;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.forumId,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['userId'],
      forumId: map['forumId'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'forumId': forumId,
      'text': text,
      'createdAt': createdAt.toString(),
    };
  }
}
