import 'package:flutter/material.dart';

/// Parallax scroll effect for depth perception
/// 
/// Features:
/// - Smooth parallax scrolling
/// - Configurable parallax factor
/// - Works with any scrollable
/// - Performance optimized
class ParallaxScrollEffect extends StatelessWidget {

  const ParallaxScrollEffect({
    super.key,
    required this.child,
    required this.backgroundKey,
    this.parallaxFactor = 0.5,
  });
  final Widget child;
  final double parallaxFactor;
  final GlobalKey backgroundKey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Flow(
        delegate: _ParallaxFlowDelegate(
          scrollable: Scrollable.of(context),
          listItemContext: context,
          backgroundImageKey: backgroundKey,
          parallaxFactor: parallaxFactor,
        ),
        children: [child],
      ),
    );
  }
}

class _ParallaxFlowDelegate extends FlowDelegate {

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
    required this.parallaxFactor,
  }) : super(repaint: scrollable.position);
  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;
  final double parallaxFactor;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(width: constraints.maxWidth);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final verticalAlignment = Alignment(0, scrollFraction * 2 - 1);

    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject() as RenderBox).size;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

    context.paintChild(
      0,
      transform: Transform.translate(
        offset: Offset(0, childRect.top * parallaxFactor),
      ).transform,
    );
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey ||
        parallaxFactor != oldDelegate.parallaxFactor;
  }
}

/// Simple parallax container for header images
class ParallaxHeader extends StatelessWidget {

  const ParallaxHeader({
    super.key,
    required this.child,
    this.height = 300,
    this.parallaxFactor = 0.5,
    this.scrollController,
  });
  final Widget child;
  final double height;
  final double parallaxFactor;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return OverflowBox(
              maxHeight: height * (1 + parallaxFactor),
              alignment: Alignment.topCenter,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

/// Parallax layer for multi-layer depth effects
class ParallaxLayer extends StatefulWidget {

  const ParallaxLayer({
    super.key,
    required this.child,
    this.depth = 0.5,
    this.baseOffset = Offset.zero,
  });
  final Widget child;
  final double depth; // 0.0 = foreground, 1.0 = background
  final Offset baseOffset;

  @override
  State<ParallaxLayer> createState() => _ParallaxLayerState();
}

class _ParallaxLayerState extends State<ParallaxLayer> {
  Offset _offset = Offset.zero;

  void updateOffset(Offset pointerPosition, Size screenSize) {
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    final dx = (pointerPosition.dx - centerX) / centerX;
    final dy = (pointerPosition.dy - centerY) / centerY;
    
    setState(() {
      _offset = Offset(
        dx * 20 * widget.depth,
        dy * 20 * widget.depth,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform.translate(
        offset: widget.baseOffset + _offset,
        child: widget.child,
      ),
    );
  }
}
