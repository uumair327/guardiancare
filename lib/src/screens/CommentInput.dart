import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/models/Comment.dart';

class CommentInput extends StatefulWidget {
  final String forumId;

  const CommentInput({Key? key, required this.forumId}) : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _addComment() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _loading = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    final userName = user.displayName ?? 'Anonymous';
    final userEmail = user.email!;

    final commentId = DateTime.now().microsecondsSinceEpoch.toString();
    final comment = Comment(
      id: commentId,
      userId: user.uid,
      userName: userName,
      userEmail: userEmail,
      forumId: widget.forumId,
      text: _controller.text,
      createdAt: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.forumId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());

      _controller.clear();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _loading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
        ],
      ),
    );
  }
}
