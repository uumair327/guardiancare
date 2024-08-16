import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardianscare/src/constants/colors.dart';
import 'package:guardianscare/src/features/forum/models/Comment.dart';
import 'package:guardianscare/src/features/forum/models/Forum.dart';
import 'package:guardianscare/src/features/forum/screens/CommentInput.dart';
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
          padding: const EdgeInsets.all(15),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;

          return Column(
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
                          style: TextStyle(
                            fontSize: isTablet ? 24.0 : 20.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(239, 72, 53, 1),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yy - hh:mm a')
                              .format(forum.createdAt),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          forum.description,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: isTablet ? 18.0 : 14.0),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        StreamBuilder<QuerySnapshot>(
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
                                .map((doc) => Comment.fromMap(
                                    doc.data() as Map<String, dynamic>))
                                .toList();
                            return Column(
                              children: comments.map((comment) {
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(left: 6),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      UserDetails(userId: comment.userId),
                                      const SizedBox(height: 6),
                                      Text(
                                        comment.text,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Text(
                                      //   DateFormat('dd MMM yy - hh:mm a').format(comment.createdAt),
                                      //   style: TextStyle(
                                      //     color: Colors.grey.shade600,
                                      //     fontSize: isTablet ? 14 : 12,
                                      //   ),
                                      // ),
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
          );
        },
      ),
    );
  }
}

class UserDetails extends StatelessWidget {
  final String userId;

  const UserDetails({Key? key, required this.userId}) : super(key: key);

  Future<Map<String, String>> fetchUserDetails(String userId) async {
    var userName = "Anonymous",
        userImage = "",
        userEmail = "anonymous@mail.com";

    try {
      final userDetails = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDetails.exists) {
        userName = userDetails.data()?['displayName'] ?? "Anonymous";
        userImage = userDetails.data()?['photoURL'] ??
            "https://i.ibb.co/Qc9HnBr/logo-CIF-zoom.jpg";
        userEmail = userDetails.data()?['email'] ?? "anonymous@mail.com";
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }

    return {
      'userName': userName,
      'userImage': userImage,
      'userEmail': userEmail
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: fetchUserDetails(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var user = snapshot.data!;
        return Row(
          children: [
            CircleAvatar(
              backgroundImage: user['userImage']!.isNotEmpty
                  ? NetworkImage(user['userImage']!)
                  : null,
              child:
                  user['userImage']!.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['userName']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: tPrimaryColor,
                  ),
                ),
                Text(
                  user['userEmail']!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
