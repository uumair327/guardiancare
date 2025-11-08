import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/core/logging/app_logger.dart';

class CommentInputBloc extends StatefulWidget {
  final String forumId;
  final String? parentCommentId;
  final VoidCallback? onCommentAdded;
  final String? placeholder;
  
  const CommentInputBloc({
    Key? key, 
    required this.forumId,
    this.parentCommentId,
    this.onCommentAdded,
    this.placeholder,
  }) : super(key: key);

  @override
  _CommentInputBlocState createState() => _CommentInputBlocState();
}

class _CommentInputBlocState extends State<CommentInputBloc> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  String? _validationError;
  String? _draftContent;
  int _characterCount = 0;
  bool _hasUnsavedChanges = false;

  static const int _maxCharacters = 1000;
  static const int _minCharacters = 2;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _loadDraft();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _characterCount = text.length;
      _hasUnsavedChanges = text.trim().isNotEmpty;
      _validationError = null;
    });
    
    _saveDraft(text);
    _validateInput(text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _hasUnsavedChanges) {
      _saveDraft(_controller.text);
    }
  }

  void _validateInput(String text) {
    final trimmedText = text.trim();
    
    if (trimmedText.isEmpty) {
      return;
    }
    
    if (trimmedText.length < _minCharacters) {
      setState(() {
        _validationError = 'Comment must be at least $_minCharacters characters long';
      });
      return;
    }
    
    if (trimmedText.length > _maxCharacters) {
      setState(() {
        _validationError = 'Comment cannot exceed $_maxCharacters characters';
      });
      return;
    }
    
    if (_validationError != null) {
      setState(() {
        _validationError = null;
      });
    }
  }

  void _addComment(BuildContext context) {
    final content = _controller.text.trim();
    
    if (content.isEmpty) {
      setState(() {
        _validationError = 'Please enter a comment';
      });
      return;
    }

    if (_validationError != null) {
      return;
    }

    // Dispatch submit comment event
    context.read<CommentBloc>().add(SubmitComment(widget.forumId, content));
    
    AppLogger.bloc('CommentBloc', 'SubmitComment', state: 'Submitting comment for forum ${widget.forumId}');
  }

  void _saveDraft(String content) {
    if (content.trim().isNotEmpty) {
      _draftContent = content;
      // TODO: Save to SharedPreferences or local storage
    }
  }

  void _loadDraft() {
    if (_draftContent != null && _draftContent!.isNotEmpty) {
      _controller.text = _draftContent!;
      _characterCount = _draftContent!.length;
      _hasUnsavedChanges = true;
    }
  }

  void _clearDraft() {
    _draftContent = null;
    // TODO: Remove from SharedPreferences or local storage
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  Color _getCharacterCountColor() {
    final percentage = _characterCount / _maxCharacters;
    if (percentage >= 0.9) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.grey;
  }

  bool _canSubmit(CommentState state) {
    return state is! CommentSubmitting && 
           _controller.text.trim().isNotEmpty && 
           _validationError == null &&
           _characterCount <= _maxCharacters;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentSubmitted) {
          // Clear the input and draft
          _controller.clear();
          _clearDraft();
          setState(() {
            _hasUnsavedChanges = false;
            _characterCount = 0;
          });

          _showSuccessMessage('Comment submitted successfully!');
          widget.onCommentAdded?.call();
          _focusNode.unfocus();
          
          AppLogger.feature('Forum', 'Comment submitted successfully');
        } else if (state is CommentError) {
          setState(() {
            _validationError = state.message;
          });
          
          _showErrorMessage(
            state.message,
            onRetry: () => _addComment(context),
          );
          
          AppLogger.error('Forum', 'Comment submission failed: ${state.message}');
        }
      },
      child: BlocBuilder<CommentBloc, CommentState>(
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
                          hintText: widget.placeholder ?? 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: tPrimaryColor, width: 2),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, 
                            vertical: 12.0,
                          ),
                          counterText: '',
                          suffixIcon: _hasUnsavedChanges
                              ? Icon(
                                  Icons.edit,
                                  color: Colors.grey[400],
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _canSubmit(state) ? tPrimaryColor : Colors.grey[300],
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
                              onPressed: _canSubmit(state) ? () => _addComment(context) : null,
                              color: _canSubmit(state) ? Colors.white : Colors.grey[500],
                              tooltip: _canSubmit(state) ? 'Send comment' : 'Enter a valid comment',
                            ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_validationError != null)
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else if (_hasUnsavedChanges)
                      const Text(
                        'Draft saved',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    
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
