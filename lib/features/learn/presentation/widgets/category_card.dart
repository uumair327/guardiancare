import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';

/// Modern category card with 3D effect and animations
/// Education-friendly design with vibrant colors and clear typography
class CategoryCard extends StatefulWidget {
  final CategoryEntity category;
  final VoidCallback onTap;
  final int index;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  Offset _tiltOffset = Offset.zero;

  Color get _cardColor => AppColors.cardPalette[widget.index % AppColors.cardPalette.length];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
        dy.clamp(-1.0, 1.0) * 0.05,
        -dx.clamp(-1.0, 1.0) * 0.05,
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
                // Background image
                CachedNetworkImage(
                  imageUrl: widget.category.thumbnail,
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
                  errorWidget: (context, url, error) => Container(
                    color: _cardColor.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.school_rounded,
                      size: AppDimensions.iconXXL,
                      color: _cardColor,
                    ),
                  ),
                ),
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
                      stops: const [0.3, 0.7, 1.0],
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
                      // Category icon
                      Container(
                        padding: EdgeInsets.all(AppDimensions.spaceS),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: AppDimensions.borderRadiusS,
                        ),
                        child: Icon(
                          _getCategoryIcon(widget.category.name),
                          color: AppColors.white,
                          size: AppDimensions.iconM,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceS),
                      // Category name
                      Text(
                        widget.category.name,
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
                      // Tap to explore hint
                      Row(
                        children: [
                          Text(
                            'Tap to explore',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(width: AppDimensions.spaceXS),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white.withValues(alpha: 0.8),
                            size: AppDimensions.iconXS,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Play indicator
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
                        Icons.play_arrow_rounded,
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

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('safety') || name.contains('safe')) {
      return Icons.security_rounded;
    } else if (name.contains('health')) {
      return Icons.favorite_rounded;
    } else if (name.contains('education') || name.contains('learn')) {
      return Icons.school_rounded;
    } else if (name.contains('family') || name.contains('parent')) {
      return Icons.family_restroom_rounded;
    } else if (name.contains('child') || name.contains('kid')) {
      return Icons.child_care_rounded;
    } else if (name.contains('online') || name.contains('internet')) {
      return Icons.language_rounded;
    } else if (name.contains('bully')) {
      return Icons.shield_rounded;
    } else if (name.contains('abuse')) {
      return Icons.report_problem_rounded;
    }
    return Icons.play_lesson_rounded;
  }
}
