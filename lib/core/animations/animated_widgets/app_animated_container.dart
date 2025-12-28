import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../app_curves.dart';

/// AnimatedContainer with app-specific defaults
///
/// Wraps Flutter's [AnimatedContainer] with consistent defaults:
/// - Default duration: [AppDurations.animationShort] (200ms)
/// - Default curve: [AppCurves.standard] (easeInOutCubic)
///
/// Follows Interface Segregation Principle - focused on container animation.
///
/// Example usage:
/// ```dart
/// AppAnimatedContainer(
///   width: isExpanded ? 200 : 100,
///   height: isExpanded ? 200 : 100,
///   decoration: BoxDecoration(
///     color: isSelected ? Colors.blue : Colors.grey,
///     borderRadius: BorderRadius.circular(8),
///   ),
///   child: Text('Content'),
/// )
/// ```
class AppAnimatedContainer extends StatelessWidget {
  /// Creates an animated container with app-specific defaults.
  ///
  /// The [duration] defaults to [AppDurations.animationShort] (200ms).
  /// The [curve] defaults to [AppCurves.standard] (easeInOutCubic).
  const AppAnimatedContainer({
    super.key,
    this.child,
    this.duration,
    this.curve,
    this.alignment,
    this.padding,
    this.margin,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.onEnd,
    this.color,
  });

  /// The child widget to display inside the container.
  final Widget? child;

  /// The duration of the animation.
  ///
  /// Defaults to [AppDurations.animationShort] (200ms).
  final Duration? duration;

  /// The curve to apply to the animation.
  ///
  /// Defaults to [AppCurves.standard] (easeInOutCubic).
  final Curve? curve;

  /// Align the child within the container.
  final AlignmentGeometry? alignment;

  /// Empty space to inscribe inside the container.
  final EdgeInsetsGeometry? padding;

  /// Empty space to surround the container.
  final EdgeInsetsGeometry? margin;

  /// The decoration to paint behind the child.
  final BoxDecoration? decoration;

  /// The decoration to paint in front of the child.
  final BoxDecoration? foregroundDecoration;

  /// The width of the container.
  final double? width;

  /// The height of the container.
  final double? height;

  /// Additional constraints to apply to the child.
  final BoxConstraints? constraints;

  /// The transformation matrix to apply before painting the container.
  final Matrix4? transform;

  /// The alignment of the origin for the transform.
  final AlignmentGeometry? transformAlignment;

  /// The clip behavior when the container has a transform.
  final Clip clipBehavior;

  /// Called when the animation completes.
  final VoidCallback? onEnd;

  /// The color to paint behind the child.
  ///
  /// This is a convenience property. If [decoration] is specified,
  /// this property should be null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration ?? AppDurations.animationShort,
      curve: curve ?? AppCurves.standard,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      onEnd: onEnd,
      color: color,
      child: child,
    );
  }
}
