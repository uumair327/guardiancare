import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';

/// Example implementation of Forum Page using Clean Architecture
/// 
/// This serves as a reference for migrating the existing forum pages
class ForumPageExample extends StatelessWidget {
  final ForumCategory category;

  const ForumPageExample({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForumBloc>()..add(LoadForums(category)),
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
                  backgroundColor: AppColors.error,
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
    super.key,
    required this.forum,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      elevation: AppDimensions.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusM,
      ),
      child: ListTile(
        contentPadding: AppDimensions.listItemPadding,
        title: Text(
          forum.title,
          style: AppTextStyles.h6,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppDimensions.spaceXS),
            Text(
              forum.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppDimensions.spaceXS),
            Text(
              _formatDate(forum.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: AppDimensions.iconS,
          color: AppColors.iconSecondary,
        ),
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
    super.key,
    required this.forum,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForumBloc>()..add(LoadComments(forum.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forum Discussion'),
        ),
        body: Column(
          children: [
            // Forum Header
            Container(
              padding: AppDimensions.paddingAllM,
              color: AppColors.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forum.title,
                    style: AppTextStyles.h4,
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    forum.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            Divider(
              height: AppDimensions.dividerThickness,
              color: AppColors.divider,
            ),

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
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceM,
                        vertical: AppDimensions.spaceS,
                      ),
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                          elevation: AppDimensions.elevation1,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusS,
                          ),
                          child: ListTile(
                            contentPadding: AppDimensions.listItemPadding,
                            title: Text(
                              comment.text,
                              style: AppTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              _formatDate(comment.createdAt),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
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
            const CommentInputWidgetExample(),
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
class CommentInputWidgetExample extends StatefulWidget {
  const CommentInputWidgetExample({super.key});

  @override
  State<CommentInputWidgetExample> createState() => _CommentInputWidgetExampleState();
}

class _CommentInputWidgetExampleState extends State<CommentInputWidgetExample> {
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
            SnackBar(
              content: Text('Comment submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Container(
        padding: AppDimensions.paddingAllS,
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
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
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppDimensions.borderRadiusM,
                    borderSide: BorderSide(
                      color: AppColors.border,
                      width: AppDimensions.borderThin,
                    ),
                  ),
                  contentPadding: AppDimensions.inputPadding,
                ),
                style: AppTextStyles.bodyMedium,
                maxLines: null,
              ),
            ),
            SizedBox(width: AppDimensions.spaceS),
            BlocBuilder<ForumBloc, ForumState>(
              builder: (context, state) {
                final isSubmitting = state is CommentSubmitting;

                return IconButton(
                  icon: isSubmitting
                      ? SizedBox(
                          width: AppDimensions.iconS,
                          height: AppDimensions.iconS,
                          child: CircularProgressIndicator(
                            strokeWidth: AppDimensions.borderMedium,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: AppColors.primary,
                          size: AppDimensions.iconM,
                        ),
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
