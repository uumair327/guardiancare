import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/home/home.dart';

class CarouselSection extends StatelessWidget {
  final HomeState state;

  const CarouselSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight * 0.25;

    // Debug: Print current state
    debugPrint('CarouselSection - Current state: ${state.runtimeType}');
    
    // Convert entity data to Map format for SimpleCarousel
    List<Map<String, dynamic>> carouselData = [];
    
    if (state is CarouselItemsLoaded) {
      final items = (state as CarouselItemsLoaded).items;
      debugPrint('CarouselSection - Items count: ${items.length}');
      
      carouselData = items.map((item) {
        return {
          'type': item.type,
          'imageUrl': item.imageUrl,
          'link': item.link,
          'thumbnailUrl': item.thumbnailUrl,
          'content': item.content,
        };
      }).toList();
    }

    return Container(
      margin: EdgeInsets.only(top: AppDimensions.spaceM),
      child: Column(
        children: [
          if (state is HomeError)
            _buildErrorCarousel(carouselHeight, (state as HomeError).message)
          else
            SimpleCarousel(
              carouselData: carouselData,
              carouselHeight: carouselHeight,
            ),
        ],
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
