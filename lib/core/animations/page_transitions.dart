import 'package:flutter/material.dart';
import 'package:guardiancare/core/animations/app_curves.dart';
import 'package:guardiancare/core/constants/app_durations.dart';

/// Custom page transitions for modern navigation
/// 
/// Features:
/// - Fade + slide transitions
/// - Scale transitions
/// - Shared element support
/// - Performance optimized
class AppPageTransitions {
  AppPageTransitions._();

  /// Fade and slide up transition
  static PageRouteBuilder<T> fadeSlideUp<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
        );
        
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppCurves.pageEnter));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale and fade transition
  static PageRouteBuilder<T> scaleFade<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
        );
        
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Slide from right transition
  static PageRouteBuilder<T> slideRight<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppCurves.pageEnter));

        final fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 3D flip transition
  static PageRouteBuilder<T> flip3D<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotateAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
          CurvedAnimation(parent: animation, curve: AppCurves.rotate3D),
        );

        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotateAnimation.value * 3.14159),
              child: Opacity(
                opacity: fadeAnimation.value,
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  /// Shared axis transition (Material Design 3)
  static PageRouteBuilder<T> sharedAxis<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

        final Offset beginOffset;
        switch (direction) {
          case SharedAxisDirection.horizontal:
            beginOffset = const Offset(30, 0);
            break;
          case SharedAxisDirection.vertical:
            beginOffset = const Offset(0, 30);
            break;
          case SharedAxisDirection.scaled:
            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: AppCurves.pageEnter),
                ),
                child: child,
              ),
            );
        }

        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppCurves.pageEnter));

        return FadeTransition(
          opacity: fadeAnimation,
          child: Transform.translate(
            offset: slideAnimation.value,
            child: child,
          ),
        );
      },
    );
  }
}

enum SharedAxisDirection { horizontal, vertical, scaled }

/// Custom page route with hero animation support
class HeroPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final String? heroTag;

  HeroPageRoute({
    required this.page,
    this.heroTag,
    super.settings,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => AppDurations.animationMedium;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
