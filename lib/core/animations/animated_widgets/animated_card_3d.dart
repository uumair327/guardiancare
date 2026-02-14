import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/constants/app_dimensions.dart';

/// 3D Animated Card with tilt effect on hover/touch
/// 
/// Features:
/// - Realistic 3D perspective tilt
/// - Smooth shadow animation
/// - Glassmorphism support
/// - Touch-responsive
/// - Performance optimized with RepaintBoundary
class AnimatedCard3D extends StatefulWidget {

  const AnimatedCard3D({
    super.key,
    required this.child,
    this.maxTilt = 0.05,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.shadowColor,
    this.elevation = 8.0,
    this.borderRadius,
    this.backgroundColor,
    this.enableGlassmorphism = false,
    this.onTap,
  });
  final Widget child;
  final double maxTilt;
  final Duration duration;
  final Curve curve;
  final Color? shadowColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final bool enableGlassmorphism;
  final VoidCallback? onTap;

  @override
  State<AnimatedCard3D> createState() => _AnimatedCard3DState();
}

class _AnimatedCard3DState extends State<AnimatedCard3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _tiltOffset = Offset.zero;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = details.localPosition;
    
    // Calculate tilt based on touch position
    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);
    
    setState(() {
      _tiltOffset = Offset(
        dy.clamp(-1.0, 1.0) * widget.maxTilt,
        -dx.clamp(-1.0, 1.0) * widget.maxTilt,
      );
      _isHovered = true;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltOffset = Offset.zero;
      _isHovered = false;
    });
  }

  void _onHover(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = box.globalToLocal(event.position);
    
    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);
    
    setState(() {
      _tiltOffset = Offset(
        dy.clamp(-1.0, 1.0) * widget.maxTilt,
        -dx.clamp(-1.0, 1.0) * widget.maxTilt,
      );
      _isHovered = true;
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      _tiltOffset = Offset.zero;
      _isHovered = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? AppDimensions.borderRadiusL;
    final shadowColor = widget.shadowColor ?? AppColors.shadowMedium;
    
    return RepaintBoundary(
      child: MouseRegion(
        onHover: _onHover,
        onExit: _onExit,
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: widget.duration,
            curve: widget.curve,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateX(_tiltOffset.dx)
              ..rotateY(_tiltOffset.dy),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: _isHovered ? 0.3 : 0.15),
                  blurRadius: _isHovered ? widget.elevation * 2 : widget.elevation,
                  offset: Offset(
                    _tiltOffset.dy * 20,
                    _tiltOffset.dx * 20 + (_isHovered ? 8 : 4),
                  ),
                  spreadRadius: _isHovered ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: widget.enableGlassmorphism
                  ? _buildGlassmorphicContent()
                  : _buildStandardContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardContent() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.cardBackground,
        borderRadius: widget.borderRadius ?? AppDimensions.borderRadiusL,
      ),
      child: widget.child,
    );
  }

  Widget _buildGlassmorphicContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: 0.25),
            AppColors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: widget.child,
    );
  }
}
