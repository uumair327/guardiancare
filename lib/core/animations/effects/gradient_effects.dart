import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';

/// Animated gradient background
/// 
/// Features:
/// - Smooth color transitions
/// - Multiple gradient types
/// - Performance optimized
class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final Widget? child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const AnimatedGradientBackground({
    super.key,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _colorIndex = (_colorIndex + 1) % (widget.colors.length - 1);
        });
        _controller.forward(from: 0.0);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextIndex = (_colorIndex + 1) % widget.colors.length;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: widget.begin,
                end: widget.end,
                colors: [
                  Color.lerp(
                    widget.colors[_colorIndex],
                    widget.colors[nextIndex],
                    _animation.value,
                  )!,
                  Color.lerp(
                    widget.colors[(_colorIndex + 1) % widget.colors.length],
                    widget.colors[(nextIndex + 1) % widget.colors.length],
                    _animation.value,
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Mesh gradient effect for modern UI
class MeshGradient extends StatelessWidget {
  final List<Color> colors;
  final double intensity;
  final Widget? child;

  const MeshGradient({
    super.key,
    required this.colors,
    this.intensity = 0.5,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MeshGradientPainter(
          colors: colors,
          intensity: intensity,
        ),
        child: child,
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final List<Color> colors;
  final double intensity;

  _MeshGradientPainter({
    required this.colors,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create overlapping radial gradients for mesh effect
    for (int i = 0; i < colors.length; i++) {
      final angle = (i / colors.length) * 2 * math.pi;
      final radius = size.width * 0.6;
      final center = Offset(
        size.width / 2 + math.cos(angle) * size.width * 0.3,
        size.height / 2 + math.sin(angle) * size.height * 0.3,
      );

      paint.shader = RadialGradient(
        colors: [
          colors[i].withValues(alpha: intensity),
          colors[i].withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MeshGradientPainter oldDelegate) {
    return colors != oldDelegate.colors || intensity != oldDelegate.intensity;
  }
}

/// Gradient border effect
class GradientBorder extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final double borderWidth;
  final BorderRadius? borderRadius;

  const GradientBorder({
    super.key,
    required this.child,
    required this.colors,
    this.borderWidth = 2.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
        ),
        child: Container(
          margin: EdgeInsets.all(borderWidth),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(
              radius.topLeft.x - borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Shimmer gradient text effect
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}
