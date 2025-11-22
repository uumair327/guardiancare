import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_event.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_state.dart';
import 'package:guardiancare/src/constants/colors.dart';

class CommentInputWidget extends StatefulWidget {
  final String forumId;

  const CommentInputWidget({Key? key, required this.forumId}) : super(key: key);

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  static const int _maxCharacters = 1000;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  void _submitComment(BuildContext context) {
    final text = _controller.text.trim();
    
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment must be at least 2 characters'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Submit comment via BLoC
    context.read<ForumBloc>().add(
          SubmitComment(
            forumId: widget.forumId,
            text: text,
          ),
        );
  }

  Color _getCharacterCountColor() {
    final percentage = _characterCount / _maxCharacters;
    if (percentage >= 0.9) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is CommentSubmitted) {
          // Clear the input
          _controller.clear();
          setState(() {
            _characterCount = 0;
          });
          _focusNode.unfocus();
        }
      },
      child: BlocBuilder<ForumBloc, ForumState>(
        buildWhen: (previous, current) {
          return current is CommentSubmitting || current is CommentSubmitted;
        },
        builder: (context, state) {
          final isSubmitting = state is CommentSubmitting;
          
          return Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        minLines: 1,
                        maxLength: _maxCharacters,
                        enabled: !isSubmitting,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: tPrimaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _controller.text.trim().isNotEmpty && !isSubmitting
                            ? tPrimaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _controller.text.trim().isNotEmpty && !isSubmitting
                                  ? () => _submitComment(context)
                                  : null,
                              color: _controller.text.trim().isNotEmpty && !isSubmitting
                                  ? Colors.white
                                  : Colors.grey[500],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$_characterCount/$_maxCharacters',
                      style: TextStyle(
                        color: _getCharacterCountColor(),
                        fontSize: 12,
                        fontWeight: _characterCount > _maxCharacters * 0.8
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
