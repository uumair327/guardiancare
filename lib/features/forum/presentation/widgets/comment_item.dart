import 'package:flutter/material.dart';
import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';
import 'package:guardiancare/features/forum/presentation/widgets/user_details_widget.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final CommentEntity comment;

  const CommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User details
            UserDetailsWidget(userId: comment.userId),
            
            const SizedBox(height: 8),
            
            // Comment text
            Text(
              comment.text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Timestamp
            Text(
              DateFormat('dd MMM yyyy - hh:mm a').format(comment.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
