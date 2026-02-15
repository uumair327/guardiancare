import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/domain/usecases/add_comment.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_comments.dart';
import 'package:guardiancare/features/forum/domain/usecases/get_forums.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_event.dart';
import 'package:guardiancare/features/forum/presentation/bloc/forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  ForumBloc({
    required this.getForums,
    required this.getComments,
    required this.addComment,
    required this.firebaseAuth,
  }) : super(const ForumInitial()) {
    on<LoadForums>(_onLoadForums);
    on<ForumsUpdated>(_onForumsUpdated);
    on<LoadComments>(_onLoadComments);
    on<SubmitComment>(_onSubmitComment);
    on<RefreshForums>(_onRefreshForums);
  }
  final GetForums getForums;
  final GetComments getComments;
  final AddComment addComment;
  final FirebaseAuth firebaseAuth;

  StreamSubscription? _parentForumsSubscription;
  StreamSubscription? _childrenForumsSubscription;

  @override
  Future<void> close() {
    _parentForumsSubscription?.cancel();
    _childrenForumsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadForums(
    LoadForums event,
    Emitter<ForumState> emit,
  ) async {
    Log.d('ForumBloc: Loading forums for category: ${event.category}');

    // Preserve existing state if possible
    final currentState =
        state is ForumsLoaded ? state as ForumsLoaded : const ForumsLoaded();

    if (event.category == ForumCategory.parent) {
      emit(currentState.copyWith(isLoadingParent: true));
      await _parentForumsSubscription?.cancel();
      _parentForumsSubscription =
          getForums(GetForumsParams(category: event.category)).listen(
        (result) => add(ForumsUpdated(result, event.category)),
      );
    } else {
      emit(currentState.copyWith(isLoadingChildren: true));
      await _childrenForumsSubscription?.cancel();
      _childrenForumsSubscription =
          getForums(GetForumsParams(category: event.category)).listen(
        (result) => add(ForumsUpdated(result, event.category)),
      );
    }
  }

  void _onForumsUpdated(
    ForumsUpdated event,
    Emitter<ForumState> emit,
  ) {
    // We should be in ForumsLoaded state or transition to it
    final currentState =
        state is ForumsLoaded ? state as ForumsLoaded : const ForumsLoaded();

    event.result.fold(
      (failure) {
        Log.e('ForumBloc: Error loading forums: ${failure.message}');
        // If it was the first load and we failed, we might want to show error
        // But if we have other data, we might just want to show a snackbar (handled by UI listener?)
        // For now, let's update state to stop loading and maybe set error
        emit(currentState.copyWith(
          isLoadingParent:
              event.category == ForumCategory.parent ? false : null,
          isLoadingChildren:
              event.category == ForumCategory.children ? false : null,
          error: failure.message,
        ));
      },
      (forums) {
        Log.d(
            'ForumBloc: Loaded ${forums.length} forums for ${event.category}');

        if (event.category == ForumCategory.parent) {
          emit(currentState.copyWith(
            parentForums: forums,
            isLoadingParent: false,
          ));
        } else {
          emit(currentState.copyWith(
            childrenForums: forums,
            isLoadingChildren: false,
          ));
        }
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
        parentId: event.parentId,
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
    // Just reload forums for the specific category
    add(LoadForums(event.category));
  }
}
