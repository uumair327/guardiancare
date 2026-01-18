import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern animated menu item for profile settings
class ProfileMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool showArrow;
  final bool isDanger;
  final Widget? trailing;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.showArrow = true,
    this.isDanger = false,
    this.trailing,
  });

  @override
  State<ProfileMenuItem> createState() => _ProfileMenuItemState();
}

class _ProfileMenuItemState extends State<ProfileMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  Color get _iconColor {
    if (widget.isDanger) return AppColors.error;
    return widget.iconColor ?? AppColors.primary;
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
          child: AnimatedContainer(
            duration: AppDurations.animationShort,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceM,
            ),
            decoration: BoxDecoration(
              color: _isPressed
                  ? _iconColor.withValues(alpha: 0.05)
                  : context.colors.surface,
              borderRadius: AppDimensions.borderRadiusM,
              border: Border.all(
                color: _isPressed
                    ? _iconColor.withValues(alpha: 0.2)
                    : context.colors.divider.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(AppDimensions.spaceS),
                  decoration: BoxDecoration(
                    color: _iconColor.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderRadiusS,
                  ),
                  child: Icon(
                    widget.icon,
                    color: _iconColor,
                    size: AppDimensions.iconM,
                  ),
                ),
                SizedBox(width: AppDimensions.spaceM),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.body1.copyWith(
                          color: widget.isDanger
                              ? AppColors.error
                              : context.colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: AppDimensions.spaceXXS),
                        Text(
                          widget.subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing widget or arrow
                if (widget.trailing != null)
                  widget.trailing!
                else if (widget.showArrow)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.textSecondary,
                    size: AppDimensions.iconM,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
