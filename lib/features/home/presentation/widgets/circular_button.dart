import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Circular button widget for home page actions
/// Deprecated: Use ActionCard instead for better UI consistency
@Deprecated('Use ActionCard widget instead')
class CircularButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  const CircularButton({
    super.key,
    required this.iconData,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppDimensions.buttonCircularSize / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppDimensions.buttonCircularSize,
            height: AppDimensions.buttonCircularSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              iconData,
              color: AppColors.white,
              size: AppDimensions.iconL,
            ),
          ),
          SizedBox(height: AppDimensions.spaceS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
