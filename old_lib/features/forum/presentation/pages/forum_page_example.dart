import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_bloc.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_event.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_state.dart';

/// Example implementation of Forum Page using Clean Architecture
/// 
/// This serves as a reference for migrating the existing forum pages
class ForumPageExample extends StatelessWidget {
  final ForumCategory category;

  const ForumPageExample({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ForumBloc>()..add(LoadForums(category)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            category == ForumCategory.parent
                ? 'Parent Forums'
                : 'Children Forums',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ForumBloc>().add(RefreshForums(category));
              },
            ),
          ],
        ),
        body: BlocConsumer<ForumBloc, ForumState>(
          listener: (context, state) {
            if (state is ForumError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ForumLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ForumsLoaded) {
              if (state.forums.isEmpty) {
                return const Center(
                  child: Text('No forums available'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ForumBloc>().add(RefreshForums(category));
                },
                child: ListView.builder(
                  itemCount: state.forums.length,
                  itemBuilder: (context, index) {
                    final forum = state.forums[index];
                    return ForumCard(forum: forum);
                  },
                ),
              );
            }

            return const Center(
              child: Text('Something went wrong'),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to create forum page
            // Navigator.push(context, MaterialPageRoute(...));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Example Forum Card Widget
class ForumCard extends StatelessWidget {
  final ForumEntity forum;

  const ForumCard({
    Key? key,
    required this.forum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          forum.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              forum.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(forum.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to forum detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumDetailPageExample(forum: forum),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Example Forum Detail Page with Comments
class ForumDetailPageExample extends StatelessWidget {
  final ForumEntity forum;

  const ForumDetailPageExample({
    Key? key,
    required this.forum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ForumBloc>()..add(LoadComments(forum.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forum Discussion'),
        ),
        body: Column(
          children: [
            // Forum Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forum.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(forum.description),
                ],
              ),
            ),
            const Divider(height: 1),

            // Comments List
            Expanded(
              child: BlocBuilder<ForumBloc, ForumState>(
                builder: (context, state) {
                  if (state is ForumLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CommentsLoaded) {
                    if (state.comments.isEmpty) {
                      return const Center(
                        child: Text('No comments yet. Be the first to comment!'),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        return ListTile(
                          title: Text(comment.text),
                          subtitle: Text(
                            _formatDate(comment.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(child: Text('Something went wrong'));
                },
              ),
            ),

            // Comment Input
            const CommentInputWidget(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Example Comment Input Widget
class CommentInputWidget extends StatefulWidget {
  const CommentInputWidget({Key? key}) : super(key: key);

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment(BuildContext context, String forumId) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ForumBloc>().add(
          SubmitComment(forumId: forumId, text: text),
        );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is CommentSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            BlocBuilder<ForumBloc, ForumState>(
              builder: (context, state) {
                final isSubmitting = state is CommentSubmitting;

                return IconButton(
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: isSubmitting
                      ? null
                      : () {
                          // Get forumId from the current context
                          // This is simplified - in real implementation,
                          // you'd pass forumId through the widget tree
                          final forumId = 'forum_id_here';
                          _submitComment(context, forumId);
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
