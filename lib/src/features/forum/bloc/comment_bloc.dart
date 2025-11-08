import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/src/features/forum/services/comment_submission_service.dart';
import 'package:guardiancare/src/services/forum_service.dart';

// Events
abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadComments extends CommentEvent {
  final String postId;

  const LoadComments(this.postId);

  @override
  List<Object?> get props => [postId];
}

class SubmitComment extends CommentEvent {
  final String postId;
  final String content;

  const SubmitComment(this.postId, this.content);

  @override
  List<Object?> get props => [postId, content];
}

class DeleteComment extends CommentEvent {
  final String commentId;

  const DeleteComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class RefreshComments extends CommentEvent {
  final String postId;

  const RefreshComments(this.postId);

  @override
  List<Object?> get props => [postId];
}

// State
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {
  const CommentInitial();
}

class CommentLoading extends CommentState {
  const CommentLoading();
}

class CommentLoaded extends CommentState {
  final List<Map<String, dynamic>> comments;
  final String postId;

  const CommentLoaded(this.comments, this.postId);

  @override
  List<Object?> get props => [comments, postId];
}

class CommentSubmitting extends CommentState {
  const CommentSubmitting();
}

class CommentSubmitted extends CommentState {
  final String commentId;

  const CommentSubmitted(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class CommentError extends CommentState {
  final String message;
  final String? errorCode;

  const CommentError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// BLoC
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final ForumService _service = ForumService();
  final CommentSubmissionService _submissionService = CommentSubmissionService.instance;

  CommentBloc() : super(const CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<SubmitComment>(_onSubmitComment);
    on<DeleteComment>(_onDeleteComment);
    on<RefreshComments>(_onRefreshComments);
  }

  Future<void> _onLoadComments(LoadComments event, Emitter<CommentState> emit) async {
    emit(const CommentLoading());
    try {
      final comments = await _service.getComments(event.postId);
      emit(CommentLoaded(comments, event.postId));
    } catch (e) {
      emit(CommentError('Failed to load comments: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitComment(SubmitComment event, Emitter<CommentState> emit) async {
    emit(const CommentSubmitting());
    try {
      final result = await _submissionService.submitComment(
        postId: event.postId,
        content: event.content,
      );

      if (result.success) {
        emit(CommentSubmitted(result.commentId!));
        // Reload comments after successful submission
        add(LoadComments(event.postId));
      } else {
        emit(CommentError(
          result.errorMessage ?? 'Failed to submit comment',
          errorCode: result.errorType?.toString(),
        ));
      }
    } catch (e) {
      emit(CommentError('Failed to submit comment: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteComment(DeleteComment event, Emitter<CommentState> emit) async {
    try {
      await _service.deleteComment(event.commentId);
      // Reload comments after deletion if we have a current post
      if (state is CommentLoaded) {
        final currentState = state as CommentLoaded;
        add(LoadComments(currentState.postId));
      }
    } catch (e) {
      emit(CommentError('Failed to delete comment: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshComments(RefreshComments event, Emitter<CommentState> emit) async {
    try {
      final comments = await _service.getComments(event.postId);
      emit(CommentLoaded(comments, event.postId));
    } catch (e) {
      emit(CommentError('Failed to refresh comments: ${e.toString()}'));
    }
  }
}
