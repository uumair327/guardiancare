import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/home/home.dart';
import 'package:shimmer/shimmer.dart';

class HomeCarouselWidget extends StatelessWidget {
  const HomeCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.25;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is CarouselItemsLoaded) {
          final items = state.items;
          
          if (items.isEmpty) {
            return _buildShimmerCarousel(carouselHeight);
          }

          return CarouselSlider(
            options: CarouselOptions(
              height: carouselHeight,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: items.length > 1,
              autoPlay: items.length > 1,
              autoPlayInterval: AppDurations.carouselAutoPlay,
              autoPlayAnimationDuration: AppDurations.animationSlow,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              scrollDirection: Axis.horizontal,
            ),
            items: items.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
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
                    },
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
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.divider,
                              child: Icon(
                                Icons.error,
                                color: AppColors.error,
                                size: AppDimensions.iconL,
                              ),
                            ),
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
            }).toList(),
          );
        } else if (state is HomeError) {
          return _buildErrorCarousel(carouselHeight, state.message);
        } else {
          // HomeLoading or HomeInitial
          return _buildShimmerCarousel(carouselHeight);
        }
      },
    );
  }

  Widget _buildShimmerCarousel(double height) {
    return CarouselSlider(
      options: CarouselOptions(
        height: height,
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
      items: List.generate(3, (index) => _buildShimmerItem()),
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
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: AppDimensions.borderRadiusL,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCarousel(double height, String message) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(color: AppColors.error, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: AppDimensions.iconXL,
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                'Failed to load content',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceXS),
              Text(
                message,
                style: AppTextStyles.body2.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
