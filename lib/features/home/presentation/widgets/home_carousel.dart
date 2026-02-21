import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/home/home.dart';

/// Education-friendly carousel with animations
/// Features 3D effects, smooth transitions, and engaging visuals
class HomeCarousel extends StatefulWidget {
  const HomeCarousel({super.key});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    final carouselHeight = context.responsiveValue<double>(
      mobile: screenHeight * 0.22,
      tablet: 260,
      desktop: 320,
      widescreen: 380,
    );

    final viewportFraction = context.responsiveValue<double>(
      mobile: 0.85,
      tablet: 0.6,
      desktop: 0.45,
      widescreen: 0.35,
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is CarouselItemsLoaded) {
          final items = state.items;

          if (items.isEmpty) {
            return _buildShimmerCarousel(carouselHeight, viewportFraction);
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                CarouselSlider.builder(
                  itemCount: items.length,
                  options: CarouselOptions(
                    height: carouselHeight,
                    viewportFraction: viewportFraction,
                    enableInfiniteScroll: items.length > 1,
                    autoPlay: items.length > 1,
                    autoPlayInterval: AppDurations.carouselAutoPlay,
                    autoPlayCurve: Curves.easeInOutCubic,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.2,
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    return CarouselCard(
                      item: items[index],
                      isActive: index == _currentIndex,
                      onTap: () => _handleItemTap(context, items[index]),
                    );
                  },
                ),
                if (items.length > 1) ...[
                  const SizedBox(height: AppDimensions.spaceM),
                  _buildIndicators(items.length),
                ],
              ],
            ),
          );
        } else if (state is HomeError) {
          return _buildErrorCarousel(
              carouselHeight, viewportFraction, state.message);
        } else {
          return _buildShimmerCarousel(carouselHeight, viewportFraction);
        }
      },
    );
  }

  Widget _buildIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: AppDurations.animationShort,
          curve: AppCurves.standard,
          width: isActive ? 24.0 : 8.0,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  )
                : null,
            color: isActive ? null : AppColors.primary.withValues(alpha: 0.25),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildShimmerCarousel(double height, double viewportFraction) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: 3,
          options: CarouselOptions(
            height: height,
            viewportFraction: viewportFraction,
            autoPlay: true,
            autoPlayInterval: AppDurations.carouselAutoPlay,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
          ),
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXS),
              child: ShimmerLoading(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: AppDimensions.borderRadiusXL,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppDimensions.spaceM),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: index == 0 ? 24.0 : 8.0,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.shimmerBase,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildErrorCarousel(
      double height, double viewportFraction, String message) {
    final double width = MediaQuery.sizeOf(context).width * viewportFraction;

    return FadeSlideWidget(
      child: Container(
        height: height,
        width: width.clamp(
            300, 800), // Bound the maximum width of the error message box
        margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.error.withValues(alpha: 0.1),
              AppColors.error.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: AppDimensions.borderRadiusXL,
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.error,
                  size: AppDimensions.iconL,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Text(
                UIStrings.contentUnavailable,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXS),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceL),
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemTap(BuildContext context, CarouselItemEntity item) {
    HapticFeedback.lightImpact();
    if (item.type == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomContentPage(content: item.content),
        ),
      );
    } else {
      context.push('/webview', extra: item.link);
    }
  }
}

/// Carousel card with 3D effects and animations
class CarouselCard extends StatefulWidget {
  const CarouselCard({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });
  final CarouselItemEntity item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  Offset _tiltOffset = Offset.zero;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.selectionClick();
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
        dy.clamp(-1.0, 1.0) * 0.02,
        -dx.clamp(-1.0, 1.0) * 0.02,
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _tiltOffset = Offset.zero);
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
                margin: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXS),
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_tiltOffset.dx)
                  ..rotateY(_tiltOffset.dy),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppDimensions.borderRadiusXL,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha:
                            widget.isActive ? (_isPressed ? 0.15 : 0.25) : 0.1,
                      ),
                      blurRadius: widget.isActive ? 20 : 12,
                      offset: Offset(
                        _tiltOffset.dy * 8,
                        _tiltOffset.dx * 8 + (widget.isActive ? 8 : 4),
                      ),
                      spreadRadius: widget.isActive ? 2 : 0,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: AppDimensions.borderRadiusXL,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                CachedNetworkImage(
                  imageUrl: widget.item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      _buildErrorPlaceholder(),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.4),
                        AppColors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                // Content overlay
                Positioned(
                  left: AppDimensions.spaceM,
                  right: AppDimensions.spaceM,
                  bottom: AppDimensions.spaceM,
                  child: Row(
                    children: [
                      // Play/View indicator
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spaceS),
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
                          widget.item.type == 'video'
                              ? Icons.play_arrow_rounded
                              : Icons.open_in_new_rounded,
                          color: AppColors.primary,
                          size: AppDimensions.iconS,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceS),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTypeLabel(widget.item.type),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              UIStrings.tapToExplore,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Source badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceS,
                          vertical: AppDimensions.spaceXXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.4),
                          borderRadius: AppDimensions.borderRadiusS,
                        ),
                        child: Text(
                          AppStrings.websiteDomain,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Educational badge
                Positioned(
                  top: AppDimensions.spaceM,
                  left: AppDimensions.spaceM,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
                      vertical: AppDimensions.spaceXXS,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: AppDimensions.borderRadiusS,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: AppColors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          UIStrings.learn,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              color: AppColors.primary.withValues(alpha: 0.5),
              size: AppDimensions.iconXL,
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              UIStrings.imageUnavailable,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return UIStrings.watchVideo;
      case 'custom':
        return UIStrings.interactiveContent;
      default:
        return UIStrings.readArticle;
    }
  }
}
