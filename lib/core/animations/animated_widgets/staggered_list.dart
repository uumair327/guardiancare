import 'package:flutter/material.dart';
import 'package:guardiancare/core/animations/animated_widgets/fade_slide_widget.dart';

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
