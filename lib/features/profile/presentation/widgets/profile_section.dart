import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// Section container for profile page
/// Groups related menu items with a title
class ProfileSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets? padding;

  const ProfileSection({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH,
                vertical: AppDimensions.spaceS,
              ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: AppDimensions.iconS,
                ),
                SizedBox(width: AppDimensions.spaceS),
              ],
              Text(
                title,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spaceS),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: Column(
            children: children.map((child) {
              final index = children.indexOf(child);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < children.length - 1
                      ? AppDimensions.spaceS
                      : 0,
                ),
                child: child,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
