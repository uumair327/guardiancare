import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/controllers/comment_controller.dart';
import 'package:guardiancare/src/features/forum/services/comment_submission_service.dart';
import 'package:guardiancare/src/constants/colors.dart';

class CommentInput extends StatefulWidget {
  final String forumId;
  final String? parentCommentId;
  final VoidCallback? onCommentAdded;
  final String? placeholder;
  
  const CommentInput({
    Key? key, 
    required this.forumId,
    this.parentCommentId,
    this.onCommentAdded,
    this.placeholder,
  }) : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final CommentController _commentController = CommentController();
  final CommentSubmissionService _submissionService = CommentSubmissionService.instance;
  
  bool _isSubmitting = false;
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
      _validationError = null; // Clear validation error on text change
    });
    
    // Auto-save draft
    _saveDraft(text);
    
    // Real-time validation
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
      return; // Don't show error for empty text
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
    
    // Clear validation error if text is valid
    if (_validationError != null) {
      setState(() {
        _validationError = null;
      });
    }
  }

  Future<void> _addComment() async {
    final content = _controller.text.trim();
    
    if (content.isEmpty) {
      setState(() {
        _validationError = 'Please enter a comment';
      });
      return;
    }

    if (_isSubmitting) return; // Prevent duplicate submissions

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    try {
      // Use the enhanced submission service
      final result = await _submissionService.submitComment(
        content: content,
        postId: widget.forumId,
        userId: 'current_user_id', // In real app, get from auth service
        parentCommentId: widget.parentCommentId,
      );

      if (result.success) {
        // Clear the input and draft
        _controller.clear();
        _clearDraft();
        setState(() {
          _hasUnsavedChanges = false;
          _characterCount = 0;
        });

        // Show success feedback
        _showSuccessMessage(result.message);
        
        // Notify parent widget
        widget.onCommentAdded?.call();
        
        // Unfocus the input
        _focusNode.unfocus();
        
      } else {
        // Handle submission failure
        setState(() {
          _validationError = result.message;
        });
        
        _showErrorMessage(result.message);
      }
      
    } catch (e) {
      setState(() {
        _validationError = 'An unexpected error occurred. Please try again.';
      });
      
      _showErrorMessage('Failed to submit comment: ${e.toString()}');
      
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  /// Save draft content to preserve user input
  void _saveDraft(String content) {
    if (content.trim().isNotEmpty) {
      _draftContent = content;
      // In a real app, save to SharedPreferences or local storage
    }
  }

  /// Load draft content if available
  void _loadDraft() {
    if (_draftContent != null && _draftContent!.isNotEmpty) {
      _controller.text = _draftContent!;
      _characterCount = _draftContent!.length;
      _hasUnsavedChanges = true;
    }
  }

  /// Clear saved draft
  void _clearDraft() {
    _draftContent = null;
    // In a real app, remove from SharedPreferences or local storage
  }

  /// Show success message
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

  /// Show error message
  void _showErrorMessage(String message) {
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
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _addComment,
        ),
      ),
    );
  }

  /// Get character count color based on usage
  Color _getCharacterCountColor() {
    final percentage = _characterCount / _maxCharacters;
    if (percentage >= 0.9) return Colors.red;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.grey;
  }

  /// Check if submit button should be enabled
  bool _canSubmit() {
    return !_isSubmitting && 
           _controller.text.trim().isNotEmpty && 
           _validationError == null &&
           _characterCount <= _maxCharacters;
  }

  @override
  Widget build(BuildContext context) {
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
          // Main input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 1,
                      maxLength: _maxCharacters,
                      enabled: !_isSubmitting,
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
                        counterText: '', // Hide default counter
                        suffixIcon: _hasUnsavedChanges
                            ? Icon(
                                Icons.edit,
                                color: Colors.grey[400],
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Submit button
              Container(
                decoration: BoxDecoration(
                  color: _canSubmit() ? tPrimaryColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isSubmitting
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
                        onPressed: _canSubmit() ? _addComment : null,
                        color: _canSubmit() ? Colors.white : Colors.grey[500],
                        tooltip: _canSubmit() ? 'Send comment' : 'Enter a valid comment',
                      ),
              ),
            ],
          ),
          
          // Character count and validation error
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Validation error
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
              
              // Character count
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
  }
}
