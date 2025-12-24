import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/forum/forum.dart';

class ForumDetailPage extends StatelessWidget {
  final String forumId;
  final String forumTitle;

  const ForumDetailPage({
    super.key,
    required this.forumId,
    required this.forumTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForumBloc>()..add(LoadComments(forumId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(forumTitle),
        ),
        body: SafeArea(
          child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ForumBloc, ForumState>(
                listener: (context, state) {
                  if (state is ForumError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        duration: AppDurations.snackbarMedium,
                      ),
                    );
                  } else if (state is CommentSubmitted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Comment posted successfully!'),
                        backgroundColor: AppColors.success,
                        duration: AppDurations.snackbarShort,
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
                              size: AppDimensions.iconXXL,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppDimensions.spaceM),
                            Text(
                              'No comments yet',
                              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
                            ),
                            SizedBox(height: AppDimensions.spaceS),
                            Text(
                              'Be the first to comment!',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ForumBloc>().add(LoadComments(forumId));
                        await Future.delayed(AppDurations.animationMedium);
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceM,
                          vertical: AppDimensions.spaceS,
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
      ),
    );
  }
}
