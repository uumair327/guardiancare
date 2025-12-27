import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Category filter chip with animation
/// Used for filtering videos by category
class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
          HapticFeedback.selectionClick();
        },
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
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
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary
                  : AppColors.white,
              borderRadius: AppDimensions.borderRadiusL,
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : AppColors.border,
                width: 1.5,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: AppDimensions.iconS,
                    color: widget.isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                  SizedBox(width: AppDimensions.spaceXS),
                ],
                Text(
                  widget.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: widget.isSelected
                        ? AppColors.white
                        : AppColors.textPrimary,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
                if (widget.isSelected) ...[
                  SizedBox(width: AppDimensions.spaceXS),
                  Icon(
                    Icons.check_rounded,
                    size: AppDimensions.iconXS,
                    color: AppColors.white,
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
