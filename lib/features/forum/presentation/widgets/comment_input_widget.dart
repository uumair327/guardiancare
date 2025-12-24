import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';

class CommentInputWidget extends StatefulWidget {
  final String forumId;

  const CommentInputWidget({super.key, required this.forumId});

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
        SnackBar(
          content: const Text('Please enter a comment'),
          backgroundColor: AppColors.warning,
          duration: AppDurations.snackbarShort,
        ),
      );
      return;
    }

    if (text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comment must be at least 2 characters'),
          backgroundColor: AppColors.warning,
          duration: AppDurations.snackbarShort,
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
    if (percentage >= 0.9) return AppColors.error;
    if (percentage >= 0.7) return AppColors.warning;
    return AppColors.textSecondary;
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
            padding: AppDimensions.paddingAllM,
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
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
                          fillColor: AppColors.inputBackground,
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide: BorderSide(color: AppColors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide: BorderSide(color: AppColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide: BorderSide(color: AppColors.primary, width: AppDimensions.borderThick),
                          ),
                          contentPadding: AppDimensions.inputPadding,
                          counterText: '',
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spaceS),
                    Container(
                      decoration: BoxDecoration(
                        color: _controller.text.trim().isNotEmpty && !isSubmitting
                            ? AppColors.primary
                            : AppColors.inputBorder,
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                      child: isSubmitting
                          ? Padding(
                              padding: AppDimensions.paddingAllM,
                              child: SizedBox(
                                width: AppDimensions.iconS,
                                height: AppDimensions.iconS,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _controller.text.trim().isNotEmpty && !isSubmitting
                                  ? () => _submitComment(context)
                                  : null,
                              color: _controller.text.trim().isNotEmpty && !isSubmitting
                                  ? AppColors.white
                                  : AppColors.textDisabled,
                            ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spaceXS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$_characterCount/$_maxCharacters',
                      style: AppTextStyles.caption.copyWith(
                        color: _getCharacterCountColor(),
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
