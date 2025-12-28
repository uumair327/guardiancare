import 'package:flutter/services.dart';

/// Types of haptic feedback for interactive animations.
///
/// Provides a type-safe way to specify haptic feedback intensity
/// for animated widgets like buttons and interactive elements.
///
/// Example usage:
/// ```dart
/// // Trigger light haptic feedback
/// HapticFeedbackType.light.trigger();
///
/// // Use with animated widgets
/// ScaleTapWidget(
///   hapticType: HapticFeedbackType.medium,
///   child: MyButton(),
/// );
/// ```
enum HapticFeedbackType {
  /// Light haptic feedback - subtle tap sensation.
  /// Ideal for small buttons and minor interactions.
  light,

  /// Medium haptic feedback - moderate tap sensation.
  /// Ideal for standard button presses.
  medium,

  /// Heavy haptic feedback - strong tap sensation.
  /// Ideal for important actions or confirmations.
  heavy,

  /// Selection haptic feedback - selection click sensation.
  /// Ideal for selection changes like toggles or pickers.
  selection;

  /// Triggers the haptic feedback for this type.
  ///
  /// Calls the appropriate [HapticFeedback] method based on the type.
  void trigger() {
    switch (this) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
    }
  }
}
