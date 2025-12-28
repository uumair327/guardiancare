import 'package:flutter/material.dart';
import 'package:guardiancare/core/animations/app_curves.dart';
import 'package:guardiancare/core/animations/config/animation_config.dart';
import 'package:guardiancare/core/constants/app_durations.dart';

/// Mixin for managing animation controllers efficiently
/// Following Single Responsibility Principle
///
/// Provides standardized animation controller lifecycle management with
/// support for multiple animation types (scale, fade, slide, rotation).
///
/// Usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget>
///     with SingleTickerProviderStateMixin, AnimationControllerMixin {
///   @override
///   void initState() {
///     super.initState();
///     initAnimation(duration: AppDurations.animationMedium);
///   }
/// }
/// ```
mixin AnimationControllerMixin<T extends StatefulWidget>
    on State<T>, TickerProvider {
  AnimationController? _animationController;
  Animation<double>? _animation;
  Animation<Offset>? _slideAnimation;

  /// Whether the animation controller has been initialized.
  bool _isInitialized = false;

  /// Returns the animation controller.
  /// Throws [StateError] if accessed before initialization.
  AnimationController get animationController {
    if (_animationController == null) {
      throw StateError(
        'AnimationController accessed before initialization. '
        'Call initAnimation, initAnimationFromConfig, or one of the '
        'specialized init methods first.',
      );
    }
    return _animationController!;
  }

  /// Returns the main animation.
  /// Throws [StateError] if accessed before initialization.
  Animation<double> get animation {
    if (_animation == null) {
      throw StateError(
        'Animation accessed before initialization. '
        'Call initAnimation, initAnimationFromConfig, or one of the '
        'specialized init methods first.',
      );
    }
    return _animation!;
  }

  /// Returns the slide animation if initialized via [initSlideAnimation].
  /// Returns null if slide animation was not initialized.
  Animation<Offset>? get slideAnimation => _slideAnimation;

  /// Whether the animation controller has been initialized.
  bool get isAnimationInitialized => _isInitialized;

  /// Initialize animation with custom parameters.
  ///
  /// This is the basic initialization method. For more control,
  /// use [initAnimationFromConfig] or the specialized init methods.
  void initAnimation({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    double begin = 0.0,
    double end = 1.0,
    bool autoStart = false,
  }) {
    _disposeExistingController();

    _animationController = AnimationController(
      vsync: this,
      duration: duration,
    );

    _animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _animationController!, curve: curve),
    );

    _isInitialized = true;

    if (autoStart) {
      _animationController!.forward();
    }
  }

  /// Initialize animation from an [AnimationConfig] object.
  ///
  /// This method provides a clean way to initialize animations using
  /// predefined configurations from [AnimationPresets] or custom configs.
  ///
  /// Example:
  /// ```dart
  /// initAnimationFromConfig(AnimationPresets.scaleButton);
  /// // or with custom config
  /// initAnimationFromConfig(
  ///   AnimationPresets.fadeIn.copyWith(duration: Duration(milliseconds: 500)),
  /// );
  /// ```
  void initAnimationFromConfig(AnimationConfig config, {bool autoStart = false}) {
    _disposeExistingController();

    _animationController = AnimationController(
      vsync: this,
      duration: config.duration,
    );

    _animation = config.createAnimation(_animationController!);

    _isInitialized = true;

    if (autoStart) {
      _animationController!.forward();
    }
  }

  /// Initialize a scale animation with common defaults.
  ///
  /// Creates an animation suitable for scale-tap effects on buttons
  /// and interactive elements.
  ///
  /// Parameters:
  /// - [scaleDown]: The scale value when pressed (default: 0.95)
  /// - [duration]: Animation duration (default: AppDurations.animationShort)
  /// - [curve]: Animation curve (default: AppCurves.tap)
  /// - [autoStart]: Whether to start the animation immediately
  ///
  /// Example:
  /// ```dart
  /// initScaleAnimation(scaleDown: 0.9);
  /// ```
  void initScaleAnimation({
    double scaleDown = 0.95,
    Duration? duration,
    Curve? curve,
    bool autoStart = false,
  }) {
    // Clamp scale value to valid range
    final clampedScale = scaleDown.clamp(0.01, 1.0);
    if (clampedScale != scaleDown) {
      debugPrint(
        'AnimationControllerMixin: scaleDown value $scaleDown clamped to $clampedScale',
      );
    }

    _disposeExistingController();

    _animationController = AnimationController(
      vsync: this,
      duration: duration ?? AppDurations.animationShort,
    );

    _animation = Tween<double>(begin: 1.0, end: clampedScale).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: curve ?? AppCurves.tap,
      ),
    );

    _isInitialized = true;

    if (autoStart) {
      _animationController!.forward();
    }
  }

  /// Initialize a fade animation with common defaults.
  ///
  /// Creates an animation suitable for fade-in/fade-out effects.
  ///
  /// Parameters:
  /// - [fadeIn]: If true, animates from 0 to 1; if false, from 1 to 0
  /// - [duration]: Animation duration (default: AppDurations.animationMedium)
  /// - [curve]: Animation curve (default: AppCurves.standardDecelerate)
  /// - [autoStart]: Whether to start the animation immediately
  ///
  /// Example:
  /// ```dart
  /// initFadeAnimation(fadeIn: true, autoStart: true);
  /// ```
  void initFadeAnimation({
    bool fadeIn = true,
    Duration? duration,
    Curve? curve,
    bool autoStart = false,
  }) {
    _disposeExistingController();

    _animationController = AnimationController(
      vsync: this,
      duration: duration ?? AppDurations.animationMedium,
    );

    _animation = Tween<double>(
      begin: fadeIn ? 0.0 : 1.0,
      end: fadeIn ? 1.0 : 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: curve ?? AppCurves.standardDecelerate,
      ),
    );

    _isInitialized = true;

    if (autoStart) {
      _animationController!.forward();
    }
  }

  /// Initialize a slide animation with common defaults.
  ///
  /// Creates an [Animation<Offset>] suitable for slide-in/slide-out effects.
  /// The slide animation is accessible via [slideAnimation] getter.
  ///
  /// Parameters:
  /// - [begin]: Starting offset (default: Offset(0, 30) - slides up from below)
  /// - [end]: Ending offset (default: Offset.zero)
  /// - [duration]: Animation duration (default: AppDurations.animationMedium)
  /// - [curve]: Animation curve (default: AppCurves.standardDecelerate)
  /// - [autoStart]: Whether to start the animation immediately
  ///
  /// Returns the created [Animation<Offset>] for convenience.
  ///
  /// Example:
  /// ```dart
  /// final slideAnim = initSlideAnimation(
  ///   begin: Offset(0, 50),
  ///   autoStart: true,
  /// );
  /// // Use with SlideTransition
  /// SlideTransition(position: slideAnim, child: MyWidget());
  /// ```
  Animation<Offset> initSlideAnimation({
    Offset begin = const Offset(0, 30),
    Offset end = Offset.zero,
    Duration? duration,
    Curve? curve,
    bool autoStart = false,
  }) {
    _disposeExistingController();

    _animationController = AnimationController(
      vsync: this,
      duration: duration ?? AppDurations.animationMedium,
    );

    // Also create a double animation for compatibility
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: curve ?? AppCurves.standardDecelerate,
      ),
    );

    // Create the slide animation
    _slideAnimation = Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: curve ?? AppCurves.standardDecelerate,
      ),
    );

    _isInitialized = true;

    if (autoStart) {
      _animationController!.forward();
    }

    return _slideAnimation!;
  }

  /// Disposes the existing controller if one exists.
  /// Called before creating a new controller to prevent memory leaks.
  void _disposeExistingController() {
    if (_animationController != null) {
      _animationController!.dispose();
      _animationController = null;
      _animation = null;
      _slideAnimation = null;
      _isInitialized = false;
    }
  }

  /// Play animation forward.
  ///
  /// Returns a [Future] that completes when the animation finishes.
  /// Fails silently if the widget is not mounted or controller is disposed.
  Future<void> playForward() async {
    if (!mounted || _animationController == null) return;
    try {
      await _animationController!.forward();
    } catch (e) {
      // Controller may be disposed, fail silently
      debugPrint('AnimationControllerMixin: playForward failed: $e');
    }
  }

  /// Play animation in reverse.
  ///
  /// Returns a [Future] that completes when the animation finishes.
  /// Fails silently if the widget is not mounted or controller is disposed.
  Future<void> playReverse() async {
    if (!mounted || _animationController == null) return;
    try {
      await _animationController!.reverse();
    } catch (e) {
      // Controller may be disposed, fail silently
      debugPrint('AnimationControllerMixin: playReverse failed: $e');
    }
  }

  /// Reset animation to beginning.
  ///
  /// Fails silently if the controller is not initialized.
  void resetAnimation() {
    if (_animationController == null) return;
    try {
      _animationController!.reset();
    } catch (e) {
      debugPrint('AnimationControllerMixin: resetAnimation failed: $e');
    }
  }

  /// Repeat animation.
  ///
  /// Parameters:
  /// - [reverse]: If true, animation reverses direction each cycle
  ///
  /// Fails silently if the controller is not initialized.
  void repeatAnimation({bool reverse = true}) {
    if (_animationController == null) return;
    try {
      _animationController!.repeat(reverse: reverse);
    } catch (e) {
      debugPrint('AnimationControllerMixin: repeatAnimation failed: $e');
    }
  }

  /// Stop the animation at its current position.
  ///
  /// Fails silently if the controller is not initialized.
  void stopAnimation() {
    if (_animationController == null) return;
    try {
      _animationController!.stop();
    } catch (e) {
      debugPrint('AnimationControllerMixin: stopAnimation failed: $e');
    }
  }

  /// Animate to a specific value.
  ///
  /// Parameters:
  /// - [target]: The target value (0.0 to 1.0)
  /// - [duration]: Optional duration override
  /// - [curve]: Optional curve override
  ///
  /// Returns a [Future] that completes when the animation finishes.
  Future<void> animateTo(
    double target, {
    Duration? duration,
    Curve? curve,
  }) async {
    if (!mounted || _animationController == null) return;
    try {
      await _animationController!.animateTo(
        target,
        duration: duration,
        curve: curve ?? Curves.linear,
      );
    } catch (e) {
      debugPrint('AnimationControllerMixin: animateTo failed: $e');
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _animationController = null;
    _animation = null;
    _slideAnimation = null;
    _isInitialized = false;
    super.dispose();
  }
}

/// Mixin for staggered animations
/// Useful for list items and grid animations
mixin StaggeredAnimationMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  final List<AnimationController> _staggeredControllers = [];
  final List<Animation<double>> _staggeredAnimations = [];
  
  List<Animation<double>> get staggeredAnimations => _staggeredAnimations;
  
  /// Initialize staggered animations for a list of items
  void initStaggeredAnimations({
    required int itemCount,
    Duration itemDuration = const Duration(milliseconds: 200),
    Duration staggerDelay = const Duration(milliseconds: 50),
    Curve curve = Curves.easeOutCubic,
  }) {
    for (int i = 0; i < itemCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: itemDuration,
      );
      
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: curve),
      );
      
      _staggeredControllers.add(controller);
      _staggeredAnimations.add(animation);
    }
  }
  
  /// Play all staggered animations with delay
  Future<void> playStaggeredAnimations({
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) async {
    for (int i = 0; i < _staggeredControllers.length; i++) {
      await Future.delayed(staggerDelay);
      if (mounted) {
        _staggeredControllers[i].forward();
      }
    }
  }
  
  @override
  void dispose() {
    for (final controller in _staggeredControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
