import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Animated stat card for profile page
/// Shows achievements, progress, or other stats
class ProfileStatCard extends StatefulWidget {

  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
    this.index = 0,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
  final int index;

  @override
  State<ProfileStatCard> createState() => _ProfileStatCardState();
}

class _ProfileStatCardState extends State<ProfileStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Color get _cardColor =>
      widget.color ?? AppColors.cardPalette[widget.index % AppColors.cardPalette.length];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
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
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.borderRadiusL,
              boxShadow: [
                BoxShadow(
                  color: _cardColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _cardColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceS),
                  decoration: BoxDecoration(
                    color: _cardColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: _cardColor,
                    size: AppDimensions.iconM,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Text(
                  widget.value,
                  style: AppTextStyles.h3.copyWith(
                    color: _cardColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXXS),
                Text(
                  widget.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
