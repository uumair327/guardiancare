import 'package:flutter/material.dart';

/// Immutable animation configuration object.
///
/// Provides a standardized way to define animation parameters that can be
/// reused across the application. Follows the Single Responsibility Principle
/// by encapsulating animation configuration only.
///
/// Example usage:
/// ```dart
/// const config = AnimationConfig(
///   duration: Duration(milliseconds: 200),
///   curve: Curves.easeOutQuad,
///   begin: 1.0,
///   end: 0.95,
/// );
///
/// // Create animation from config
/// final animation = config.createAnimation(controller);
/// ```
@immutable
class AnimationConfig {

  /// Creates an immutable animation configuration.
  const AnimationConfig({
    required this.duration,
    required this.curve,
    required this.begin,
    required this.end,
  });
  /// The duration of the animation.
  final Duration duration;

  /// The curve applied to the animation.
  final Curve curve;

  /// The starting value of the animation.
  final double begin;

  /// The ending value of the animation.
  final double end;

  /// Creates a copy of this config with the given fields replaced.
  ///
  /// Returns a new [AnimationConfig] instance with the specified values
  /// overridden. The original instance remains unchanged.
  AnimationConfig copyWith({
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  }) {
    return AnimationConfig(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      begin: begin ?? this.begin,
      end: end ?? this.end,
    );
  }

  /// Creates a [Tween] from this configuration's begin and end values.
  Tween<double> toTween() => Tween<double>(begin: begin, end: end);

  /// Creates a curved [Animation] from the given [AnimationController].
  ///
  /// The animation will use this config's curve and tween values.
  Animation<double> createAnimation(AnimationController controller) {
    return toTween().animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimationConfig &&
        other.duration == duration &&
        other.curve == curve &&
        other.begin == begin &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(duration, curve, begin, end);

  @override
  String toString() {
    return 'AnimationConfig(duration: $duration, curve: $curve, begin: $begin, end: $end)';
  }
}
