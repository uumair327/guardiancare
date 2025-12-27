import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';

class ContentCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;

  const ContentCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
        onTap: () => context.push('/video-player', extra: widget.description),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: AppDurations.animationShort,
            margin: EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              borderRadius: AppDimensions.borderRadiusM,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium.withValues(
                    alpha: _isPressed ? 0.1 : 0.2,
                  ),
                  blurRadius: _isPressed ? 8 : 12,
                  offset: Offset(0, _isPressed ? 2 : 6),
                ),
              ],
            ),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thumbnail with error handling
                  Stack(
                    children: [
                      widget.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              height: 200,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return ShimmerLoading(
                                  child: Container(
                                    height: 200,
                                    color: AppColors.shimmerBase,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: AppColors.shimmerBase,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: AppDimensions.iconXXL,
                                    color: AppColors.textSecondary,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 200,
                              color: AppColors.shimmerBase,
                              child: Icon(
                                Icons.video_library,
                                size: AppDimensions.iconXXL,
                                color: AppColors.textSecondary,
                              ),
                            ),
                      // Play button overlay
                      Positioned.fill(
                        child: Center(
                          child: AnimatedOpacity(
                            duration: AppDurations.animationShort,
                            opacity: _isPressed ? 0.6 : 0.8,
                            child: Container(
                              padding: EdgeInsets.all(AppDimensions.spaceM),
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
                                color: AppColors.primary,
                                size: AppDimensions.iconL,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Title
                  Padding(
                    padding: AppDimensions.paddingAllM,
                    child: Text(
                      widget.title,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
