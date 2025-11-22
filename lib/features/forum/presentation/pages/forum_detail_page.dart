import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_event.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_state.dart';
import 'package:guardiancare/features/forum/presentation/widgets/comment_item.dart';
import 'package:guardiancare/features/forum/presentation/widgets/comment_input_widget.dart';
import 'package:intl/intl.dart';

class ForumDetailPage extends StatelessWidget {
  final String forumId;
  final String forumTitle;

  const ForumDetailPage({
    Key? key,
    required this.forumId,
    required this.forumTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ForumBloc>()..add(LoadComments(forumId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(forumTitle),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ForumBloc, ForumState>(
                listener: (context, state) {
                  if (state is ForumError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else if (state is CommentSubmitted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment posted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                buildWhen: (previous, current) {
                  // Only rebuild for states related to comments
                  return current is ForumLoading ||
                      current is CommentsLoaded ||
                      current is ForumError;
                },
                builder: (context, state) {
                  if (state is ForumLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is CommentsLoaded && state.forumId == forumId) {
                    if (state.comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ForumBloc>().add(LoadComments(forumId));
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          return CommentItem(
                            comment: state.comments[index],
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Pull to refresh'),
                  );
                },
              ),
            ),
            CommentInputWidget(forumId: forumId),
          ],
        ),
      ),
    );
  }
}
