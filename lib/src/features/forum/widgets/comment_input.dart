import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/controllers/comment_controller.dart';

class CommentInput extends StatefulWidget {
  final String forumId;
  const CommentInput({Key? key, required this.forumId}) : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  final CommentController _commentController = CommentController();

  Future<void> _addComment() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
    });
    try {
      await _commentController.addComment(
          widget.forumId, _controller.text.trim());
      _controller.clear();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to add comment. Please try again.')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(color: Color.fromRGBO(239, 72, 53, 1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(color: Color.fromRGBO(239, 72, 53, 1)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
            ),
          ),
          const SizedBox(width: 5),
          _loading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                  color: const Color.fromRGBO(239, 72, 53, 1),
                ),
        ],
      ),
    );
  }
}
