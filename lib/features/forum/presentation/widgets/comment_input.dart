import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';

/// Comment Input with educational-friendly design
///
/// Features:
/// - Animated send button
/// - Character counter with color feedback
/// - Glassmorphism style
/// - Haptic feedback
class CommentInput extends StatefulWidget {
  final String forumId;

  const CommentInput({super.key, required this.forumId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  static const int _maxCharacters = 1000;
  int _characterCount = 0;
  bool _isFocused = false;

  static Color get _primaryColor => AppColors.videoPrimary;
  static Color get _secondaryColor => AppColors.videoPrimaryDark;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _submitComment(BuildContext context) {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.white, size: 20),
              SizedBox(width: AppDimensions.spaceS),
              Text(FeedbackStrings.enterComment),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          duration: AppDurations.snackbarShort,
        ),
      );
      return;
    }

    if (text.length < 2) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.white, size: 20),
              SizedBox(width: AppDimensions.spaceS),
              Text(FeedbackStrings.commentTooShort),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          duration: AppDurations.snackbarShort,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

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
    return context.colors.textSecondary;
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is CommentSubmitted) {
          _controller.clear();
          setState(() => _characterCount = 0);
          _focusNode.unfocus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.white, size: 20),
                  SizedBox(width: AppDimensions.spaceS),
                  Text(FeedbackStrings.commentPosted),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              duration: AppDurations.snackbarShort,
            ),
          );
        }
      },
      child: BlocBuilder<ForumBloc, ForumState>(
        buildWhen: (previous, current) {
          return current is CommentSubmitting || current is CommentSubmitted;
        },
        builder: (context, state) {
          final isSubmitting = state is CommentSubmitting;

          return Container(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingH,
              AppDimensions.spaceM,
              AppDimensions.screenPaddingH,
              AppDimensions.spaceM + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: _isFocused
                      ? _primaryColor.withValues(alpha: 0.3)
                      : context.colors.divider.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: AppDurations.animationShort,
                        decoration: BoxDecoration(
                          color: context.colors.background,
                          borderRadius: AppDimensions.borderRadiusL,
                          border: Border.all(
                            color: _isFocused
                                ? _primaryColor.withValues(alpha: 0.5)
                                : context.colors.divider,
                            width: _isFocused ? 1.5 : 1,
                          ),
                          boxShadow: _isFocused
                              ? [
                                  BoxShadow(
                                    color: _primaryColor.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: TextField(
                          controller: _controller,
                          onTapOutside: (_) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          focusNode: _focusNode,
                          maxLines: 4,
                          minLines: 1,
                          maxLength: _maxCharacters,
                          enabled: !isSubmitting,
                          textCapitalization: TextCapitalization.sentences,
                          style: AppTextStyles.body2.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: ForumStrings.shareYourThoughts,
                            hintStyle: AppTextStyles.body2.copyWith(
                              color: context.colors.textSecondary
                                  .withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceM,
                              vertical: AppDimensions.spaceM,
                            ),
                            counterText: '',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: AppDimensions.spaceM,
                                right: AppDimensions.spaceS,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: _isFocused
                                    ? _primaryColor
                                    : context.colors.textSecondary,
                                size: 20,
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.spaceS),
                    GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) => _animationController.reverse(),
                      onTapCancel: () => _animationController.reverse(),
                      onTap: _canSubmit && !isSubmitting
                          ? () => _submitComment(context)
                          : null,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          );
                        },
                        child: AnimatedContainer(
                          duration: AppDurations.animationShort,
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _canSubmit && !isSubmitting
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [_primaryColor, _secondaryColor],
                                  )
                                : null,
                            color: _canSubmit && !isSubmitting
                                ? null
                                : context.colors.divider,
                            borderRadius: AppDimensions.borderRadiusM,
                            boxShadow: _canSubmit && !isSubmitting
                                ? [
                                    BoxShadow(
                                      color:
                                          _primaryColor.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.send_rounded,
                                    color: _canSubmit
                                        ? AppColors.white
                                        : context.colors.textSecondary,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.spaceS),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ForumStrings.beRespectful,
                      style: AppTextStyles.caption.copyWith(
                        color:
                            context.colors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                    AnimatedDefaultTextStyle(
                      duration: AppDurations.animationShort,
                      style: AppTextStyles.caption.copyWith(
                        color: _getCharacterCountColor(),
                        fontWeight: _characterCount > _maxCharacters * 0.8
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      child: Text('$_characterCount/$_maxCharacters'),
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
