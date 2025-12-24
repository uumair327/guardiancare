import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final CommentEntity comment;

  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
      elevation: AppDimensions.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusS,
      ),
      child: Padding(
        padding: AppDimensions.paddingAllM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User details
            UserDetailsWidget(userId: comment.userId),
            
            SizedBox(height: AppDimensions.spaceS),
            
            // Comment text
            Text(
              comment.text,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
            ),
            
            SizedBox(height: AppDimensions.spaceS),
            
            // Timestamp
            Text(
              DateFormat('dd MMM yyyy - hh:mm a').format(comment.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
