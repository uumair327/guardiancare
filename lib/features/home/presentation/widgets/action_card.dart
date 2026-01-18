import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Action Card with 3D effects and animations
///
/// Features:
/// - 3D tilt effect on touch
/// - Scale animation on tap
/// - Gradient background
/// - Glassmorphism option
/// - Haptic feedback
/// - Performance optimized
class ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enableGlassmorphism;
  final bool enable3DEffect;

  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.enableGlassmorphism = false,
    this.enable3DEffect = true,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;
  Offset _tiltOffset = Offset.zero;

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

    _elevationAnimation = Tween<double>(begin: 8.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enable3DEffect) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = details.localPosition;

    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);

    setState(() {
      _tiltOffset = Offset(
        dy.clamp(-1.0, 1.0) * 0.08,
        -dx.clamp(-1.0, 1.0) * 0.08,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltOffset = Offset.zero;
    });
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
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppDurations.animationShort,
                curve: AppCurves.standard,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltOffset.dx)
                  ..rotateY(_tiltOffset.dy),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppDimensions.borderRadiusL,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color
                          .withValues(alpha: _isPressed ? 0.3 : 0.2),
                      blurRadius: _elevationAnimation.value * 2,
                      offset: Offset(
                        _tiltOffset.dy * 15,
                        _tiltOffset.dx * 15 + _elevationAnimation.value / 2,
                      ),
                      spreadRadius: _isPressed ? 0 : 2,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.enableGlassmorphism
              ? _buildGlassmorphicContent()
              : _buildStandardContent(),
        ),
      ),
    );
  }

  Widget _buildStandardContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.surface,
            context.colors.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: widget.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: _buildCardContent(),
    );
  }

  Widget _buildGlassmorphicContent() {
    return GlassmorphicContainer(
      blur: 10,
      opacity: 0.15,
      borderRadius: AppDimensions.borderRadiusL,
      padding: EdgeInsets.zero,
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon container
        AnimatedContainer(
          duration: AppDurations.animationShort,
          padding: EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: _isPressed ? 0.2 : 0.1),
                widget.color.withValues(alpha: _isPressed ? 0.15 : 0.05),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: AppDimensions.iconL,
          ),
        ),
        SizedBox(height: AppDimensions.spaceS),
        // Label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceXS),
          child: Text(
            widget.label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
