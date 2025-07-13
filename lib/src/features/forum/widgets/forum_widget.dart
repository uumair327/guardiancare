import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';
import 'package:guardiancare/src/features/forum/screens/forum_detail_page.dart';
import 'package:intl/intl.dart';

class ForumWidget extends StatelessWidget {
  final Forum forum;

  const ForumWidget({Key? key, required this.forum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ForumDetailPage(forum: forum)),
      ),
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
              const SizedBox(height: 10),
              Text(
                DateFormat('dd MMM yy - hh:mm a').format(forum.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
