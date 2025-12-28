# Design Document: Animation Centralization

## Overview

This design document outlines the architecture for centralizing animation patterns in the GuardianCare Flutter application. The solution enhances the existing `lib/core/animations/` infrastructure while eliminating duplicate animation code across feature widgets. The design follows Clean Architecture principles, placing all reusable animation components in the core layer, and adheres to SOLID principles for maintainability and extensibility.

## Architecture

The animation system follows a layered architecture within the Clean Architecture pattern:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Feature Widgets (quiz, video_player, etc.)             │   │
│  │  - Use centralized animated widgets                      │   │
│  │  - No direct AnimationController management              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CORE LAYER                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  lib/core/animations/                                    │   │
│  │  ├── animated_widgets/     (Reusable animated widgets)  │   │
│  │  │   ├── scale_tap_widget.dart                          │   │
│  │  │   ├── animated_button.dart                           │   │
│  │  │   ├── app_animated_container.dart                    │   │
│  │  │   ├── staggered_list.dart                            │   │
│  │  │   └── ...                                            │   │
│  │  ├── config/               (Animation configurations)   │   │
│  │  │   ├── animation_config.dart                          │   │
│  │  │   └── animation_presets.dart                         │   │
│  │  ├── mixins/               (Animation mixins)           │   │
│  │  │   └── animation_controller_mixin.dart                │   │
│  │  ├── app_curves.dart       (Curve constants)            │   │
│  │  └── animations.dart       (Barrel export)              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### SOLID Principles Application

1. **Single Responsibility Principle (SRP)**: Each animated widget handles one animation pattern (ScaleTapWidget handles scale-tap, FadeSlideWidget handles fade-slide)
2. **Open/Closed Principle (OCP)**: AnimationConfig allows extension through presets without modifying base classes
3. **Liskov Substitution Principle (LSP)**: All animated widgets can be used interchangeably where Widget is expected
4. **Interface Segregation Principle (ISP)**: Mixins provide focused functionality (AnimationControllerMixin, StaggeredAnimationMixin)
5. **Dependency Inversion Principle (DIP)**: Feature widgets depend on abstract animation interfaces, not concrete implementations

## Components and Interfaces

### 1. AnimationConfig Class

Immutable configuration object for animation parameters.

```dart
/// Immutable animation configuration
/// Follows Single Responsibility Principle
@immutable
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  
  const AnimationConfig({
    required this.duration,
    required this.curve,
    required this.begin,
    required this.end,
  });
  
  AnimationConfig copyWith({
    Duration? duration,
    Curve? curve,
    double? begin,
    double? end,
  });
  
  /// Creates a Tween from this config
  Tween<double> toTween();
  
  /// Creates a CurvedAnimation from controller
  Animation<double> createAnimation(AnimationController controller);
}
```

### 2. AnimationPresets Class

Predefined animation configurations for common use cases.

```dart
/// Predefined animation presets
/// Follows Open/Closed Principle - extend via new presets
class AnimationPresets {
  AnimationPresets._();
  
  /// Button scale animation (0.95 scale)
  static const AnimationConfig scaleButton = AnimationConfig(
    duration: AppDurations.animationShort,
    curve: AppCurves.tap,
    begin: 1.0,
    end: 0.95,
  );
  
  /// Large scale animation (0.9 scale)
  static const AnimationConfig scaleLarge = AnimationConfig(
    duration: AppDurations.animationShort,
    curve: AppCurves.tap,
    begin: 1.0,
    end: 0.9,
  );
  
  /// Fade in animation
  static const AnimationConfig fadeIn = AnimationConfig(
    duration: AppDurations.animationMedium,
    curve: AppCurves.standardDecelerate,
    begin: 0.0,
    end: 1.0,
  );
  
  /// Slide up animation (offset-based)
  static const AnimationConfig slideUp = AnimationConfig(
    duration: AppDurations.animationMedium,
    curve: AppCurves.standardDecelerate,
    begin: 30.0,
    end: 0.0,
  );
}
```

### 3. Enhanced ScaleTapWidget

Enhanced version of existing widget with config support.

```dart
/// Interactive widget with scale animation on tap
/// Follows Single Responsibility Principle
class ScaleTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AnimationConfig? config;
  final double? scaleDown;  // Convenience param, overrides config
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final bool enabled;

  const ScaleTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.config,
    this.scaleDown,
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.enabled = true,
  });
}

enum HapticFeedbackType { light, medium, heavy, selection }
```

### 4. AnimatedButton Widget

New centralized button widget combining scale-tap with content.

```dart
/// Animated button with scale-tap and customizable content
/// Replaces VideoControlButton, PlayPauseButton, _ActionButton
class AnimatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final AnimationConfig? config;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final bool enabled;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;

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
  
  /// Factory for icon-only button
  factory AnimatedButton.icon({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    double size = 24,
    AnimationConfig? config,
  });
  
  /// Factory for circular button
  factory AnimatedButton.circular({
    required Widget child,
    required VoidCallback onTap,
    double size = 48,
    Color? backgroundColor,
    AnimationConfig? config,
  });
}
```

### 5. AppAnimatedContainer Widget

Wrapper for AnimatedContainer with app defaults.

```dart
/// AnimatedContainer with app-specific defaults
/// Follows Interface Segregation - focused on container animation
class AppAnimatedContainer extends StatelessWidget {
  final Widget? child;
  final Duration? duration;
  final Curve? curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Matrix4? transform;
  final Clip clipBehavior;

  const AppAnimatedContainer({
    super.key,
    this.child,
    this.duration,  // Defaults to AppDurations.animationShort
    this.curve,     // Defaults to AppCurves.standard
    this.alignment,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.transform,
    this.clipBehavior = Clip.none,
  });
}
```

### 6. Enhanced StaggeredListWidget

Enhanced staggered animation for lists.

```dart
/// Staggered animation for list items
/// Follows Single Responsibility - handles staggered animations only
class StaggeredListWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final Curve curve;
  final StaggerAnimationType animationType;
  final Axis direction;
  final bool animate;

  const StaggeredListWidget({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutCubic,
    this.animationType = StaggerAnimationType.fadeSlide,
    this.direction = Axis.vertical,
    this.animate = true,
  });
}

enum StaggerAnimationType { fade, slide, fadeSlide, scale }
```

### 7. Enhanced AnimationControllerMixin

Enhanced mixin with multi-animation support.

```dart
/// Mixin for managing animation controllers
/// Follows Interface Segregation - focused functionality
mixin AnimationControllerMixin<T extends StatefulWidget> 
    on State<T>, TickerProvider {
  
  AnimationController get animationController;
  Animation<double> get animation;
  
  /// Initialize with AnimationConfig
  void initAnimationFromConfig(AnimationConfig config, {bool autoStart = false});
  
  /// Initialize scale animation
  void initScaleAnimation({
    double scaleDown = 0.95,
    Duration? duration,
    Curve? curve,
  });
  
  /// Initialize fade animation
  void initFadeAnimation({
    Duration? duration,
    Curve? curve,
  });
  
  /// Initialize slide animation
  Animation<Offset> initSlideAnimation({
    Offset begin = const Offset(0, 30),
    Offset end = Offset.zero,
    Duration? duration,
    Curve? curve,
  });
  
  /// Play forward
  Future<void> playForward();
  
  /// Play reverse
  Future<void> playReverse();
  
  /// Reset
  void resetAnimation();
  
  /// Repeat
  void repeatAnimation({bool reverse = true});
}
```

## Data Models

### AnimationConfig

```dart
@immutable
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  
  const AnimationConfig({
    required this.duration,
    required this.curve,
    required this.begin,
    required this.end,
  });
  
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
  
  Tween<double> toTween() => Tween<double>(begin: begin, end: end);
  
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
}
```

### HapticFeedbackType Enum

```dart
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection;
  
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
```

### StaggerAnimationType Enum

```dart
enum StaggerAnimationType {
  fade,
  slide,
  fadeSlide,
  scale,
}
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Based on the prework analysis, the following correctness properties have been identified:

### Property 1: Scale Animation Round-Trip

*For any* ScaleTapWidget with any configured scale value, pressing down then releasing (or canceling) SHALL return the widget's scale to exactly 1.0.

**Validates: Requirements 1.2, 1.3**

This is a round-trip property ensuring that the animation state returns to its original value after a complete press-release cycle.

### Property 2: Disabled Widget Ignores Input

*For any* ScaleTapWidget with `enabled = false`, touch events (tap down, tap up, tap cancel, tap) SHALL NOT trigger any animation state changes or callbacks.

**Validates: Requirements 1.6**

This is an invariant property ensuring disabled state is respected across all touch interactions.

### Property 3: AnimationConfig Immutability

*For any* AnimationConfig instance, calling `copyWith` with modified values SHALL return a new AnimationConfig instance while the original instance remains unchanged with its original values.

**Validates: Requirements 3.3**

This is a round-trip/invariant property ensuring immutability is preserved.

### Property 4: AnimationConfig Application Consistency

*For any* AnimationConfig applied to an animated widget, the resulting animation SHALL use the exact duration, curve, begin value, and end value specified in the config.

**Validates: Requirements 3.4**

This is an invariant property ensuring configuration values are applied without modification.

### Property 5: Animation Controller Disposal

*For any* widget using AnimationControllerMixin, after the widget is disposed, the AnimationController SHALL be disposed (not usable, no memory leak).

**Validates: Requirements 4.3, 8.3**

This is an invariant property ensuring proper resource cleanup.

### Property 6: Staggered Animation Sequential Timing

*For any* StaggeredListWidget with N children and stagger delay D, child at index i SHALL begin its animation at time offset i × D from the start.

**Validates: Requirements 6.4**

This is a metamorphic property where the relationship between child index and animation start time must hold.

## Error Handling

### Animation Controller Errors

1. **Null Controller Access**: If animation controller is accessed before initialization, throw `StateError` with descriptive message
2. **Double Initialization**: If `initAnimation` is called twice, dispose previous controller before creating new one
3. **Post-Dispose Access**: If animation methods are called after disposal, fail silently (widget is unmounted)

### Configuration Errors

1. **Invalid Scale Values**: If scale value is <= 0 or > 1, clamp to valid range [0.01, 1.0] and log warning
2. **Invalid Duration**: If duration is negative, use default `AppDurations.animationShort`
3. **Null Config with Null Fallback**: If both config and individual params are null, use `AnimationPresets.scaleButton`

### Widget Tree Errors

1. **Missing TickerProvider**: If mixin is used without proper TickerProvider, throw clear error message explaining required mixin
2. **Disposed Widget Rebuild**: If widget rebuilds after disposal, return empty SizedBox to prevent crashes

### Error Handling Pattern

```dart
/// Safe animation execution pattern
void _safeAnimationForward() {
  if (!mounted) return;
  try {
    _controller.forward();
  } catch (e) {
    // Controller may be disposed, fail silently
    debugPrint('Animation forward failed: $e');
  }
}
```

## Testing Strategy

### Dual Testing Approach

The animation system requires both unit tests and property-based tests:

1. **Unit Tests**: Verify specific examples, edge cases, and widget configurations
2. **Property-Based Tests**: Verify universal properties across all valid inputs

### Property-Based Testing Framework

**Framework**: `flutter_test` with custom property generators

**Configuration**: Minimum 100 iterations per property test

**Tag Format**: `Feature: animation-centralization, Property {number}: {property_text}`

### Test Categories

#### Unit Tests

1. **Widget Configuration Tests**
   - ScaleTapWidget accepts all configuration parameters
   - AnimatedButton factory constructors create correct widgets
   - AppAnimatedContainer uses correct defaults
   - AnimationPresets contain expected values

2. **Animation Behavior Tests**
   - Tap down triggers forward animation
   - Tap up/cancel triggers reverse animation
   - Disabled state prevents interactions
   - Haptic feedback triggers correctly

3. **Integration Tests**
   - Migrated feature widgets maintain visual behavior
   - Animation system integrates with existing app constants

#### Property-Based Tests

1. **Property 1 Test**: Scale Animation Round-Trip
   ```dart
   // Feature: animation-centralization, Property 1: Scale animation round-trip
   testWidgets('scale returns to 1.0 after press-release cycle', (tester) async {
     // Generate random scale values in valid range
     // For each: press, verify scale changed, release, verify scale is 1.0
   });
   ```

2. **Property 2 Test**: Disabled Widget Ignores Input
   ```dart
   // Feature: animation-centralization, Property 2: Disabled widget ignores input
   testWidgets('disabled widget ignores all touch events', (tester) async {
     // Generate random touch sequences
     // For each: verify no animation state changes when disabled
   });
   ```

3. **Property 3 Test**: AnimationConfig Immutability
   ```dart
   // Feature: animation-centralization, Property 3: AnimationConfig immutability
   test('copyWith returns new instance, original unchanged', () {
     // Generate random configs
     // For each: copyWith, verify original unchanged, new has modified values
   });
   ```

4. **Property 4 Test**: AnimationConfig Application
   ```dart
   // Feature: animation-centralization, Property 4: AnimationConfig application
   testWidgets('config values applied exactly to animation', (tester) async {
     // Generate random configs
     // For each: apply to widget, verify animation uses exact values
   });
   ```

5. **Property 5 Test**: Controller Disposal
   ```dart
   // Feature: animation-centralization, Property 5: Controller disposal
   testWidgets('controller disposed when widget disposed', (tester) async {
     // Create widget, dispose, verify controller is disposed
   });
   ```

6. **Property 6 Test**: Staggered Animation Timing
   ```dart
   // Feature: animation-centralization, Property 6: Staggered animation timing
   testWidgets('children animate with correct stagger delay', (tester) async {
     // Generate random child counts and delays
     // For each: verify child i starts at time i*delay
   });
   ```

### Test Utilities

```dart
/// Animation test utilities
class AnimationTestUtils {
  /// Verify animation completed
  static Future<void> verifyAnimationComplete(
    WidgetTester tester,
    AnimationController controller,
  ) async {
    await tester.pumpAndSettle();
    expect(controller.isCompleted, isTrue);
  }
  
  /// Verify animation at specific value
  static void verifyAnimationValue(
    AnimationController controller,
    double expected, {
    double tolerance = 0.01,
  }) {
    expect(controller.value, closeTo(expected, tolerance));
  }
  
  /// Simulate press-release cycle
  static Future<void> simulatePressRelease(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.press(finder);
    await tester.pump();
    await tester.pumpAndSettle();
  }
}
```

### Test File Structure

```
test/
├── core/
│   └── animations/
│       ├── animation_config_test.dart
│       ├── animation_presets_test.dart
│       ├── scale_tap_widget_test.dart
│       ├── animated_button_test.dart
│       ├── app_animated_container_test.dart
│       ├── staggered_list_test.dart
│       ├── animation_controller_mixin_test.dart
│       └── animation_properties_test.dart  # Property-based tests
```
