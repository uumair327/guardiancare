import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/src/features/forum/models/comment.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';

class ForumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch only topics in the given category
  Stream<List<Forum>> getForums(ForumCategory category) {
    return _firestore
        .collection('forum')
        .where('category', isEqualTo: category == ForumCategory.parent ? 'parent' : 'children')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Forum.fromMap(doc.data()))
            .toList());
  }

  // Comments under a topic
  Stream<List<Comment>> getComments(String forumId) {
    return _firestore
        .collection('forum')
        .doc(forumId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Comment.fromMap(doc.data()))
            .toList());
  }

  // Add a new comment
  Future<void> addComment(String forumId, String text) async {
    final user = _auth.currentUser!;
    final commentId = DateTime.now().microsecondsSinceEpoch.toString();
    final comment = Comment(
      id:        commentId,
      userId:    user.uid,
      forumId:   forumId,
      text:      text,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('forum')
        .doc(forumId)
        .collection('comments')
        .doc(commentId)
        .set(comment.toMap());
  }
  // Fetch user details, including role
  Future<Map<String, String>> fetchUserDetails(String userId) async {
    String userName = 'Anonymous';
    String userImage = '';
    String userEmail = 'anonymous@mail.com';
    String role = 'child';

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        userName = data['displayName'] ?? userName;
        userImage = data['photoURL'] ?? userImage;
        userEmail = data['email'] ?? userEmail;
        role = data['role'] ?? role;
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }

    return {
      'userName': userName,
      'userImage': userImage,
      'userEmail': userEmail,
      'role': role,
    };
  }
}
