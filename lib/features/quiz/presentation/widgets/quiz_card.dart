import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern quiz card with 3D effect and animations
/// Education-friendly design with vibrant colors
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

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  Offset _tiltOffset = Offset.zero;

  // Quiz colors for visual variety
  static const List<Color> _quizColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFEF4444), // Red
    Color(0xFF14B8A6), // Teal
  ];

  Color get _cardColor => _quizColors[widget.index % _quizColors.length];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppDurations.animationShort,
                curve: AppCurves.standard,
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
                child: child,
              ),
            );
          },
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
                            'Start Quiz',
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
