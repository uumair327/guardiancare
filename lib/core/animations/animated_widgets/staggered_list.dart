import 'package:flutter/material.dart';
import 'package:guardiancare/core/animations/animated_widgets/fade_slide_widget.dart';

/// Animation types for staggered list items
/// Follows Single Responsibility - defines animation type only
enum StaggerAnimationType {
  /// Fade in only
  fade,
  /// Slide in only (uses direction parameter)
  slide,
  /// Combined fade and slide (default)
  fadeSlide,
  /// Scale in from smaller size
  scale,
}

/// Staggered animation widget for list of children
/// 
/// Features:
/// - Multiple animation types (fade, slide, fadeSlide, scale)
/// - Configurable item duration and stagger delay
/// - Support for both vertical and horizontal layouts
/// - Performance optimized with RepaintBoundary
/// 
/// Follows Single Responsibility Principle - handles staggered animations only
class StaggeredListWidget extends StatefulWidget {
  /// The children widgets to animate
  final List<Widget> children;
  
  /// Duration for each item's animation
  final Duration itemDuration;
  
  /// Delay between each item's animation start
  final Duration staggerDelay;
  
  /// Animation curve
  final Curve curve;
  
  /// Type of animation to apply
  final StaggerAnimationType animationType;
  
  /// Layout direction (vertical = Column, horizontal = Row)
  final Axis direction;
  
  /// Whether to animate the children
  final bool animate;
  
  /// Slide offset for slide animations
  final double slideOffset;
  
  /// Main axis alignment for the layout
  final MainAxisAlignment mainAxisAlignment;
  
  /// Cross axis alignment for the layout
  final CrossAxisAlignment crossAxisAlignment;
  
  /// Main axis size for the layout
  final MainAxisSize mainAxisSize;

  const StaggeredListWidget({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutCubic,
    this.animationType = StaggerAnimationType.fadeSlide,
    this.direction = Axis.vertical,
    this.animate = true,
    this.slideOffset = 30.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  State<StaggeredListWidget> createState() => _StaggeredListWidgetState();
}

class _StaggeredListWidgetState extends State<StaggeredListWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.animate) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        vsync: this,
        duration: widget.itemDuration,
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: _getSlideBeginOffset(),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: widget.curve));
    }).toList();

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: widget.curve),
      );
    }).toList();
  }

  Offset _getSlideBeginOffset() {
    final offset = widget.slideOffset;
    // Slide direction based on layout direction
    if (widget.direction == Axis.vertical) {
      return Offset(0, offset); // Slide up for vertical
    } else {
      return Offset(offset, 0); // Slide left for horizontal
    }
  }

  Future<void> _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      
      // Calculate delay for this item
      final delay = Duration(
        milliseconds: widget.staggerDelay.inMilliseconds * i,
      );
      
      // Start animation after delay
      Future.delayed(delay, () {
        if (mounted && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(StaggeredListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle children count changes
    if (widget.children.length != oldWidget.children.length) {
      _disposeControllers();
      _initializeAnimations();
      if (widget.animate) {
        _startAnimations();
      }
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Widget _buildAnimatedChild(int index) {
    final child = widget.children[index];
    
    if (!widget.animate) {
      return child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, childWidget) {
          return _applyAnimation(index, childWidget!);
        },
        child: child,
      ),
    );
  }

  Widget _applyAnimation(int index, Widget child) {
    switch (widget.animationType) {
      case StaggerAnimationType.fade:
        return Opacity(
          opacity: _fadeAnimations[index].value,
          child: child,
        );
      
      case StaggerAnimationType.slide:
        return Transform.translate(
          offset: _slideAnimations[index].value,
          child: child,
        );
      
      case StaggerAnimationType.fadeSlide:
        return Opacity(
          opacity: _fadeAnimations[index].value,
          child: Transform.translate(
            offset: _slideAnimations[index].value,
            child: child,
          ),
        );
      
      case StaggerAnimationType.scale:
        return Opacity(
          opacity: _fadeAnimations[index].value,
          child: Transform.scale(
            scale: _scaleAnimations[index].value,
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final animatedChildren = List.generate(
      widget.children.length,
      (index) => _buildAnimatedChild(index),
    );

    if (widget.direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        children: animatedChildren,
      );
    } else {
      return Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        mainAxisSize: widget.mainAxisSize,
        children: animatedChildren,
      );
    }
  }
}

/// Staggered animation list for smooth item entrance
/// 
/// Features:
/// - Automatic stagger delay calculation
/// - Configurable animation direction
/// - Performance optimized with RepaintBoundary
/// - Supports both ListView and GridView
class StaggeredAnimationList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration itemDuration;
  final Duration staggerDelay;
  final SlideDirection direction;
  final double slideOffset;
  final Curve curve;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final ScrollController? controller;

  const StaggeredAnimationList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.direction = SlideDirection.up,
    this.slideOffset = 30.0,
    this.curve = Curves.easeOutCubic,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return FadeSlideWidget(
          duration: itemDuration,
          delay: Duration(milliseconds: staggerDelay.inMilliseconds * index),
          direction: direction,
          slideOffset: slideOffset,
          curve: curve,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Staggered animation grid for smooth grid item entrance
class StaggeredAnimationGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Duration itemDuration;
  final Duration staggerDelay;
  final SlideDirection direction;
  final double slideOffset;
  final Curve curve;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const StaggeredAnimationGrid({
    super.key,
    required this.itemCount,
    required this.crossAxisCount,
    required this.itemBuilder,
    this.itemDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.direction = SlideDirection.up,
    this.slideOffset = 30.0,
    this.curve = Curves.easeOutCubic,
    this.padding,
    this.physics,
    this.shrinkWrap = true,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Calculate stagger based on grid position for wave effect
        final row = index ~/ crossAxisCount;
        final col = index % crossAxisCount;
        final staggerIndex = row + col;
        
        return FadeSlideWidget(
          duration: itemDuration,
          delay: Duration(milliseconds: staggerDelay.inMilliseconds * staggerIndex),
          direction: direction,
          slideOffset: slideOffset,
          curve: curve,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
