import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/forum_service.dart';

class UserDetails extends StatelessWidget {
  final String userId;
  final ForumService _service = ForumService();

  UserDetails({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _service.fetchUserDetails(userId),
      builder: (c, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final u = snap.data!;
        return Row(
          children: [
            CircleAvatar(
              backgroundImage: u['userImage']!.isNotEmpty
                  ? NetworkImage(u['userImage']!)
                  : null,
              child: u['userImage']!.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u['userName']!,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(u['userEmail']!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        );
      },
    );
  }
}
