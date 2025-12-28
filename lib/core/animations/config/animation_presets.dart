import 'package:guardiancare/core/animations/app_curves.dart';
import 'package:guardiancare/core/constants/app_durations.dart';

import 'animation_config.dart';

/// Predefined animation configurations for common use cases.
///
/// Follows the Open/Closed Principle - extend via new presets without
/// modifying existing ones.
///
/// Example usage:
/// ```dart
/// // Use a preset directly
/// ScaleTapWidget(
///   config: AnimationPresets.scaleButton,
///   child: MyButton(),
/// );
///
/// // Customize a preset
/// final customConfig = AnimationPresets.scaleButton.copyWith(
///   duration: Duration(milliseconds: 300),
/// );
/// ```
class AnimationPresets {
  AnimationPresets._();

  /// Button scale animation preset.
  ///
  /// Scales down to 0.95 with short duration and tap curve.
  /// Ideal for button press feedback.
  static const AnimationConfig scaleButton = AnimationConfig(
    duration: AppDurations.animationShort,
    curve: AppCurves.tap,
    begin: 1.0,
    end: 0.95,
  );

  /// Large scale animation preset.
  ///
  /// Scales down to 0.9 with short duration and tap curve.
  /// Ideal for larger interactive elements like cards.
  static const AnimationConfig scaleLarge = AnimationConfig(
    duration: AppDurations.animationShort,
    curve: AppCurves.tap,
    begin: 1.0,
    end: 0.9,
  );

  /// Fade in animation preset.
  ///
  /// Fades from 0 to 1 opacity with medium duration and decelerate curve.
  /// Ideal for elements entering the screen.
  static const AnimationConfig fadeIn = AnimationConfig(
    duration: AppDurations.animationMedium,
    curve: AppCurves.standardDecelerate,
    begin: 0.0,
    end: 1.0,
  );

  /// Slide up animation preset.
  ///
  /// Slides from 30 offset to 0 with medium duration and decelerate curve.
  /// Ideal for elements sliding into view from below.
  static const AnimationConfig slideUp = AnimationConfig(
    duration: AppDurations.animationMedium,
    curve: AppCurves.standardDecelerate,
    begin: 30.0,
    end: 0.0,
  );
}
