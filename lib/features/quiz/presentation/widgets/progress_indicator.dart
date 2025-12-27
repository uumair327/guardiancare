import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Modern animated progress indicator for quiz
/// Shows current progress with smooth animations
class QuizProgressIndicator extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final Color? activeColor;
  final Color? inactiveColor;

  const QuizProgressIndicator({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentQuestion / totalQuestions;
    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ?? AppColors.divider;

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: inactive,
              borderRadius: AppDimensions.borderRadiusXS,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: AppDurations.animationMedium,
                      curve: AppCurves.standard,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            active,
                            active.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: AppDimensions.borderRadiusXS,
                        boxShadow: [
                          BoxShadow(
                            color: active.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: AppDimensions.spaceS),
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $currentQuestion of $totalQuestions',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: active,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular progress indicator for quiz completion
class QuizCircularProgress extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? activeColor;
  final Color? inactiveColor;
  final Widget? child;

  const QuizCircularProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.activeColor,
    this.inactiveColor,
    this.child,
  });

  @override
  State<QuizCircularProgress> createState() => _QuizCircularProgressState();
}

class _QuizCircularProgressState extends State<QuizCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.emphasized),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(QuizCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: AppCurves.emphasized),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? AppColors.primary;
    final inactive = widget.inactiveColor ?? AppColors.divider;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: _CircularProgressPainter(
                progress: _progressAnimation.value,
                activeColor: active,
                inactiveColor: inactive,
                strokeWidth: widget.strokeWidth,
              ),
              child: child,
            );
          },
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -1.5708,
        endAngle: 4.7124,
        colors: [
          activeColor,
          activeColor.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start from top
      progress * 6.2832, // Full circle = 2 * pi
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
