import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Modern quiz card with 3D effect and animations
/// Education-friendly design with vibrant colors
///
/// Uses centralized [ScaleTapWidget] for scale-tap animation,
/// while maintaining the 3D tilt effect on pan gestures.
class QuizCard extends StatefulWidget {
  final String name;
  final String? thumbnail;
  final VoidCallback onTap;
  final int index;
  final int? questionCount;

  const QuizCard({
    super.key,
    required this.name,
    this.thumbnail,
    required this.onTap,
    this.index = 0,
    this.questionCount,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  bool _isPressed = false;
  Offset _tiltOffset = Offset.zero;

  /// Custom animation config for quiz card (0.96 scale).
  static const _quizCardConfig = AnimationConfig(
    duration: AppDurations.animationShort,
    curve: AppCurves.tap,
    begin: 1.0,
    end: 0.96,
  );

  Color get _cardColor => AppColors.cardPalette[widget.index % AppColors.cardPalette.length];

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final localPosition = details.localPosition;

    final dx = (localPosition.dx - size.width / 2) / (size.width / 2);
    final dy = (localPosition.dy - size.height / 2) / (size.height / 2);

    setState(() {
      _tiltOffset = Offset(
        dy.clamp(-1.0, 1.0) * 0.03,
        -dx.clamp(-1.0, 1.0) * 0.03,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _tiltOffset = Offset.zero);
  }

  void _onPressStateChanged(bool isPressed) {
    setState(() => _isPressed = isPressed);
  }

  @override
  Widget build(BuildContext context) {
    // Use GestureDetector for pan gestures (3D tilt effect)
    // ScaleTapWidget handles tap and scale animation
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: _ScaleTapWithPressCallback(
        config: _quizCardConfig,
        onTap: widget.onTap,
        enableHaptic: true,
        hapticType: HapticFeedbackType.light,
        onPressStateChanged: _onPressStateChanged,
        child: AppAnimatedContainer(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltOffset.dx)
            ..rotateY(_tiltOffset.dy),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusL,
            boxShadow: [
              BoxShadow(
                color: _cardColor.withValues(alpha: _isPressed ? 0.2 : 0.3),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(
                  _tiltOffset.dy * 10,
                  _tiltOffset.dx * 10 + (_isPressed ? 4 : 8),
                ),
                spreadRadius: _isPressed ? 0 : 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppDimensions.borderRadiusL,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or gradient
                if (widget.thumbnail != null && widget.thumbnail!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: widget.thumbnail!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: _cardColor.withValues(alpha: 0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _cardColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildGradientBackground(),
                  )
                else
                  _buildGradientBackground(),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _cardColor.withValues(alpha: 0.7),
                        _cardColor.withValues(alpha: 0.95),
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: AppDimensions.spaceM,
                  right: AppDimensions.spaceM,
                  bottom: AppDimensions.spaceM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Quiz icon
                      Container(
                        padding: EdgeInsets.all(AppDimensions.spaceS),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: AppDimensions.borderRadiusS,
                        ),
                        child: Icon(
                          Icons.quiz_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconM,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceS),
                      // Quiz name
                      Text(
                        _capitalizeEach(widget.name),
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: AppColors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimensions.spaceXS),
                      // Start quiz hint
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            color: AppColors.white.withValues(alpha: 0.8),
                            size: AppDimensions.iconXS,
                          ),
                          SizedBox(width: AppDimensions.spaceXS),
                          Text(
                            UIStrings.startQuiz,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          if (widget.questionCount != null) ...[
                            SizedBox(width: AppDimensions.spaceS),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.spaceS,
                                vertical: AppDimensions.spaceXXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                borderRadius: AppDimensions.borderRadiusXS,
                              ),
                              child: Text(
                                '${widget.questionCount} Q',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Trophy badge
                Positioned(
                  top: AppDimensions.spaceM,
                  right: AppDimensions.spaceM,
                  child: AnimatedOpacity(
                    duration: AppDurations.animationShort,
                    opacity: _isPressed ? 0.6 : 1.0,
                    child: Container(
                      padding: EdgeInsets.all(AppDimensions.spaceS),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: _cardColor,
                        size: AppDimensions.iconM,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _cardColor.withValues(alpha: 0.8),
            _cardColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.quiz_rounded,
          size: AppDimensions.iconXXL * 1.5,
          color: AppColors.white.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  String _capitalizeEach(String? text) {
    if (text == null || text.isEmpty) return "";
    final List<String> words = text.split(' ');
    final formatted = words.map((e) {
      if (e.isEmpty) return e;
      return '${e[0].toUpperCase()}${e.substring(1)}';
    }).toList();
    return formatted.join(' ');
  }
}

/// A wrapper around ScaleTapWidget that provides press state callbacks.
///
/// This is used by QuizCard to track press state for visual effects
/// (shadow changes, opacity changes) while using the centralized
/// ScaleTapWidget for scale animation.
class _ScaleTapWithPressCallback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final AnimationConfig? config;
  final bool enableHaptic;
  final HapticFeedbackType hapticType;
  final ValueChanged<bool>? onPressStateChanged;

  const _ScaleTapWithPressCallback({
    required this.child,
    this.onTap,
    this.config,
    this.enableHaptic = true,
    this.hapticType = HapticFeedbackType.light,
    this.onPressStateChanged,
  });

  @override
  State<_ScaleTapWithPressCallback> createState() => _ScaleTapWithPressCallbackState();
}

class _ScaleTapWithPressCallbackState extends State<_ScaleTapWithPressCallback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  AnimationConfig get _effectiveConfig =>
      widget.config ?? AnimationPresets.scaleButton;

  @override
  void initState() {
    super.initState();
    final config = _effectiveConfig;
    _controller = AnimationController(
      vsync: this,
      duration: config.duration,
    );
    _scaleAnimation = config.createAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    widget.onPressStateChanged?.call(true);
    if (widget.enableHaptic) {
      widget.hapticType.trigger();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressStateChanged?.call(false);
  }

  void _onTapCancel() {
    _controller.reverse();
    widget.onPressStateChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
