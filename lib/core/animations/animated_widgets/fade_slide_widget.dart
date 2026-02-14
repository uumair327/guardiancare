import 'package:flutter/material.dart';

/// Direction for slide animation
enum SlideDirection { up, down, left, right }

/// Animated widget that fades and slides into view
/// 
/// Features:
/// - Configurable direction
/// - Customizable duration and curve
/// - Optional delay for staggered effects
/// - Performance optimized with RepaintBoundary
class FadeSlideWidget extends StatefulWidget {

  const FadeSlideWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.direction = SlideDirection.up,
    this.slideOffset = 30.0,
    this.animate = true,
  });
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final SlideDirection direction;
  final double slideOffset;
  final bool animate;

  @override
  State<FadeSlideWidget> createState() => _FadeSlideWidgetState();
}

class _FadeSlideWidgetState extends State<FadeSlideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.animate) {
      _startAnimation();
    }
  }

  Offset _getBeginOffset() {
    final offset = widget.slideOffset;
    switch (widget.direction) {
      case SlideDirection.up:
        return Offset(0, offset);
      case SlideDirection.down:
        return Offset(0, -offset);
      case SlideDirection.left:
        return Offset(offset, 0);
      case SlideDirection.right:
        return Offset(-offset, 0);
    }
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      await _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: _slideAnimation.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
