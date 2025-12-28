import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/core/animations/animated_widgets/scale_tap_widget.dart';
import 'package:guardiancare/core/animations/config/animation_presets.dart';

import 'animation_test_utils.dart';

/// Tests for AnimationTestUtils
/// Validates: Requirements 9.1, 9.2, 9.3, 9.4
void main() {
  group('AnimationTestUtils', () {
    group('verifyAnimationComplete', () {
      testWidgets('verifies completed animation', (tester) async {
        late AnimationController controller;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return _AnimatedTestWidget(
                    onControllerCreated: (c) => controller = c,
                  );
                },
              ),
            ),
          ),
        );

        // Start animation
        controller.forward();
        await AnimationTestUtils.verifyAnimationComplete(tester, controller);
      });
    });

    group('verifyAnimationValue', () {
      testWidgets('verifies animation value at specific point', (tester) async {
        late AnimationController controller;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AnimatedTestWidget(
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Initial value should be 0.0
        AnimationTestUtils.verifyAnimationValue(controller, 0.0);

        // Forward to completion
        controller.forward();
        await tester.pumpAndSettle();

        // Final value should be 1.0
        AnimationTestUtils.verifyAnimationValue(controller, 1.0);
      });
    });

    group('simulatePressRelease', () {
      testWidgets('simulates complete press-release cycle', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          AnimationTestUtils.wrapForTest(
            ScaleTapWidget(
              key: const Key('test_scale_tap'),
              config: AnimationPresets.scaleButton,
              enableHaptic: false,
              onTap: () => tapped = true,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        );

        await AnimationTestUtils.simulatePressRelease(
          tester,
          find.byKey(const Key('test_scale_tap')),
        );

        expect(tapped, isTrue);
      });
    });

    group('simulatePressDown', () {
      testWidgets('simulates press down and returns gesture', (tester) async {
        await tester.pumpWidget(
          AnimationTestUtils.wrapForTest(
            ScaleTapWidget(
              key: const Key('test_scale_tap'),
              config: AnimationPresets.scaleButton,
              enableHaptic: false,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        );

        final gesture = await AnimationTestUtils.simulatePressDown(
          tester,
          find.byKey(const Key('test_scale_tap')),
        );

        // Scale should be at pressed state (0.95)
        AnimationTestUtils.verifyScale(
          tester,
          find.byKey(const Key('test_scale_tap')),
          0.95,
          tolerance: 0.02,
        );

        // Release gesture
        await gesture.up();
        await tester.pumpAndSettle();

        // Scale should return to 1.0
        AnimationTestUtils.verifyScale(
          tester,
          find.byKey(const Key('test_scale_tap')),
          1.0,
        );
      });
    });

    group('getScaleFromTransform', () {
      testWidgets('extracts scale value from Transform widget', (tester) async {
        await tester.pumpWidget(
          AnimationTestUtils.wrapForTest(
            ScaleTapWidget(
              key: const Key('test_scale_tap'),
              config: AnimationPresets.scaleButton,
              enableHaptic: false,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        );

        final scale = AnimationTestUtils.getScaleFromTransform(
          tester,
          find.byKey(const Key('test_scale_tap')),
        );

        expect(scale, closeTo(1.0, 0.01));
      });
    });

    group('verifyScale', () {
      testWidgets('verifies scale matches expected value', (tester) async {
        await tester.pumpWidget(
          AnimationTestUtils.wrapForTest(
            ScaleTapWidget(
              key: const Key('test_scale_tap'),
              scaleDown: 0.9,
              enableHaptic: false,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        );

        // Initial scale should be 1.0
        AnimationTestUtils.verifyScale(
          tester,
          find.byKey(const Key('test_scale_tap')),
          1.0,
        );

        // Press down
        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('test_scale_tap'))),
        );
        await tester.pumpAndSettle();

        // Scale should be 0.9
        AnimationTestUtils.verifyScale(
          tester,
          find.byKey(const Key('test_scale_tap')),
          0.9,
          tolerance: 0.02,
        );

        await gesture.up();
      });
    });

    group('pumpDuration', () {
      testWidgets('advances animation by specific duration', (tester) async {
        late AnimationController controller;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _AnimatedTestWidget(
                duration: const Duration(milliseconds: 200),
                onControllerCreated: (c) => controller = c,
              ),
            ),
          ),
        );

        // Start animation and pump once to begin
        controller.forward();
        await tester.pump();

        // Pump for half the duration using our utility
        await AnimationTestUtils.pumpDuration(
          tester,
          const Duration(milliseconds: 100),
        );

        // Value should be approximately 0.5 (depending on curve)
        expect(controller.value, greaterThan(0.0));
        expect(controller.value, lessThan(1.0));
      });
    });

    group('wrapForTest', () {
      testWidgets('creates proper test wrapper', (tester) async {
        await tester.pumpWidget(
          AnimationTestUtils.wrapForTest(
            Container(
              key: const Key('test_container'),
              width: 100,
              height: 100,
            ),
          ),
        );

        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byKey(const Key('test_container')), findsOneWidget);
      });
    });
  });
}

/// Helper widget for testing animation controller
class _AnimatedTestWidget extends StatefulWidget {
  final void Function(AnimationController) onControllerCreated;
  final Duration duration;

  const _AnimatedTestWidget({
    required this.onControllerCreated,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<_AnimatedTestWidget> createState() => _AnimatedTestWidgetState();
}

class _AnimatedTestWidgetState extends State<_AnimatedTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    widget.onControllerCreated(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        );
      },
    );
  }
}
