import 'package:flutter/material.dart';

/// Professional Animation Curves
/// Based on Material Design 3 Motion Guidelines
/// 
/// Curve Categories:
/// - Standard: General purpose animations
/// - Emphasized: Important UI transitions
/// - Decelerated: Elements entering the screen
/// - Accelerated: Elements leaving the screen
class AppCurves {
  AppCurves._();

  // ==================== Standard Curves ====================
  /// Standard easing - balanced acceleration/deceleration
  static const Curve standard = Curves.easeInOutCubic;
  
  /// Standard accelerate - starts slow, ends fast
  static const Curve standardAccelerate = Curves.easeInCubic;
  
  /// Standard decelerate - starts fast, ends slow
  static const Curve standardDecelerate = Curves.easeOutCubic;

  // ==================== Emphasized Curves ====================
  /// Emphasized - for important transitions
  static const Curve emphasized = Curves.easeInOutQuart;
  
  /// Emphasized accelerate - dramatic exit
  static const Curve emphasizedAccelerate = Curves.easeInQuart;
  
  /// Emphasized decelerate - dramatic entrance
  static const Curve emphasizedDecelerate = Curves.easeOutQuart;

  // ==================== Bounce & Spring ====================
  /// Bounce effect - playful interactions
  static const Curve bounce = Curves.bounceOut;
  
  /// Elastic effect - spring-like motion
  static const Curve elastic = Curves.elasticOut;
  
  /// Spring curve - natural physics-based motion
  static const Curve spring = Curves.easeOutBack;
  
  /// Overshoot - goes past target then settles
  static const Curve overshoot = Curves.easeOutBack;

  // ==================== 3D Transform Curves ====================
  /// Smooth 3D rotation curve
  static const Curve rotate3D = Curves.easeInOutSine;
  
  /// Perspective shift curve
  static const Curve perspective = Curves.easeOutQuint;
  
  /// Depth transition curve
  static const Curve depth = Curves.easeInOutExpo;

  // ==================== Micro-interaction Curves ====================
  /// Quick tap feedback
  static const Curve tap = Curves.easeOutQuad;
  
  /// Button press effect
  static const Curve press = Curves.easeInOutQuad;
  
  /// Hover effect
  static const Curve hover = Curves.easeOutCubic;
  
  /// Scale animation
  static const Curve scale = Curves.easeOutBack;

  // ==================== Page Transition Curves ====================
  /// Page enter curve
  static const Curve pageEnter = Curves.easeOutCubic;
  
  /// Page exit curve
  static const Curve pageExit = Curves.easeInCubic;
  
  /// Shared element transition
  static const Curve sharedElement = Curves.easeInOutCubicEmphasized;
}
