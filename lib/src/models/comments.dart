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


// import "package:flutter/material.dart";

// class Comment extends StatelessWidget {
//    final String text;
//     final String user;
//     final DateTime time;
//     const Comment({
//       super.key,
//       required this.text,
//       required this.user,
//       required this.time,
//     });
//     @override
//     Widget build (BuildContext context){
//       return Container (
//         decoration: BoxDecoration(
//           color:  Colors.grey[200],
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child:Column(children: [
//           Text(text),
//           //User , time 
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(user),
//               Text (" . ")
//             ],
//           ),
//         ],)
//       );
//     }
//   }