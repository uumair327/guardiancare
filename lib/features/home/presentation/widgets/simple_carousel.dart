import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:shimmer/shimmer.dart';

class SimpleCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> carouselData;
  final double carouselHeight;

  const SimpleCarousel({
    super.key,
    required this.carouselData,
    required this.carouselHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: carouselHeight,
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
      items: carouselData.isEmpty
          ? _buildShimmerItems()
          : carouselData.map((item) {
              final imageUrl = item['imageUrl'];
              final link = item['link'];

              if (imageUrl == null || link == null) {
                return _buildShimmerItem();
              }

              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      final type = item['type'] ?? 'web';
                      if (type == 'custom') {
                        // For custom content, navigate to a custom page
                        // You may need to add a route for this in app_router.dart
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomContentPage(
                              content: item['content'] ?? {},
                            ),
                          ),
                        );
                      } else {
                        context.push('/webview', extra: link);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: AppDimensions.borderRadiusL,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          Positioned(
                            bottom: AppDimensions.spaceXS,
                            right: AppDimensions.spaceS,
                            child: Text(
                              "Source: childrenofindia.in",
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
            }).toList(),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.spaceS),
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: AppDimensions.borderRadiusM,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: SizedBox(
          width: double.infinity,
          height: carouselHeight,
        ),
      ),
    );
  }

  List<Widget> _buildShimmerItems() {
    return List.generate(5, (index) => _buildShimmerItem());
  }
}
