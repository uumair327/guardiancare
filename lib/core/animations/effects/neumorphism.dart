import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/constants/app_dimensions.dart';

/// Neumorphic design effect container
/// 
/// Features:
/// - Soft UI shadows
/// - Pressed/unpressed states
/// - Customizable depth
/// - Performance optimized
class NeumorphicContainer extends StatelessWidget {

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.depth = 5.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.isPressed = false,
    this.lightShadowColor,
    this.darkShadowColor,
  });
  final Widget child;
  final double depth;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool isPressed;
  final Color? lightShadowColor;
  final Color? darkShadowColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.background;
    final radius = borderRadius ?? AppDimensions.borderRadiusM;
    final lightShadow = lightShadowColor ?? AppColors.white;
    final darkShadow = darkShadowColor ?? AppColors.gray300;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        padding: padding ?? AppDimensions.paddingAllM,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
          boxShadow: isPressed
              ? [
                  // Inner shadow effect for pressed state
                  BoxShadow(
                    color: darkShadow,
                    offset: Offset(depth / 2, depth / 2),
                    blurRadius: depth,
                    spreadRadius: -depth / 2,
                  ),
                  BoxShadow(
                    color: lightShadow,
                    offset: Offset(-depth / 2, -depth / 2),
                    blurRadius: depth,
                    spreadRadius: -depth / 2,
                  ),
                ]
              : [
                  // Outer shadow effect for unpressed state
                  BoxShadow(
                    color: darkShadow,
                    offset: Offset(depth, depth),
                    blurRadius: depth * 2,
                  ),
                  BoxShadow(
                    color: lightShadow,
                    offset: Offset(-depth, -depth),
                    blurRadius: depth * 2,
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

/// Neumorphic button with press animation
class NeumorphicButton extends StatefulWidget {

  const NeumorphicButton({
    super.key,
    required this.child,
    this.onTap,
    this.depth = 5.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.enabled = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double depth;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool enabled;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.enabled ? widget.onTap : null,
      child: NeumorphicContainer(
        depth: widget.depth,
        backgroundColor: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        isPressed: _isPressed,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Neumorphic icon button
class NeumorphicIconButton extends StatefulWidget {

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48.0,
    this.depth = 4.0,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double depth;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.enabled ? widget.onTap : null,
      child: NeumorphicContainer(
        depth: widget.depth,
        backgroundColor: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.size / 2),
        padding: EdgeInsets.zero,
        width: widget.size,
        height: widget.size,
        isPressed: _isPressed,
        child: Center(
          child: Icon(
            widget.icon,
            color: widget.iconColor ?? AppColors.primary,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );
  }
}

/// Neumorphic progress indicator
class NeumorphicProgress extends StatelessWidget {

  const NeumorphicProgress({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });
  final double value; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.background;
    final progress = progressColor ?? AppColors.primary;
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return RepaintBoundary(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: AppColors.gray300,
              offset: Offset(2, 2),
              blurRadius: 4,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColors.white,
              offset: Offset(-2, -2),
              blurRadius: 4,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    progress,
                    progress.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
