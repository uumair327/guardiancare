import 'package:flutter/material.dart';

import '../config/animation_config.dart';
import '../config/animation_presets.dart';
import '../config/haptic_feedback_type.dart';

/// Interactive widget with scale animation on tap
///
/// Features:
/// - Smooth scale down on press
/// - Haptic feedback support with configurable intensity
/// - Customizable scale factor via [config] or [scaleDown]
/// - Performance optimized with RepaintBoundary
/// - Supports AnimationConfig for centralized configuration
///
/// Example usage:
/// ```dart
/// // Using AnimationConfig
/// ScaleTapWidget(
///   config: AnimationPresets.scaleButton,
///   onTap: () => print('Tapped!'),
///   child: MyButton(),
/// );
///
/// // Using convenience parameters (backward compatible)
/// ScaleTapWidget(
///   scaleDown: 0.9,
///   onTap: () => print('Tapped!'),
///   child: MyButton(),
/// );
/// ```
class ScaleTapWidget extends StatefulWidget {
  /// The child widget to animate.
  final Widget child;

  /// Callback when the widget is tapped.
  final VoidCallback? onTap;

  /// Callback when the widget is long pressed.
  final VoidCallback? onLongPress;

  /// Animation configuration object.
  ///
  /// When provided, this takes precedence over [scaleDown], [duration],
  /// and [curve] parameters. If null, uses [AnimationPresets.scaleButton]
  /// as default, unless [scaleDown] is explicitly provided.
  final AnimationConfig? config;

  /// Convenience parameter for scale factor.
  ///
  /// When provided, overrides the scale value from [config].
  /// Defaults to null, which uses the config's end value.
  final double? scaleDown;

  /// Animation duration when not using [config].
  ///
  /// Only used when [config] is null and [scaleDown] is provided.
  /// Defaults to 100ms for backward compatibility.
  final Duration? duration;

  /// Animation curve when not using [config].
  ///
  /// Only used when [config] is null and [scaleDown] is provided.
  /// Defaults to [Curves.easeOutQuad] for backward compatibility.
  final Curve? curve;

  /// Whether haptic feedback is enabled.
  final bool enableHaptic;

  /// The type of haptic feedback to trigger.
  ///
  /// Only used when [enableHaptic] is true.
  /// Defaults to [HapticFeedbackType.light].
  final HapticFeedbackType hapticType;

  /// Whether the widget responds to touch interactions.
  final bool enabled;

  const ScaleTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.config,
    this.scaleDown,
    this.duration,
    this.curve,
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.enabled = true,
  });

  @override
  State<ScaleTapWidget> createState() => _ScaleTapWidgetState();
}

class _ScaleTapWidgetState extends State<ScaleTapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  /// Default duration for backward compatibility when using scaleDown (100ms).
  static const _legacyDefaultDuration = Duration(milliseconds: 100);

  /// Default curve for backward compatibility when using scaleDown.
  static const _legacyDefaultCurve = Curves.easeOutQuad;

  /// Gets the effective animation config.
  ///
  /// Priority:
  /// 1. If [scaleDown] is provided, creates config with that scale (backward compatible)
  /// 2. If [config] is provided, uses that config
  /// 3. Otherwise, uses [AnimationPresets.scaleButton] as default
  AnimationConfig get _effectiveConfig {
    if (widget.scaleDown != null) {
      // Backward compatibility: use scaleDown with optional duration/curve
      return AnimationConfig(
        duration: widget.duration ?? _legacyDefaultDuration,
        curve: widget.curve ?? _legacyDefaultCurve,
        begin: 1.0,
        end: widget.scaleDown!,
      );
    }
    return widget.config ?? AnimationPresets.scaleButton;
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    final config = _effectiveConfig;
    _controller = AnimationController(
      vsync: this,
      duration: config.duration,
    );

    _scaleAnimation = config.createAnimation(_controller);
  }

  @override
  void didUpdateWidget(ScaleTapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild animation if config-related properties changed
    final oldConfig = _getConfigFromWidget(oldWidget);
    final newConfig = _effectiveConfig;
    if (oldConfig != newConfig) {
      _controller.dispose();
      _initAnimation();
    }
  }

  AnimationConfig _getConfigFromWidget(ScaleTapWidget widget) {
    if (widget.scaleDown != null) {
      return AnimationConfig(
        duration: widget.duration ?? _legacyDefaultDuration,
        curve: widget.curve ?? _legacyDefaultCurve,
        begin: 1.0,
        end: widget.scaleDown!,
      );
    }
    return widget.config ?? AnimationPresets.scaleButton;
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    _controller.forward();
    if (widget.enableHaptic) {
      widget.hapticType.trigger();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _onTap() {
    if (!widget.enabled) return;
    widget.onTap?.call();
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
        onTap: _onTap,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
