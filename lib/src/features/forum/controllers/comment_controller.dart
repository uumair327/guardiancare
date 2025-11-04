import 'package:flutter/foundation.dart';
import 'package:guardiancare/src/features/forum/forum_service.dart';
import 'package:guardiancare/src/features/forum/services/comment_submission_service.dart';

/// Enhanced comment controller with improved state management
class CommentController extends ChangeNotifier {
  final ForumService _service = ForumService();
  final CommentSubmissionService _submissionService = CommentSubmissionService.instance;
  
  // Track submission states for different comments/posts
  final Map<String, CommentSubmissionState> _submissionStates = {};
  
  // Track active submissions to prevent duplicates
  final Set<String> _activeSubmissions = {};
  
  // Track submission history for retry logic
  final Map<String, List<CommentSubmissionAttempt>> _submissionHistory = {};

  /// Get submission state for a specific post/comment
  CommentSubmissionState getSubmissionState(String postId) {
    return _submissionStates[postId] ?? CommentSubmissionState.idle();
  }

  /// Check if a submission is currently active for a post
  bool isSubmissionActive(String postId) {
    return _activeSubmissions.contains(postId);
  }

  /// Get submission history for a post
  List<CommentSubmissionAttempt> getSubmissionHistory(String postId) {
    return _submissionHistory[postId] ?? [];
  }

  /// Add a comment with enhanced state management
  Future<CommentSubmissionResult> addComment(
    String forumId, 
    String text, {
    String? parentCommentId,
    Map<String, dynamic>? metadata,
  }) async {
    final submissionKey = _generateSubmissionKey(forumId, parentCommentId);
    
    // Prevent duplicate submissions
    if (_activeSubmissions.contains(submissionKey)) {
      return CommentSubmissionResult.failure(
        'A comment submission is already in progress',
        CommentSubmissionErrorType.validation,
      );
    }

    // Set submission state to loading
    _setSubmissionState(submissionKey, CommentSubmissionState.loading());
    _activeSubmissions.add(submissionKey);

    try {
      // Use the enhanced submission service
      final result = await _submissionService.submitComment(
        content: text,
        postId: forumId,
        userId: 'current_user_id', // In real app, get from auth service
        parentCommentId: parentCommentId,
        metadata: metadata,
      );

      // Record submission attempt
      _recordSubmissionAttempt(submissionKey, result);

      if (result.success) {
        // Set success state
        _setSubmissionState(submissionKey, CommentSubmissionState.success(
          message: result.message,
          commentId: result.commentId!,
        ));
        
        // Also call the original service for backward compatibility
        await _service.addComment(forumId, text);
        
      } else {
        // Set error state
        _setSubmissionState(submissionKey, CommentSubmissionState.error(
          message: result.message,
          errorType: result.errorType!,
          canRetry: _canRetrySubmission(result.errorType!),
        ));
      }

      return result;

    } catch (e) {
      // Handle unexpected errors
      final errorResult = CommentSubmissionResult.failure(
        'Unexpected error: ${e.toString()}',
        CommentSubmissionErrorType.network,
      );
      
      _recordSubmissionAttempt(submissionKey, errorResult);
      _setSubmissionState(submissionKey, CommentSubmissionState.error(
        message: errorResult.message,
        errorType: errorResult.errorType!,
        canRetry: true,
      ));

      return errorResult;

    } finally {
      _activeSubmissions.remove(submissionKey);
      
      // Clear success/error state after a delay
      Future.delayed(const Duration(seconds: 3), () {
        _clearSubmissionState(submissionKey);
      });
    }
  }

  /// Retry a failed comment submission
  Future<CommentSubmissionResult> retryComment(
    String forumId,
    String text, {
    String? parentCommentId,
    Map<String, dynamic>? metadata,
  }) async {
    final submissionKey = _generateSubmissionKey(forumId, parentCommentId);
    final currentState = getSubmissionState(submissionKey);
    
    if (currentState.status != CommentSubmissionStatus.error || !currentState.canRetry) {
      return CommentSubmissionResult.failure(
        'Cannot retry this submission',
        CommentSubmissionErrorType.validation,
      );
    }

    return await addComment(
      forumId,
      text,
      parentCommentId: parentCommentId,
      metadata: metadata,
    );
  }

  /// Cancel an active submission
  void cancelSubmission(String postId, {String? parentCommentId}) {
    final submissionKey = _generateSubmissionKey(postId, parentCommentId);
    
    if (_activeSubmissions.contains(submissionKey)) {
      _activeSubmissions.remove(submissionKey);
      _setSubmissionState(submissionKey, CommentSubmissionState.cancelled());
      
      // Clear cancelled state after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        _clearSubmissionState(submissionKey);
      });
    }
  }

  /// Clear submission state for a specific post
  void clearSubmissionState(String postId, {String? parentCommentId}) {
    final submissionKey = _generateSubmissionKey(postId, parentCommentId);
    _clearSubmissionState(submissionKey);
  }

  /// Clear all submission states
  void clearAllSubmissionStates() {
    _submissionStates.clear();
    _activeSubmissions.clear();
    notifyListeners();
  }

  /// Get submission statistics
  CommentSubmissionStats getSubmissionStats() {
    int totalAttempts = 0;
    int successfulAttempts = 0;
    int failedAttempts = 0;
    
    for (final attempts in _submissionHistory.values) {
      totalAttempts += attempts.length;
      successfulAttempts += attempts.where((a) => a.result.success).length;
      failedAttempts += attempts.where((a) => !a.result.success).length;
    }
    
    return CommentSubmissionStats(
      totalSubmissions: totalAttempts,
      successfulSubmissions: successfulAttempts,
      failedSubmissions: failedAttempts,
      averageRetryCount: totalAttempts > 0 ? failedAttempts / totalAttempts : 0.0,
      lastSubmissionTime: _getLastSubmissionTime(),
    );
  }

  /// Generate a unique key for tracking submissions
  String _generateSubmissionKey(String postId, String? parentCommentId) {
    return parentCommentId != null ? '${postId}_$parentCommentId' : postId;
  }

  /// Set submission state and notify listeners
  void _setSubmissionState(String key, CommentSubmissionState state) {
    _submissionStates[key] = state;
    notifyListeners();
  }

  /// Clear submission state and notify listeners
  void _clearSubmissionState(String key) {
    _submissionStates.remove(key);
    notifyListeners();
  }

  /// Record a submission attempt for history tracking
  void _recordSubmissionAttempt(String key, CommentSubmissionResult result) {
    _submissionHistory.putIfAbsent(key, () => []);
    _submissionHistory[key]!.add(CommentSubmissionAttempt(
      timestamp: DateTime.now(),
      result: result,
    ));
    
    // Keep only the last 10 attempts per key
    if (_submissionHistory[key]!.length > 10) {
      _submissionHistory[key]!.removeAt(0);
    }
  }

  /// Check if a submission can be retried based on error type
  bool _canRetrySubmission(CommentSubmissionErrorType errorType) {
    switch (errorType) {
      case CommentSubmissionErrorType.network:
      case CommentSubmissionErrorType.server:
      case CommentSubmissionErrorType.timeout:
        return true;
      case CommentSubmissionErrorType.validation:
      case CommentSubmissionErrorType.authentication:
      case CommentSubmissionErrorType.permission:
        return false;
    }
  }

  /// Get the timestamp of the last submission
  DateTime? _getLastSubmissionTime() {
    DateTime? lastTime;
    
    for (final attempts in _submissionHistory.values) {
      for (final attempt in attempts) {
        if (lastTime == null || attempt.timestamp.isAfter(lastTime)) {
          lastTime = attempt.timestamp;
        }
      }
    }
    
    return lastTime;
  }

  @override
  void dispose() {
    _submissionStates.clear();
    _activeSubmissions.clear();
    _submissionHistory.clear();
    super.dispose();
  }
}

/// State of a comment submission
class CommentSubmissionState {
  final CommentSubmissionStatus status;
  final String? message;
  final String? commentId;
  final CommentSubmissionErrorType? errorType;
  final bool canRetry;
  final DateTime timestamp;

  CommentSubmissionState._({
    required this.status,
    this.message,
    this.commentId,
    this.errorType,
    this.canRetry = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory CommentSubmissionState.idle() {
    return CommentSubmissionState._(status: CommentSubmissionStatus.idle);
  }

  factory CommentSubmissionState.loading() {
    return CommentSubmissionState._(status: CommentSubmissionStatus.loading);
  }

  factory CommentSubmissionState.success({
    required String message,
    required String commentId,
  }) {
    return CommentSubmissionState._(
      status: CommentSubmissionStatus.success,
      message: message,
      commentId: commentId,
    );
  }

  factory CommentSubmissionState.error({
    required String message,
    required CommentSubmissionErrorType errorType,
    bool canRetry = false,
  }) {
    return CommentSubmissionState._(
      status: CommentSubmissionStatus.error,
      message: message,
      errorType: errorType,
      canRetry: canRetry,
    );
  }

  factory CommentSubmissionState.cancelled() {
    return CommentSubmissionState._(
      status: CommentSubmissionStatus.cancelled,
      message: 'Submission cancelled',
    );
  }

  bool get isLoading => status == CommentSubmissionStatus.loading;
  bool get isSuccess => status == CommentSubmissionStatus.success;
  bool get isError => status == CommentSubmissionStatus.error;
  bool get isCancelled => status == CommentSubmissionStatus.cancelled;
  bool get isIdle => status == CommentSubmissionStatus.idle;

  @override
  String toString() {
    return 'CommentSubmissionState{status: $status, message: $message, canRetry: $canRetry}';
  }
}

/// Status of comment submission
enum CommentSubmissionStatus {
  idle,
  loading,
  success,
  error,
  cancelled,
}

/// Record of a submission attempt
class CommentSubmissionAttempt {
  final DateTime timestamp;
  final CommentSubmissionResult result;

  CommentSubmissionAttempt({
    required this.timestamp,
    required this.result,
  });

  @override
  String toString() {
    return 'CommentSubmissionAttempt{timestamp: $timestamp, success: ${result.success}}';
  }
}
