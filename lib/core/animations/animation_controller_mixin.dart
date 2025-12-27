import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_durations.dart';

/// Mixin for managing animation controllers efficiently
/// Following Single Responsibility Principle
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
mixin AnimationControllerMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  AnimationController get animationController => _animationController;
  Animation<double> get animation => _animation;
  
  /// Initialize animation with custom parameters
  void initAnimation({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutCubic,
    double begin = 0.0,
    double end = 1.0,
    bool autoStart = false,
  }) {
    _animationController = AnimationController(
      vsync: this,
      duration: duration,
    );
    
    _animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _animationController, curve: curve),
    );
    
    if (autoStart) {
      _animationController.forward();
    }
  }
  
  /// Play animation forward
  Future<void> playForward() => _animationController.forward();
  
  /// Play animation in reverse
  Future<void> playReverse() => _animationController.reverse();
  
  /// Reset animation to beginning
  void resetAnimation() => _animationController.reset();
  
  /// Repeat animation
  void repeatAnimation({bool reverse = true}) {
    _animationController.repeat(reverse: reverse);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
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
