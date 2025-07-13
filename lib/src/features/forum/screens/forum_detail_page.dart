// lib/src/features/forum/screens/forum_detail_page.dart
import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/controllers/forum_controller.dart';
import 'package:guardiancare/src/features/forum/models/comment.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';
import 'package:guardiancare/src/features/forum/widgets/comment_input.dart';
import 'package:guardiancare/src/features/forum/widgets/reminder_dialog.dart';
import 'package:guardiancare/src/features/forum/widgets/user_details.dart';

import 'package:intl/intl.dart';

class ForumDetailPage extends StatefulWidget {
  final Forum forum;
  const ForumDetailPage({Key? key, required this.forum}) : super(key: key);

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final ForumController _controller = ForumController();
  bool _reminderShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reminderShown) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ReminderDialog(
            onAgree: () => {},
          ),
        );
        _reminderShown = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.forum.title)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.forum.title,
                          style: TextStyle(
                            fontSize: isTablet ? 24.0 : 20.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(239, 72, 53, 1),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yy - hh:mm a')
                              .format(widget.forum.createdAt),
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.forum.description,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: isTablet ? 18.0 : 14.0),
                        ),
                        const Divider(),
                        StreamBuilder<List<Comment>>(
                          stream: _controller.getComments(widget.forum.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            var comments = snapshot.data!;
                            return Column(
                              children: comments.map((comment) {
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(left: 6),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      UserDetails(userId: comment.userId),
                                      const SizedBox(height: 6),
                                      Text(
                                        comment.text,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                  isThreeLine: true,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CommentInput(forumId: widget.forum.id),
            ],
          );
        },
      ),
    );
  }
}
