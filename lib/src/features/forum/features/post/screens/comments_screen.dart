import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardiancare/src/features/forum/core/common/error_text.dart';
import 'package:guardiancare/src/features/forum/core/common/loader.dart';
import 'package:guardiancare/src/features/forum/core/common/post_card.dart';
import 'package:guardiancare/src/features/forum/features/auth/controlller/auth_controller.dart';
import 'package:guardiancare/src/features/forum/features/post/controller/post_controller.dart';
import 'package:guardiancare/src/features/forum/features/post/widgets/comment_card.dart';
import 'package:guardiancare/src/features/forum/models/post_model.dart';
import 'package:guardiancare/src/features/forum/responsive/responsive.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  if (!isGuest)
                    Responsive(
                      child: TextField(
                        onSubmitted: (val) => addComment(data),
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'What are your thoughts?',
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ref.watch(getPostCommentsProvider(widget.postId)).when(
                        data: (data) {
                          return Expanded(
                            child: ListView.separated(
                                itemCount: data.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(),
                                itemBuilder: (BuildContext context, int index) {
                                  final comment = data[index];
                                  return DelayedDisplay(
                                      delay: Duration(milliseconds: 5 * index),
                                      child: CommentCard(comment: comment));
                                }),
                          );
                        },
                        error: (error, stackTrace) {
                          return ErrorText(
                            error: error.toString(),
                          );
                        },
                        loading: () => const Loader(),
                      ),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
