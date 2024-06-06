import "package:flutter/material.dart";
import "package:guardiancare/src/models/Forum.dart";
import "package:intl/intl.dart";

class ForumWidget extends StatelessWidget {
  final Forum forum;
  const ForumWidget({Key? key, required this.forum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child : Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(forum.title, style: const TextStyle(
                    fontSize: 24.0, 
                    fontWeight: FontWeight.bold, 
                    color: Color.fromRGBO(239, 72, 53,1), 
                  ),
                ),
              Text(DateFormat('dd MMM yy hh:mm a').format(forum.createdAt)),
              const SizedBox(height: 10),
              Text(forum.description),
            ],
          )
        ],
      )
    );
  }
}