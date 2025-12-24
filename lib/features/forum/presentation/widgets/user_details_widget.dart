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
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          );
        }

        return snapshot.data!.fold(
          (failure) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Unknown User',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          (userDetails) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: userDetails.userImage.isNotEmpty
                    ? NetworkImage(userDetails.userImage)
                    : null,
                backgroundColor: Colors.grey[300],
                child: userDetails.userImage.isEmpty
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userDetails.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      userDetails.userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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
