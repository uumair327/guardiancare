import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/models/Comment.dart';
import 'package:guardiancare/src/features/forum/models/Forum.dart';
import 'package:guardiancare/src/features/forum/screens/CommentInput.dart';
import 'package:intl/intl.dart';

class ForumWidget extends StatelessWidget {
  final Forum forum;

  const ForumWidget({Key? key, required this.forum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForumDetailPage(forum: forum),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 30),
        child: Container(
          // margin: const EdgeInsets.only(bottom: 30),
          padding: const EdgeInsets.all(15),

          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.grey.shade300),
          //   borderRadius: BorderRadius.circular(10),
          // ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                forum.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(239, 72, 53, 1),
                ),
              ),
              Text(
                DateFormat('dd MMM yy - hh:mm a').format(forum.createdAt),
              ),
              const SizedBox(height: 10),
              Text(
                forum.description,
                textAlign: TextAlign.left,
              ),
              // const Divider(),
              // StreamBuilder(
              //   stream: FirebaseFirestore.instance
              //       .collection('forum')
              //       .doc(forum.id)
              //       .collection('comments')
              //       .snapshots(),
              //   builder: (context, snapshot) {
              //     if (!snapshot.hasData) {
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //     var comments = snapshot.data!.docs
              //         .map((doc) => Comment.fromMap(doc.data()))
              //         .toList();
              //     return Column(
              //       children: comments.map((comment) {
              //         return ListTile(
              //           title: Text(
              //             comment.userName,
              //             style: const TextStyle(fontWeight: FontWeight.bold),
              //           ),
              //           subtitle: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 comment.userEmail,
              //                 style: TextStyle(
              //                     color: Colors.grey.shade600, fontSize: 12),
              //               ),
              //               Text(
              //                 comment.text,
              //                 textAlign: TextAlign.left,
              //               ),
              //               Text(
              //                 DateFormat('dd MMM yy - hh:mm a')
              //                     .format(comment.createdAt),
              //                 style: TextStyle(
              //                     color: Colors.grey.shade600, fontSize: 12),
              //               ),
              //             ],
              //           ),
              //           isThreeLine: true,
              //         );
              //       }).toList(),
              //     );
              //   },
              // ),
              // const Divider(),
              // CommentInput(forumId: forum.id),
            ],
          ),
        ),
      ),
    );
  }
}

class ForumDetailPage extends StatelessWidget {
  final Forum forum;

  const ForumDetailPage({Key? key, required this.forum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forum.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forum.title,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(239, 72, 53, 1),
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yy - hh:mm a').format(forum.createdAt),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      forum.description,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('forum')
                          .doc(forum.id)
                          .collection('comments')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        var comments = snapshot.data!.docs
                            .map((doc) => Comment.fromMap(doc.data()))
                            .toList();
                        return Column(
                          children: comments.map((comment) {
                            return ListTile(
                              // title: Text(
                              //   comment.userName,
                              //   style: const TextStyle(fontWeight: FontWeight.bold),
                              // ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.userEmail,
                                    style: const TextStyle(
                                        color: Color.fromRGBO(239, 72, 53, 1),
                                        fontSize: 12),
                                  ),
                                  Text(
                                    comment.text,
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    DateFormat('dd MMM yy - hh:mm a')
                                        .format(comment.createdAt),
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: CommentInput(forumId: forum.id),
          ),
        ],
      ),
    );
  }
}
