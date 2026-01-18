import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';

class UserDetailsWidget extends StatelessWidget {
  final String userId;

  const UserDetailsWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<GetUserDetails>()(GetUserDetailsParams(userId: userId)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.iconXS,
                backgroundColor: context.colors.border,
                child: Icon(Icons.person, size: AppDimensions.iconXS),
              ),
              SizedBox(width: AppDimensions.spaceS),
              Text(
                'Loading...',
                style: AppTextStyles.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          );
        }

        return snapshot.data!.fold(
          (failure) => Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.iconXS,
                backgroundColor: context.colors.border,
                child: Icon(Icons.person, size: AppDimensions.iconXS),
              ),
              SizedBox(width: AppDimensions.spaceS),
              Text(
                'Unknown User',
                style: AppTextStyles.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          (userDetails) => Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.iconXS,
                backgroundImage: userDetails.userImage.isNotEmpty
                    ? NetworkImage(userDetails.userImage)
                    : null,
                backgroundColor: context.colors.border,
                child: userDetails.userImage.isEmpty
                    ? Icon(Icons.person, size: AppDimensions.iconXS)
                    : null,
              ),
              SizedBox(width: AppDimensions.spaceS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userDetails.userName,
                      style: AppTextStyles.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      userDetails.userEmail,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
