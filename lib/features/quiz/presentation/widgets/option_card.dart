import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Modern option card with animations and feedback
/// Shows correct/incorrect state with visual feedback
///
/// Uses centralized [ScaleTapWidget] for scale-tap animation,
/// eliminating duplicate animation code.
class OptionCard extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool showFeedback;
  final bool isCorrect;
  final VoidCallback? onTap;

  /// Custom animation config for option card (0.97 scale).
  static const _optionCardConfig = AnimationConfig(
    duration: AppDurations.animationShort,
    curve: AppCurves.tap,
    begin: 1.0,
    end: 0.97,
  );

  // Option labels
  static const List<String> _optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

  const OptionCard({
    super.key,
    required this.option,
    required this.index,
    required this.isSelected,
    this.showFeedback = false,
    this.isCorrect = false,
    this.onTap,
  });

  Color _backgroundColor(BuildContext context, bool isSelected,
      bool showFeedback, bool isCorrect) {
    if (showFeedback) {
      if (isCorrect) {
        return context.colors.success.withValues(alpha: 0.15);
      } else if (isSelected) {
        return context.colors.error.withValues(alpha: 0.15);
      }
    }
    if (isSelected) {
      return context.colors.primary.withValues(alpha: 0.1);
    }
    return context.colors.surface;
  }

  Color _borderColor(BuildContext context, bool isSelected, bool showFeedback,
      bool isCorrect) {
    if (showFeedback) {
      if (isCorrect) {
        return context.colors.success;
      } else if (isSelected) {
        return context.colors.error;
      }
    }
    if (isSelected) {
      return context.colors.primary;
    }
    return context.colors.border;
  }

  Color _labelColor(BuildContext context, bool isSelected, bool showFeedback,
      bool isCorrect) {
    if (showFeedback) {
      if (isCorrect) return context.colors.success;
      if (isSelected) return context.colors.error;
    }
    if (isSelected) return context.colors.primary;
    return context.colors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final label =
        index < _optionLabels.length ? _optionLabels[index] : '${index + 1}';

    final backgroundColor =
        _backgroundColor(context, isSelected, showFeedback, isCorrect);
    final borderColor =
        _borderColor(context, isSelected, showFeedback, isCorrect);
    final labelColor =
        _labelColor(context, isSelected, showFeedback, isCorrect);

    // Disable interaction when showing feedback or no onTap callback
    final isEnabled = !showFeedback && onTap != null;

    return ScaleTapWidget(
      config: _optionCardConfig,
      onTap: onTap,
      enabled: isEnabled,
      enableHaptic: true,
      hapticType: HapticFeedbackType.light,
      child: AppAnimatedContainer(
        padding: EdgeInsets.all(AppDimensions.spaceM),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppDimensions.borderRadiusM,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Option label badge
            AppAnimatedContainer(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isSelected ? labelColor : labelColor.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusS,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: isSelected ? AppColors.white : labelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppDimensions.spaceM),
            // Option text
            Expanded(
              child: Text(
                option,
                style: AppTextStyles.body1.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // Feedback icon
            if (showFeedback) ...[
              SizedBox(width: AppDimensions.spaceS),
              AnimatedScale(
                scale: 1.0,
                duration: AppDurations.animationShort,
                child: Icon(
                  isCorrect
                      ? Icons.check_circle_rounded
                      : (isSelected ? Icons.cancel_rounded : null),
                  color: isCorrect ? AppColors.success : AppColors.error,
                  size: AppDimensions.iconM,
                ),
              ),
            ] else if (isSelected) ...[
              SizedBox(width: AppDimensions.spaceS),
              Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.primary,
                size: AppDimensions.iconM,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
