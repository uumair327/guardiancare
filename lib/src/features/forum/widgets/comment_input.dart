import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_bloc.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_event.dart';

class CommentInput extends StatefulWidget {
  final String forumId;

  const CommentInput({super.key, required this.forumId});

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  bool _loading = false;

  void _addComment() {
    if (_controller.text.trim().isEmpty) return;

    context.read<CommentBloc>().add(
      CommentAddRequested(
        forumId: widget.forumId,
        text: _controller.text.trim(),
      ),
    );
    _controller.clear();
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
