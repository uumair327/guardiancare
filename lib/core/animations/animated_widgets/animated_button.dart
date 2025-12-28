import 'package:flutter/material.dart';

import '../config/animation_config.dart';
import '../config/haptic_feedback_type.dart';
import 'scale_tap_widget.dart';

/// Animated button widget with scale-tap animation and customizable content.
///
/// This widget combines [ScaleTapWidget] internally with additional styling
/// options like padding and decoration. It serves as a centralized replacement
/// for duplicated button animation code across the application.
///
/// Follows Single Responsibility Principle - handles animated button behavior only.
///
/// Example usage:
/// ```dart
/// // Basic usage
/// AnimatedButton(
///   onTap: () => print('Tapped!'),
///   child: Text('Click me'),
/// );
///
/// // With custom config
/// AnimatedButton(
///   config: AnimationPresets.scaleLarge,
///   onTap: () => print('Tapped!'),
///   padding: EdgeInsets.all(16),
///   decoration: BoxDecoration(
///     color: Colors.blue,
///     borderRadius: BorderRadius.circular(8),
///   ),
///   child: Text('Custom Button'),
/// );
/// ```
class AnimatedButton extends StatelessWidget {
  /// The child widget to display inside the button.
  final Widget child;

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  /// Callback when the button is long pressed.
  final VoidCallback? onLongPress;

  /// Animation configuration for the scale-tap effect.
  ///
  /// If null, uses [AnimationPresets.scaleButton] as default.
  final AnimationConfig? config;

  /// Whether haptic feedback is enabled.
  final bool enableHaptic;

  /// The type of haptic feedback to trigger.
  final HapticFeedbackType hapticType;

  /// Whether the button responds to touch interactions.
  final bool enabled;

  /// Padding inside the button.
  final EdgeInsetsGeometry? padding;

  /// Decoration for the button container.
  final BoxDecoration? decoration;

  /// Creates an animated button with scale-tap animation.
  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.config,
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.enabled = true,
    this.padding,
    this.decoration,
  });

  /// Creates an icon-only animated button.
  ///
  /// Example:
  /// ```dart
  /// AnimatedButton.icon(
  ///   icon: Icons.play_arrow,
  ///   onTap: () => print('Play tapped'),
  ///   color: Colors.white,
  ///   size: 32,
  /// );
  /// ```
  factory AnimatedButton.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onTap,
    Color? color,
    double size = 24,
    AnimationConfig? config,
    bool enableHaptic = true,
    HapticFeedbackType hapticType = HapticFeedbackType.light,
    bool enabled = true,
    EdgeInsetsGeometry? padding,
    BoxDecoration? decoration,
  }) {
    return AnimatedButton(
      key: key,
      onTap: onTap,
      config: config,
      enableHaptic: enableHaptic,
      hapticType: hapticType,
      enabled: enabled,
      padding: padding,
      decoration: decoration,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  /// Creates a circular animated button.
  ///
  /// Example:
  /// ```dart
  /// AnimatedButton.circular(
  ///   size: 56,
  ///   backgroundColor: Colors.blue,
  ///   onTap: () => print('Circular button tapped'),
  ///   child: Icon(Icons.add, color: Colors.white),
  /// );
  /// ```
  factory AnimatedButton.circular({
    Key? key,
    required Widget child,
    required VoidCallback? onTap,
    double size = 48,
    Color? backgroundColor,
    AnimationConfig? config,
    bool enableHaptic = true,
    HapticFeedbackType hapticType = HapticFeedbackType.light,
    bool enabled = true,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    return AnimatedButton(
      key: key,
      onTap: onTap,
      config: config,
      enableHaptic: enableHaptic,
      hapticType: hapticType,
      enabled: enabled,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply padding if provided
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    }

    // Apply decoration if provided
    if (decoration != null) {
      content = DecoratedBox(
        decoration: decoration!,
        child: content,
      );
    }

    return ScaleTapWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      config: config,
      enableHaptic: enableHaptic,
      hapticType: hapticType,
      enabled: enabled,
      child: content,
    );
  }
}
