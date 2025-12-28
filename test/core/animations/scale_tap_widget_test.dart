import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/animations/animated_widgets/scale_tap_widget.dart';
import 'package:guardiancare/core/animations/config/animation_config.dart';
import 'package:guardiancare/core/animations/config/animation_presets.dart';

/// Property-based tests for ScaleTapWidget
/// Feature: animation-centralization, Property 1: Scale animation round-trip
/// Validates: Requirements 1.2, 1.3
///
/// Property 1: Scale Animation Round-Trip
/// *For any* ScaleTapWidget with any configured scale value, pressing down
/// then releasing (or canceling) SHALL return the widget's scale to exactly 1.0.

void main() {
  /// Helper to find the Transform widget inside ScaleTapWidget and get its scale value
  double getScaleValue(WidgetTester tester) {
    // Find the Transform that is a descendant of ScaleTapWidget
    final scaleTapWidget = find.byKey(const Key('scale_tap_widget'));
    expect(scaleTapWidget, findsOneWidget);

    // Find Transform that is a descendant of the ScaleTapWidget
    final transformFinder = find.descendant(
      of: scaleTapWidget,
      matching: find.byType(Transform),
    );
    expect(transformFinder, findsOneWidget);

    final transform = tester.widget<Transform>(transformFinder);
    // Extract scale from the transform matrix
    final matrix = transform.transform;
    // Scale is stored in the diagonal elements [0,0] and [1,1]
    return matrix.storage[0]; // X scale (same as Y for uniform scale)
  }

  /// Generate random scale values for property-based testing
  /// Scale values should be between 0.5 and 0.99 for visible scale-down effect
  List<double> generateScaleValues(int count, int seed) {
    final random = Random(seed);
    return List.generate(count, (_) => 0.5 + random.nextDouble() * 0.49);
  }

  group('ScaleTapWidget Property Tests', () {
    // Feature: animation-centralization, Property 1: Scale animation round-trip
    // For any ScaleTapWidget with any configured scale value, pressing down
    // then releasing SHALL return the widget's scale to exactly 1.0

    // Property-based test with 100 random scale values (press-release cycle)
    // Each iteration uses a fresh widget to avoid state issues
    testWidgets(
      'Property 1: Scale returns to 1.0 after press-release cycle for any scale value (100 iterations)',
      (tester) async {
        const iterations = 100;
        const seed = 42; // Fixed seed for reproducibility
        final scaleValues = generateScaleValues(iterations, seed);

        for (var i = 0; i < iterations; i++) {
          final scaleDown = scaleValues[i];

          // Create a fresh widget with unique key for each iteration
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey('app_$i'),
              home: Scaffold(
                body: Center(
                  child: ScaleTapWidget(
                    key: const Key('scale_tap_widget'),
                    scaleDown: scaleDown,
                    duration: const Duration(milliseconds: 100),
                    enableHaptic: false, // Disable haptic for testing
                    child: Container(
                      key: const Key('test_child'),
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Initial state: scale should be 1.0
          expect(
            getScaleValue(tester),
            closeTo(1.0, 0.001),
            reason: 'Initial scale should be 1.0 for scaleDown=$scaleDown',
          );

          // Find the ScaleTapWidget for gesture interaction
          final scaleTapWidget = find.byKey(const Key('scale_tap_widget'));

          // Simulate tap down - start gesture
          final gesture = await tester.startGesture(
            tester.getCenter(scaleTapWidget),
          );
          await tester.pumpAndSettle();

          // After press: scale should be at the configured scaleDown value
          expect(
            getScaleValue(tester),
            closeTo(scaleDown, 0.02),
            reason: 'Scale after press should be $scaleDown',
          );

          // Simulate tap up (release)
          await gesture.up();
          await tester.pumpAndSettle();

          // After release: scale should return to exactly 1.0 (round-trip property)
          expect(
            getScaleValue(tester),
            closeTo(1.0, 0.001),
            reason:
                'Scale should return to 1.0 after release for scaleDown=$scaleDown (iteration $i)',
          );
        }
      },
    );

    // Property-based test with 100 random scale values (press-cancel cycle)
    testWidgets(
      'Property 1: Scale returns to 1.0 after press-cancel cycle for any scale value (100 iterations)',
      (tester) async {
        const iterations = 100;
        const seed = 123; // Different seed for variety
        final scaleValues = generateScaleValues(iterations, seed);

        for (var i = 0; i < iterations; i++) {
          final scaleDown = scaleValues[i];

          // Create a fresh widget with unique key for each iteration
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey('app_cancel_$i'),
              home: Scaffold(
                body: Center(
                  child: ScaleTapWidget(
                    key: const Key('scale_tap_widget'),
                    scaleDown: scaleDown,
                    duration: const Duration(milliseconds: 100),
                    enableHaptic: false,
                    child: Container(
                      key: const Key('test_child'),
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Initial state: scale should be 1.0
          expect(
            getScaleValue(tester),
            closeTo(1.0, 0.001),
            reason: 'Initial scale should be 1.0 for scaleDown=$scaleDown',
          );

          final scaleTapWidget = find.byKey(const Key('scale_tap_widget'));

          // Simulate tap down
          final gesture = await tester.startGesture(
            tester.getCenter(scaleTapWidget),
          );
          await tester.pumpAndSettle();

          // After press: scale should be at the configured scaleDown value
          expect(
            getScaleValue(tester),
            closeTo(scaleDown, 0.02),
            reason: 'Scale after press should be $scaleDown',
          );

          // Simulate cancel by calling cancel on the gesture
          await gesture.cancel();
          await tester.pumpAndSettle();

          // After cancel: scale should return to exactly 1.0 (round-trip property)
          expect(
            getScaleValue(tester),
            closeTo(1.0, 0.001),
            reason:
                'Scale should return to 1.0 after cancel for scaleDown=$scaleDown (iteration $i)',
          );
        }
      },
    );

    // Test with AnimationConfig presets
    testWidgets(
      'Property 1: Scale returns to 1.0 using AnimationPresets.scaleButton',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ScaleTapWidget(
                  key: const Key('scale_tap_widget'),
                  config: AnimationPresets.scaleButton,
                  enableHaptic: false,
                  child: Container(
                    key: const Key('test_child'),
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial state
        expect(getScaleValue(tester), closeTo(1.0, 0.001));

        final scaleTapWidget = find.byKey(const Key('scale_tap_widget'));

        // Press down
        final gesture = await tester.startGesture(
          tester.getCenter(scaleTapWidget),
        );
        await tester.pumpAndSettle();

        // Should be at preset scale (0.95)
        expect(getScaleValue(tester), closeTo(0.95, 0.02));

        // Release
        await gesture.up();
        await tester.pumpAndSettle();

        // Should return to 1.0
        expect(getScaleValue(tester), closeTo(1.0, 0.001));
      },
    );

    testWidgets(
      'Property 1: Scale returns to 1.0 using AnimationPresets.scaleLarge',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ScaleTapWidget(
                  key: const Key('scale_tap_widget'),
                  config: AnimationPresets.scaleLarge,
                  enableHaptic: false,
                  child: Container(
                    key: const Key('test_child'),
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial state
        expect(getScaleValue(tester), closeTo(1.0, 0.001));

        final scaleTapWidget = find.byKey(const Key('scale_tap_widget'));

        // Press down
        final gesture = await tester.startGesture(
          tester.getCenter(scaleTapWidget),
        );
        await tester.pumpAndSettle();

        // Should be at preset scale (0.9)
        expect(getScaleValue(tester), closeTo(0.9, 0.02));

        // Release
        await gesture.up();
        await tester.pumpAndSettle();

        // Should return to 1.0
        expect(getScaleValue(tester), closeTo(1.0, 0.001));
      },
    );

    // Property-based test with custom AnimationConfig (100 iterations)
    testWidgets(
      'Property 1: Scale returns to 1.0 with custom AnimationConfig (100 iterations)',
      (tester) async {
        const iterations = 100;
        const seed = 456;
        final scaleValues = generateScaleValues(iterations, seed);
        final random = Random(seed);
        final durations =
            List.generate(iterations, (_) => 50 + random.nextInt(450));

        for (var i = 0; i < iterations; i++) {
          final scaleDown = scaleValues[i];
          final durationMs = durations[i];

          final config = AnimationConfig(
            duration: Duration(milliseconds: durationMs),
            curve: Curves.easeOutQuad,
            begin: 1.0,
            end: scaleDown,
          );

          // Create a fresh widget with unique key for each iteration
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey('app_config_$i'),
              home: Scaffold(
                body: Center(
                  child: ScaleTapWidget(
                    key: const Key('scale_tap_widget'),
                    config: config,
                    enableHaptic: false,
                    child: Container(
                      key: const Key('test_child'),
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Initial state
          expect(
            getScaleValue(tester),
            closeTo(1.0, 0.001),
            reason: 'Initial scale should be 1.0',
          );

          final scaleTapWidget = find.byKey(const Key('scale_tap_widget'));

          // Press down
          final gesture = await tester.startGesture(
            tester.getCenter(scaleTapWidget),
          );
          await tester.pumpAndSettle();

          // Should be at configured scale
          expect(
            getScaleValue(tester),
            closeTo(scaleDown, 0.02),
            reason: 'Scale after press should be $scaleDown',
          );

          // Release
          await gesture.up();
          await tester.pumpAndSettle();

          // Should return to 1.0 (round-trip property)
          expect(
            getScaleValue(tester),
            closeTo(1.0, 0.001),
            reason:
                'Scale should return to 1.0 after release (iteration $i, scaleDown=$scaleDown, duration=${durationMs}ms)',
          );
        }
      },
    );
  });
}
