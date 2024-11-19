import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/forum/forum_service.dart';

class UserDetails extends StatelessWidget {
  final String userId;
  final ForumService _forumService = ForumService();

  UserDetails({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _forumService.fetchUserDetails(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var user = snapshot.data!;
        return Row(
          children: [
            CircleAvatar(
              backgroundImage: user['userImage']!.isNotEmpty
                  ? NetworkImage(user['userImage']!)
                  : null,
              child:
                  user['userImage']!.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['userName']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: tPrimaryColor,
                  ),
                ),
                Text(
                  user['userEmail']!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
