import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/home/home.dart';
import 'package:shimmer/shimmer.dart';

class EnhancedCarousel extends StatefulWidget {
  final List<CarouselItemEntity> items;
  final double height;

  const EnhancedCarousel({
    super.key,
    required this.items,
    required this.height,
  });

  @override
  State<EnhancedCarousel> createState() => _EnhancedCarouselState();
}

class _EnhancedCarouselState extends State<EnhancedCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    debugPrint('EnhancedCarousel: Building with ${widget.items.length} items');
    
    if (widget.items.isEmpty) {
      return _buildEmptyCarousel();
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: widget.items.length > 1,
            autoPlay: widget.items.length > 1,
            autoPlayInterval: AppDurations.carouselAutoPlay,
            autoPlayAnimationDuration: AppDurations.animationSlow,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.scale,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
          items: widget.items.map((item) => _buildCarouselItem(item)).toList(),
        ),
        if (widget.items.length > 1) ...[
          SizedBox(height: AppDimensions.spaceM),
          _buildIndicators(),
        ],
      ],
    );
  }

  Widget _buildCarouselItem(CarouselItemEntity item) {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => _handleItemTap(context, item),
          child: ClipRRect(
            borderRadius: AppDimensions.borderRadiusL,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildErrorWidget(),
                ),
                Positioned(
                  bottom: AppDimensions.spaceXS,
                  right: AppDimensions.spaceS,
                  child: Text(
                    'Source: childrenofindia.in',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shadows: [
                        Shadow(
                          offset: const Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: AppColors.black.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => Container(
          width: _currentIndex == index ? 24.0 : 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentIndex == index
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: AppColors.divider,
      child: Center(
        child: Icon(
          Icons.error,
          size: AppDimensions.iconL,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildEmptyCarousel() {
    return SizedBox(
      height: widget.height,
      child: CarouselSlider(
        options: CarouselOptions(
          height: widget.height,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: AppDurations.carouselAutoPlay,
          autoPlayAnimationDuration: AppDurations.animationSlow,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.scale,
          scrollDirection: Axis.horizontal,
        ),
        items: _buildShimmerItems(),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: AppDimensions.borderRadiusL,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: SizedBox(
          width: double.infinity,
          height: widget.height,
        ),
      ),
    );
  }

  List<Widget> _buildShimmerItems() {
    return List.generate(3, (index) => _buildShimmerItem());
  }

  void _handleItemTap(BuildContext context, CarouselItemEntity item) {
    if (item.type == 'custom') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomContentPage(
            content: item.content,
          ),
        ),
      );
    } else {
      context.push('/webview', extra: item.link);
    }
  }
}
