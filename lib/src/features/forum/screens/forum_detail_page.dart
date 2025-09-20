// lib/src/features/forum/screens/forum_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/core/di/dependency_injection.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_bloc.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_event.dart';
import 'package:guardiancare/src/features/forum/bloc/comment_state.dart';
import 'package:guardiancare/src/features/forum/models/comment.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';
import 'package:guardiancare/src/features/forum/widgets/comment_input.dart';
import 'package:guardiancare/src/features/forum/widgets/reminder_dialog.dart';
import 'package:guardiancare/src/features/forum/widgets/user_details.dart';
import 'package:intl/intl.dart';

class ForumDetailPage extends StatelessWidget {
  final Forum forum;

  const ForumDetailPage({super.key, required this.forum});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.get<CommentBloc>()
        ..add(CommentLoadRequested(forum.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(forum.title),
        ),
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
                            forum.title,
                            style: TextStyle(
                              fontSize: isTablet ? 24.0 : 20.0,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(239, 72, 53, 1),
                            ),
                          ),
                          Text(
                            DateFormat('dd MMM yy - hh:mm a')
                                .format(forum.createdAt),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            forum.description,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: isTablet ? 18.0 : 14.0),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          // In-App Reminder
                          const ReminderWidget(),
                          const SizedBox(height: 10),
                          BlocBuilder<CommentBloc, CommentState>(
                            builder: (context, state) {
                              if (state is CommentLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (state is CommentLoaded) {
                                final comments = state.comments;
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
                              } else if (state is CommentError) {
                                return Center(
                                  child: Text('Error: ${state.message}'),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: CommentInput(forumId: forum.id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ReminderWidget extends StatefulWidget {
  const ReminderWidget({super.key});

  @override
  State<ReminderWidget> createState() => _ReminderWidgetState();
}

class _ReminderWidgetState extends State<ReminderWidget> {
  bool _isReminderShown = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowReminder();
  }

  Future<void> _checkAndShowReminder() async {
    // Implement your logic to determine if the user is a child.
    // For demonstration, we'll assume all users are children.
    bool isChildUser = true;

    if (isChildUser && !_isReminderShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ReminderDialog(
            onAgree: () {
              // You can add additional actions here if needed
            },
          ),
        );
      });
      setState(() {
        _isReminderShown = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder, as the dialog handles the reminder
  }
}
