import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';
import 'package:intl/intl.dart';

class ForumListItem extends StatelessWidget {
  final ForumEntity forum;

  const ForumListItem({super.key, required this.forum});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final forumData = {
          'title': forum.title,
          'description': forum.description,
          'createdAt': forum.createdAt.toIso8601String(),
        };
        context.push('/forum/${forum.id}', extra: forumData);
      },
      child: Card(
        elevation: AppDimensions.elevationS,
        margin: EdgeInsets.symmetric(horizontal: AppDimensions.spaceM, vertical: AppDimensions.spaceS),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: Container(
          padding: AppDimensions.paddingAllM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      forum.title,
                      style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                DateFormat('dd MMM yyyy - hh:mm a').format(forum.createdAt),
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppDimensions.spaceM),
              Text(
                forum.description,
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
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
