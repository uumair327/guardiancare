import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';

class ContentCard extends StatelessWidget{
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/video-player', extra: description),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: AppDimensions.spaceM, vertical: AppDimensions.spaceS),
        elevation: AppDimensions.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail with error handling
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: AppColors.shimmerBase,
                        child: const Center(
                          child: CircularProgressIndicator(),
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
            // Title
            Padding(
              padding: AppDimensions.paddingAllM,
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
