import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'progress_indicator.dart';

/// Modern result card for quiz completion
/// Shows score with animations and encouraging feedback
class ResultCard extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;

  const ResultCard({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    this.onRetry,
    this.onBack,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _percentage => widget.correctAnswers / widget.totalQuestions;

  String get _feedbackTitle {
    if (_percentage >= 0.9) return UIStrings.excellentFeedback;
    if (_percentage >= 0.7) return UIStrings.greatJobFeedback;
    if (_percentage >= 0.5) return UIStrings.goodEffortFeedback;
    return UIStrings.keepLearningFeedback;
  }

  String get _feedbackMessage {
    if (_percentage >= 0.9) return UIStrings.quizMasterMessage;
    if (_percentage >= 0.7) return UIStrings.doingGreatMessage;
    if (_percentage >= 0.5) return UIStrings.onRightTrackMessage;
    return UIStrings.practiceMessage;
  }

  Color get _resultColor {
    if (_percentage >= 0.7) return AppColors.success;
    if (_percentage >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.borderRadiusXL,
            boxShadow: [
              BoxShadow(
                color: _resultColor.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceL),
                decoration: BoxDecoration(
                  color: _resultColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _percentage >= 0.7
                      ? Icons.emoji_events_rounded
                      : Icons.school_rounded,
                  color: _resultColor,
                  size: AppDimensions.iconXXL,
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),
              // Feedback title
              Text(
                _feedbackTitle,
                style: AppTextStyles.h2.copyWith(
                  color: _resultColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                _feedbackMessage,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXL),
              // Circular progress
              QuizCircularProgress(
                progress: _percentage,
                size: 140,
                strokeWidth: 12,
                activeColor: _resultColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_percentage * 100).round()}%',
                      style: AppTextStyles.h1.copyWith(
                        color: _resultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      UIStrings.score,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),
              // Score details
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.check_circle_rounded,
                      label: UIStrings.correct,
                      value: '${widget.correctAnswers}',
                      color: AppColors.success,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider,
                    ),
                    _buildStatItem(
                      icon: Icons.cancel_rounded,
                      label: UIStrings.wrong,
                      value: '${widget.totalQuestions - widget.correctAnswers}',
                      color: AppColors.error,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.divider,
                    ),
                    _buildStatItem(
                      icon: Icons.quiz_rounded,
                      label: UIStrings.total,
                      value: '${widget.totalQuestions}',
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceXL),
              // Action buttons
              Row(
                children: [
                  if (widget.onRetry != null)
                    Expanded(
                      child: ScaleTapWidget(
                        onTap: widget.onRetry,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spaceM,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          child: Center(
                            child: Text(
                              UIStrings.tryAgainButton,
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.onRetry != null && widget.onBack != null)
                    SizedBox(width: AppDimensions.spaceM),
                  if (widget.onBack != null)
                    Expanded(
                      child: ScaleTapWidget(
                        onTap: widget.onBack,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.spaceM,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: AppDimensions.borderRadiusM,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.backToQuizzes,
                              style: AppTextStyles.button,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppDimensions.iconS),
        SizedBox(height: AppDimensions.spaceXS),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
