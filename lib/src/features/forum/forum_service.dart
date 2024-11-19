import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/features/forum/models/comment.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Forum>> getForums() {
    return _firestore
        .collection('forum')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Forum.fromMap(doc.data()))
            .toList());
  }

  Future<void> addForum(String title, String description) async {
    final user = _auth.currentUser!;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    Forum forum = Forum(
      id: id,
      userId: user.uid,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('forum').doc(id).set(forum.toMap());
  }

  Stream<List<Comment>> getComments(String forumId) {
    return _firestore
        .collection('forum')
        .doc(forumId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Comment.fromMap(doc.data()))
            .toList());
  }

  Future<void> addComment(String forumId, String text) async {
    final user = _auth.currentUser!;
    final commentId = DateTime.now().microsecondsSinceEpoch.toString();
    Comment comment = Comment(
      id: commentId,
      userId: user.uid,
      forumId: forumId,
      text: text,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('forum')
        .doc(forumId)
        .collection('comments')
        .doc(commentId)
        .set(comment.toMap());
  }

  Future<Map<String, String>> fetchUserDetails(String userId) async {
    String userName = "Anonymous";
    String userImage = "";
    String userEmail = "anonymous@mail.com";

    try {
      final userDetails =
          await _firestore.collection('users').doc(userId).get();

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
      'userEmail': userEmail,
    };
  }
}
