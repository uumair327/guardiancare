import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Animation test utilities for the GuardianCare animation system.
///
/// Provides helper methods for testing animated widgets, verifying animation
/// states, and simulating user interactions in widget tests.
///
/// These utilities support the animation testing requirements:
/// - Requirement 9.1: Expose animation state for testing purposes
/// - Requirement 9.2: Support widget testing with WidgetTester.pump and pumpAndSettle
/// - Requirement 9.3: Allow verification of animation completion
/// - Requirement 9.4: Provide test utilities for common animation assertions
///
/// Example usage:
/// ```dart
/// testWidgets('animation completes correctly', (tester) async {
///   // ... setup widget with animation controller
///   await AnimationTestUtils.verifyAnimationComplete(tester, controller);
/// });
/// ```
class AnimationTestUtils {
  AnimationTestUtils._();

  /// Default tolerance for animation value comparisons.
  static const double defaultTolerance = 0.01;

  /// Verifies that an animation has completed (reached its end state).
  ///
  /// This method pumps the widget tree until all animations settle,
  /// then verifies that the [controller] has completed.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [controller]: The AnimationController to verify
  ///
  /// Throws:
  /// - [TestFailure] if the animation has not completed after settling
  ///
  /// Example:
  /// ```dart
  /// await AnimationTestUtils.verifyAnimationComplete(tester, controller);
  /// ```
  static Future<void> verifyAnimationComplete(
    WidgetTester tester,
    AnimationController controller,
  ) async {
    await tester.pumpAndSettle();
    expect(
      controller.isCompleted,
      isTrue,
      reason: 'Animation should be completed after pumpAndSettle. '
          'Current value: ${controller.value}, status: ${controller.status}',
    );
  }

  /// Verifies that an animation is at a specific value within tolerance.
  ///
  /// Parameters:
  /// - [controller]: The AnimationController to verify
  /// - [expected]: The expected animation value (0.0 to 1.0)
  /// - [tolerance]: The acceptable deviation from expected (default: 0.01)
  ///
  /// Throws:
  /// - [TestFailure] if the animation value is not within tolerance
  ///
  /// Example:
  /// ```dart
  /// AnimationTestUtils.verifyAnimationValue(controller, 0.5);
  /// AnimationTestUtils.verifyAnimationValue(controller, 1.0, tolerance: 0.001);
  /// ```
  static void verifyAnimationValue(
    AnimationController controller,
    double expected, {
    double tolerance = defaultTolerance,
  }) {
    expect(
      controller.value,
      closeTo(expected, tolerance),
      reason: 'Animation value should be $expected (±$tolerance). '
          'Actual: ${controller.value}',
    );
  }

  /// Verifies that an `Animation<double>` is at a specific value within tolerance.
  ///
  /// This is useful when testing animations that are derived from a controller
  /// (e.g., with Tween or CurvedAnimation).
  ///
  /// Parameters:
  /// - [animation]: The `Animation<double>` to verify
  /// - [expected]: The expected animation value
  /// - [tolerance]: The acceptable deviation from expected (default: 0.01)
  ///
  /// Example:
  /// ```dart
  /// final scaleAnimation = Tween(begin: 1.0, end: 0.9).animate(controller);
  /// AnimationTestUtils.verifyAnimatedValue(scaleAnimation, 0.95);
  /// ```
  static void verifyAnimatedValue(
    Animation<double> animation,
    double expected, {
    double tolerance = defaultTolerance,
  }) {
    expect(
      animation.value,
      closeTo(expected, tolerance),
      reason: 'Animated value should be $expected (±$tolerance). '
          'Actual: ${animation.value}',
    );
  }

  /// Simulates a complete press-release cycle on a widget.
  ///
  /// This method:
  /// 1. Starts a gesture (press down) at the center of the widget
  /// 2. Pumps the widget tree to allow animations to progress
  /// 3. Releases the gesture (press up)
  /// 4. Pumps until all animations settle
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [finder]: A Finder that locates the widget to interact with
  ///
  /// Returns:
  /// - A [Future] that completes when the press-release cycle is done
  ///
  /// Example:
  /// ```dart
  /// await AnimationTestUtils.simulatePressRelease(
  ///   tester,
  ///   find.byKey(Key('my_button')),
  /// );
  /// ```
  static Future<void> simulatePressRelease(
    WidgetTester tester,
    Finder finder,
  ) async {
    expect(finder, findsOneWidget, reason: 'Widget to press must exist');

    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump();
    await tester.pumpAndSettle();

    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Simulates a press down gesture on a widget without releasing.
  ///
  /// Useful for testing intermediate animation states during a press.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [finder]: A Finder that locates the widget to interact with
  ///
  /// Returns:
  /// - A [TestGesture] that can be used to release or cancel the gesture
  ///
  /// Example:
  /// ```dart
  /// final gesture = await AnimationTestUtils.simulatePressDown(tester, finder);
  /// // Verify intermediate state
  /// await gesture.up(); // Release when done
  /// ```
  static Future<TestGesture> simulatePressDown(
    WidgetTester tester,
    Finder finder,
  ) async {
    expect(finder, findsOneWidget, reason: 'Widget to press must exist');

    final gesture = await tester.startGesture(tester.getCenter(finder));
    await tester.pump();
    await tester.pumpAndSettle();

    return gesture;
  }

  /// Extracts the scale value from a Transform widget.
  ///
  /// This is useful for testing ScaleTapWidget and other scale-based animations.
  /// Finds the Transform widget that is a descendant of the widget found by [parentFinder].
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [parentFinder]: A Finder that locates the parent widget containing the Transform
  ///
  /// Returns:
  /// - The current scale value from the Transform's matrix
  ///
  /// Throws:
  /// - [TestFailure] if no Transform widget is found
  ///
  /// Example:
  /// ```dart
  /// final scale = AnimationTestUtils.getScaleFromTransform(
  ///   tester,
  ///   find.byKey(Key('scale_tap_widget')),
  /// );
  /// expect(scale, closeTo(0.95, 0.01));
  /// ```
  static double getScaleFromTransform(
    WidgetTester tester,
    Finder parentFinder,
  ) {
    expect(parentFinder, findsOneWidget, reason: 'Parent widget must exist');

    final transformFinder = find.descendant(
      of: parentFinder,
      matching: find.byType(Transform),
    );
    expect(
      transformFinder,
      findsOneWidget,
      reason: 'Transform widget must exist as descendant',
    );

    final transform = tester.widget<Transform>(transformFinder);
    final matrix = transform.transform;
    // Scale is stored in the diagonal elements [0,0] and [1,1]
    // For uniform scale, [0,0] equals [1,1]
    return matrix.storage[0];
  }

  /// Verifies that a widget's scale matches the expected value.
  ///
  /// Combines [getScaleFromTransform] with an expectation check.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [parentFinder]: A Finder that locates the parent widget containing the Transform
  /// - [expected]: The expected scale value
  /// - [tolerance]: The acceptable deviation from expected (default: 0.01)
  ///
  /// Example:
  /// ```dart
  /// AnimationTestUtils.verifyScale(
  ///   tester,
  ///   find.byKey(Key('scale_tap_widget')),
  ///   0.95,
  /// );
  /// ```
  static void verifyScale(
    WidgetTester tester,
    Finder parentFinder,
    double expected, {
    double tolerance = defaultTolerance,
  }) {
    final scale = getScaleFromTransform(tester, parentFinder);
    expect(
      scale,
      closeTo(expected, tolerance),
      reason: 'Scale should be $expected (±$tolerance). Actual: $scale',
    );
  }

  /// Extracts the opacity value from an Opacity or FadeTransition widget.
  ///
  /// Useful for testing fade animations.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [parentFinder]: A Finder that locates the parent widget containing the opacity widget
  ///
  /// Returns:
  /// - The current opacity value (0.0 to 1.0)
  ///
  /// Throws:
  /// - [TestFailure] if no Opacity or FadeTransition widget is found
  ///
  /// Example:
  /// ```dart
  /// final opacity = AnimationTestUtils.getOpacity(
  ///   tester,
  ///   find.byKey(Key('fade_widget')),
  /// );
  /// expect(opacity, closeTo(1.0, 0.01));
  /// ```
  static double getOpacity(
    WidgetTester tester,
    Finder parentFinder,
  ) {
    expect(parentFinder, findsOneWidget, reason: 'Parent widget must exist');

    // Try to find Opacity widget first
    final opacityFinder = find.descendant(
      of: parentFinder,
      matching: find.byType(Opacity),
    );

    if (opacityFinder.evaluate().isNotEmpty) {
      final opacity = tester.widget<Opacity>(opacityFinder.first);
      return opacity.opacity;
    }

    // Try FadeTransition
    final fadeTransitionFinder = find.descendant(
      of: parentFinder,
      matching: find.byType(FadeTransition),
    );

    if (fadeTransitionFinder.evaluate().isNotEmpty) {
      final fadeTransition =
          tester.widget<FadeTransition>(fadeTransitionFinder.first);
      return fadeTransition.opacity.value;
    }

    fail('No Opacity or FadeTransition widget found as descendant');
  }

  /// Verifies that a widget's opacity matches the expected value.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [parentFinder]: A Finder that locates the parent widget
  /// - [expected]: The expected opacity value (0.0 to 1.0)
  /// - [tolerance]: The acceptable deviation from expected (default: 0.01)
  ///
  /// Example:
  /// ```dart
  /// AnimationTestUtils.verifyOpacity(
  ///   tester,
  ///   find.byKey(Key('fade_widget')),
  ///   1.0,
  /// );
  /// ```
  static void verifyOpacity(
    WidgetTester tester,
    Finder parentFinder,
    double expected, {
    double tolerance = defaultTolerance,
  }) {
    final opacity = getOpacity(tester, parentFinder);
    expect(
      opacity,
      closeTo(expected, tolerance),
      reason: 'Opacity should be $expected (±$tolerance). Actual: $opacity',
    );
  }

  /// Verifies that an animation controller is properly disposed.
  ///
  /// This checks that the controller is no longer usable after disposal.
  ///
  /// Parameters:
  /// - [controller]: The AnimationController to verify
  ///
  /// Note: This should be called after the widget using the controller
  /// has been disposed (e.g., after pumping a different widget tree).
  ///
  /// Example:
  /// ```dart
  /// // After disposing the widget
  /// AnimationTestUtils.verifyControllerDisposed(controller);
  /// ```
  static void verifyControllerDisposed(AnimationController controller) {
    // A disposed controller will throw when trying to access certain properties
    // or perform operations. We check the status which should throw.
    bool isDisposed = false;
    try {
      // Attempting to forward a disposed controller throws
      controller.forward();
    } on Object {
      // FlutterError is thrown when controller is disposed
      isDisposed = true;
    }

    expect(
      isDisposed,
      isTrue,
      reason: 'AnimationController should be disposed and throw on operations',
    );
  }

  /// Pumps the widget tree for a specific duration to advance animations.
  ///
  /// Useful for testing animation states at specific points in time.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [duration]: The duration to advance the animation
  ///
  /// Example:
  /// ```dart
  /// // Advance animation by 50ms
  /// await AnimationTestUtils.pumpDuration(tester, Duration(milliseconds: 50));
  /// ```
  static Future<void> pumpDuration(
    WidgetTester tester,
    Duration duration,
  ) async {
    await tester.pump(duration);
  }

  /// Pumps the widget tree in small increments to observe animation progress.
  ///
  /// Useful for debugging or testing animation curves.
  ///
  /// Parameters:
  /// - [tester]: The WidgetTester instance from the test
  /// - [totalDuration]: The total duration to pump
  /// - [frameInterval]: The interval between pumps (default: 16ms for ~60fps)
  /// - [onFrame]: Optional callback called after each pump with elapsed time
  ///
  /// Example:
  /// ```dart
  /// await AnimationTestUtils.pumpFrames(
  ///   tester,
  ///   Duration(milliseconds: 300),
  ///   onFrame: (elapsed) {
  ///     print('Elapsed: $elapsed, Value: ${controller.value}');
  ///   },
  /// );
  /// ```
  static Future<void> pumpFrames(
    WidgetTester tester,
    Duration totalDuration, {
    Duration frameInterval = const Duration(milliseconds: 16),
    void Function(Duration elapsed)? onFrame,
  }) async {
    Duration elapsed = Duration.zero;
    while (elapsed < totalDuration) {
      await tester.pump(frameInterval);
      elapsed += frameInterval;
      onFrame?.call(elapsed);
    }
  }

  /// Creates a test widget wrapper with MaterialApp for animation testing.
  ///
  /// Provides a consistent test environment for animated widgets.
  ///
  /// Parameters:
  /// - [child]: The widget to test
  /// - [key]: Optional key for the MaterialApp
  ///
  /// Returns:
  /// - A MaterialApp wrapping the child in a Scaffold
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpWidget(
  ///   AnimationTestUtils.wrapForTest(
  ///     ScaleTapWidget(
  ///       key: Key('test_widget'),
  ///       child: Container(),
  ///     ),
  ///   ),
  /// );
  /// ```
  static Widget wrapForTest(Widget child, {Key? key}) {
    return MaterialApp(
      key: key,
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    );
  }
}
