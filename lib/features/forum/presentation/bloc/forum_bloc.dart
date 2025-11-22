import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiancare/features/forum/domain/usecases/add_comment.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_comments.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_forums.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_event.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final GetForums getForums;
  final GetComments getComments;
  final AddComment addComment;
  final FirebaseAuth firebaseAuth;

  ForumBloc({
    required this.getForums,
    required this.getComments,
    required this.addComment,
    required this.firebaseAuth,
  }) : super(const ForumInitial()) {
    on<LoadForums>(_onLoadForums);
    on<LoadComments>(_onLoadComments);
    on<SubmitComment>(_onSubmitComment);
    on<RefreshForums>(_onRefreshForums);
  }

  Future<void> _onLoadForums(
    LoadForums event,
    Emitter<ForumState> emit,
  ) async {
    print('ForumBloc: Loading forums for category: ${event.category}');
    emit(const ForumLoading());

    await emit.forEach<dynamic>(
      getForums(GetForumsParams(category: event.category)),
      onData: (result) {
        return result.fold(
          (failure) {
            print('ForumBloc: Error loading forums: ${failure.message}');
            return ForumError(failure.message, code: failure.code);
          },
          (forums) {
            print('ForumBloc: Loaded ${forums.length} forums for ${event.category}');
            return ForumsLoaded(forums, event.category);
          },
        );
      },
      onError: (error, stackTrace) {
        print('ForumBloc: Stream error: $error');
        return ForumError('Stream error: ${error.toString()}');
      },
    );
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<ForumState> emit,
  ) async {
    emit(const ForumLoading());

    await emit.forEach<dynamic>(
      getComments(GetCommentsParams(forumId: event.forumId)),
      onData: (result) {
        return result.fold(
          (failure) => ForumError(failure.message, code: failure.code),
          (comments) => CommentsLoaded(comments, event.forumId),
        );
      },
      onError: (error, stackTrace) {
        return ForumError('Stream error: ${error.toString()}');
      },
    );
  }

  Future<void> _onSubmitComment(
    SubmitComment event,
    Emitter<ForumState> emit,
  ) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const ForumError('User not authenticated'));
      return;
    }

    emit(const CommentSubmitting());

    final result = await addComment(
      AddCommentParams(
        forumId: event.forumId,
        text: event.text,
        userId: currentUser.uid,
      ),
    );

    result.fold(
      (failure) => emit(ForumError(failure.message, code: failure.code)),
      (_) {
        emit(const CommentSubmitted());
        // Reload comments after successful submission
        add(LoadComments(event.forumId));
      },
    );
  }

  Future<void> _onRefreshForums(
    RefreshForums event,
    Emitter<ForumState> emit,
  ) async {
    // Just reload forums - the stream will handle the update
    add(LoadForums(event.category));
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
