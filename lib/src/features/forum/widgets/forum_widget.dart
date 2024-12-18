import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';
import 'package:guardiancare/src/features/forum/screens/forum_detail_page.dart';
import 'package:intl/intl.dart';

class ForumWidget extends StatelessWidget {
  final Forum forum;

  const ForumWidget({super.key, required this.forum});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForumDetailPage(forum: forum),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 30),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                forum.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(239, 72, 53, 1),
                ),
              ),
              Text(
                DateFormat('dd MMM yy - hh:mm a').format(forum.createdAt),
              ),
              const SizedBox(height: 10),
              Text(
                forum.description,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
