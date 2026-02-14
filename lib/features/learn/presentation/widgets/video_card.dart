import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';

/// Modern video card with animations and education-friendly design
/// Features thumbnail preview, title, and play button overlay
class VideoCard extends StatefulWidget {

  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.index = 0,
  });
  final VideoEntity video;
  final VoidCallback onTap;
  final int index;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.96).animate(
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
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
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
              curve: AppCurves.standard,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: AppDimensions.borderRadiusL,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowMedium.withValues(
                      alpha: _isPressed ? 0.1 : (_isHovered ? 0.25 : 0.15),
                    ),
                    blurRadius: _isPressed ? 8 : (_isHovered ? 20 : 12),
                    offset: Offset(0, _isPressed ? 2 : (_isHovered ? 8 : 4)),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusL,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thumbnail with play overlay
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail image
                          CachedNetworkImage(
                            imageUrl: widget.video.thumbnailUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.shimmerBase,
                              child: Center(
                                child: ShimmerLoading(
                                  child: Container(
                                    color: AppColors.shimmerBase,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              child: const Icon(
                                Icons.video_library_rounded,
                                size: AppDimensions.iconXL,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.black.withValues(alpha: 0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Play button
                          Center(
                            child: AnimatedScale(
                              scale:
                                  _isPressed ? 0.9 : (_isHovered ? 1.1 : 1.0),
                              duration: AppDurations.animationShort,
                              child: AnimatedOpacity(
                                duration: AppDurations.animationShort,
                                opacity: _isPressed ? 0.7 : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.all(AppDimensions.spaceM),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.white.withValues(alpha: 0.95),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black
                                            .withValues(alpha: 0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.primary,
                                    size: AppDimensions.iconL,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Duration badge (placeholder)
                          Positioned(
                            bottom: AppDimensions.spaceS,
                            right: AppDimensions.spaceS,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spaceS,
                                vertical: AppDimensions.spaceXXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black.withValues(alpha: 0.7),
                                borderRadius: AppDimensions.borderRadiusXS,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: AppColors.white,
                                    size: AppDimensions.iconXS,
                                  ),
                                  const SizedBox(width: AppDimensions.spaceXXS),
                                  Text(
                                    'Video',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Title section
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceS),
                      child: Text(
                        widget.video.title,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          height: 1.2,
                        ),
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
      ),
    );
  }
}

/// Horizontal video card for list view
class VideoListCard extends StatefulWidget {

  const VideoListCard({
    super.key,
    required this.video,
    required this.onTap,
    this.index = 0,
  });
  final VideoEntity video;
  final VoidCallback onTap;
  final int index;

  @override
  State<VideoListCard> createState() => _VideoListCardState();
}

class _VideoListCardState extends State<VideoListCard>
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

    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
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
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTap: widget.onTap,
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
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppDimensions.borderRadiusL,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium.withValues(
                    alpha: _isPressed ? 0.1 : 0.15,
                  ),
                  blurRadius: _isPressed ? 6 : 12,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppDimensions.borderRadiusL,
              child: Row(
                children: [
                  // Thumbnail
                  SizedBox(
                    width: 140,
                    height: 100,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.video.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.shimmerBase,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.video_library_rounded,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        // Play icon overlay
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppDimensions.spaceS),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.primary,
                              size: AppDimensions.iconM,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.video.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Row(
                            children: [
                              const Icon(
                                Icons.play_circle_outline_rounded,
                                size: AppDimensions.iconXS,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppDimensions.spaceXXS),
                              Text(
                                'Tap to watch',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Arrow
                  const Padding(
                    padding: EdgeInsets.only(right: AppDimensions.spaceM),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppDimensions.iconS,
                      color: AppColors.textSecondary,
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
