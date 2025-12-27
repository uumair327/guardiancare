import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern option card with animations and feedback
/// Shows correct/incorrect state with visual feedback
class OptionCard extends StatefulWidget {
  final String option;
  final int index;
  final bool isSelected;
  final bool showFeedback;
  final bool isCorrect;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.index,
    required this.isSelected,
    this.showFeedback = false,
    this.isCorrect = false,
    this.onTap,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Option labels
  static const List<String> _optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.showFeedback || widget.onTap == null) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    if (widget.showFeedback) {
      if (widget.isCorrect) {
        return AppColors.success.withValues(alpha: 0.15);
      } else if (widget.isSelected) {
        return AppColors.error.withValues(alpha: 0.15);
      }
    }
    if (widget.isSelected) {
      return AppColors.primary.withValues(alpha: 0.1);
    }
    return AppColors.surface;
  }

  Color get _borderColor {
    if (widget.showFeedback) {
      if (widget.isCorrect) {
        return AppColors.success;
      } else if (widget.isSelected) {
        return AppColors.error;
      }
    }
    if (widget.isSelected) {
      return AppColors.primary;
    }
    return AppColors.divider;
  }

  Color get _labelColor {
    if (widget.showFeedback) {
      if (widget.isCorrect) return AppColors.success;
      if (widget.isSelected) return AppColors.error;
    }
    if (widget.isSelected) return AppColors.primary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.index < _optionLabels.length
        ? _optionLabels[widget.index]
        : '${widget.index + 1}';

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.showFeedback ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: AppDurations.animationShort,
            curve: AppCurves.standard,
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: AppDimensions.borderRadiusM,
              border: Border.all(
                color: _borderColor,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: _borderColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Option label badge
                AnimatedContainer(
                  duration: AppDurations.animationShort,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? _labelColor
                        : _labelColor.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderRadiusS,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: AppTextStyles.body1.copyWith(
                        color: widget.isSelected
                            ? AppColors.white
                            : _labelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.spaceM),
                // Option text
                Expanded(
                  child: Text(
                    widget.option,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                // Feedback icon
                if (widget.showFeedback) ...[
                  SizedBox(width: AppDimensions.spaceS),
                  AnimatedScale(
                    scale: 1.0,
                    duration: AppDurations.animationShort,
                    child: Icon(
                      widget.isCorrect
                          ? Icons.check_circle_rounded
                          : (widget.isSelected
                              ? Icons.cancel_rounded
                              : null),
                      color: widget.isCorrect
                          ? AppColors.success
                          : AppColors.error,
                      size: AppDimensions.iconM,
                    ),
                  ),
                ] else if (widget.isSelected) ...[
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
        ),
      ),
    );
  }
}
