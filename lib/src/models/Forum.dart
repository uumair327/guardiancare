class Forum {
  String id , userId , title , description; 
  DateTime createdAt;
  
  Forum({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toString(),
    };
  }

}