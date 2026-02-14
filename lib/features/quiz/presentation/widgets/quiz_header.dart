import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Modern header for quiz pages
/// Features gradient background, animated icon, and motivational text
class QuizHeader extends StatefulWidget {

  const QuizHeader({
    super.key,
    this.quizName,
    this.currentQuestion,
    this.totalQuestions,
    this.onBackPressed,
  });
  final String? quizName;
  final int? currentQuestion;
  final int? totalQuestions;
  final VoidCallback? onBackPressed;

  @override
  State<QuizHeader> createState() => _QuizHeaderState();
}

class _QuizHeaderState extends State<QuizHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _iconAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isInQuiz = widget.currentQuestion != null;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.screenPaddingH,
          AppDimensions.spaceM,
          AppDimensions.screenPaddingH,
          AppDimensions.spaceL,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.primary,
              context.colors.primary.withValues(alpha: 0.85),
              context.colors.primaryDark,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.radiusXL),
            bottomRight: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.onBackPressed != null) ...[
                      ScaleTapWidget(
                        onTap: widget.onBackPressed,
                        child: Container(
                          padding: const EdgeInsets.all(AppDimensions.spaceS),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: AppDimensions.borderRadiusS,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.white,
                            size: AppDimensions.iconM,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceM),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.quizName ?? l10n.quiz,
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Text(
                            isInQuiz
                                ? 'Question ${widget.currentQuestion} of ${widget.totalQuestions}'
                                : 'Test your knowledge',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _iconAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spaceM),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInQuiz
                              ? Icons.help_outline_rounded
                              : Icons.quiz_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconL,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isInQuiz) ...[
                  const SizedBox(height: AppDimensions.spaceM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceM,
                      vertical: AppDimensions.spaceS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusM,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: context.colors.warning,
                          size: AppDimensions.iconS,
                        ),
                        const SizedBox(width: AppDimensions.spaceS),
                        Expanded(
                          child: Text(
                            'Challenge yourself and learn something new!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
