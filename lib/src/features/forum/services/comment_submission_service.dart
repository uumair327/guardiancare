import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Service for handling comment submissions with retry logic and validation
class CommentSubmissionService {
  static const int _maxRetryAttempts = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static const Duration _maxRetryDelay = Duration(seconds: 10);
  
  static CommentSubmissionService? _instance;
  
  CommentSubmissionService._();
  
  /// Get singleton instance
  static CommentSubmissionService get instance {
    _instance ??= CommentSubmissionService._();
    return _instance!;
  }

  /// Submit a comment with retry logic and validation
  Future<CommentSubmissionResult> submitComment({
    required String content,
    required String postId,
    required String userId,
    String? parentCommentId,
    Map<String, dynamic>? metadata,
  }) async {
    // Validate comment content
    final validationResult = _validateComment(content);
    if (!validationResult.isValid) {
      return CommentSubmissionResult.failure(
        validationResult.errorMessage!,
        CommentSubmissionErrorType.validation,
      );
    }

    // Prepare comment data
    final commentData = CommentData(
      content: content.trim(),
      postId: postId,
      userId: userId,
      parentCommentId: parentCommentId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );

    // Attempt submission with retry logic
    return await _submitWithRetry(commentData);
  }

  /// Submit comment with exponential backoff retry logic
  Future<CommentSubmissionResult> _submitWithRetry(CommentData commentData) async {
    int attemptCount = 0;
    Duration currentDelay = _baseRetryDelay;
    
    while (attemptCount < _maxRetryAttempts) {
      attemptCount++;
      
      try {
        print('CommentSubmissionService: Attempt $attemptCount of $_maxRetryAttempts');
        
        final result = await _performSubmission(commentData);
        
        if (result.success) {
          print('CommentSubmissionService: Comment submitted successfully on attempt $attemptCount');
          return result;
        }
        
        // If this was the last attempt, return the failure
        if (attemptCount >= _maxRetryAttempts) {
          print('CommentSubmissionService: All retry attempts exhausted');
          return result;
        }
        
        // Check if error is retryable
        if (!_isRetryableError(result.errorType)) {
          print('CommentSubmissionService: Non-retryable error: ${result.errorType}');
          return result;
        }
        
        // Wait before retrying with exponential backoff
        print('CommentSubmissionService: Retrying in ${currentDelay.inSeconds} seconds...');
        await Future.delayed(currentDelay);
        
        // Exponential backoff with jitter
        currentDelay = Duration(
          milliseconds: min(
            _maxRetryDelay.inMilliseconds,
            (currentDelay.inMilliseconds * 2) + Random().nextInt(1000),
          ),
        );
        
      } catch (e) {
        print('CommentSubmissionService: Unexpected error on attempt $attemptCount: $e');
        
        if (attemptCount >= _maxRetryAttempts) {
          return CommentSubmissionResult.failure(
            'Failed to submit comment after $_maxRetryAttempts attempts: ${e.toString()}',
            CommentSubmissionErrorType.network,
          );
        }
        
        // Wait before retrying
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: min(
            _maxRetryDelay.inMilliseconds,
            (currentDelay.inMilliseconds * 2) + Random().nextInt(1000),
          ),
        );
      }
    }
    
    return CommentSubmissionResult.failure(
      'Failed to submit comment after $_maxRetryAttempts attempts',
      CommentSubmissionErrorType.network,
    );
  }

  /// Perform the actual comment submission
  Future<CommentSubmissionResult> _performSubmission(CommentData commentData) async {
    // Simulate network request with potential failures
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
    
    // Simulate different types of failures for testing
    final random = Random();
    final failureChance = random.nextDouble();
    
    if (failureChance < 0.1) {
      // 10% chance of validation error (non-retryable)
      return CommentSubmissionResult.failure(
        'Comment content violates community guidelines',
        CommentSubmissionErrorType.validation,
      );
    } else if (failureChance < 0.3) {
      // 20% chance of network error (retryable)
      return CommentSubmissionResult.failure(
        'Network connection failed',
        CommentSubmissionErrorType.network,
      );
    } else if (failureChance < 0.4) {
      // 10% chance of server error (retryable)
      return CommentSubmissionResult.failure(
        'Server temporarily unavailable',
        CommentSubmissionErrorType.server,
      );
    } else if (failureChance < 0.45) {
      // 5% chance of authentication error (non-retryable)
      return CommentSubmissionResult.failure(
        'User authentication failed',
        CommentSubmissionErrorType.authentication,
      );
    }
    
    // 55% chance of success
    final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}';
    
    return CommentSubmissionResult.success(
      commentId: commentId,
      message: 'Comment submitted successfully',
      submittedAt: DateTime.now(),
    );
  }

  /// Validate comment content
  CommentValidationResult _validateComment(String content) {
    final trimmedContent = content.trim();
    
    if (trimmedContent.isEmpty) {
      return CommentValidationResult.invalid('Comment cannot be empty');
    }
    
    if (trimmedContent.length < 2) {
      return CommentValidationResult.invalid('Comment must be at least 2 characters long');
    }
    
    if (trimmedContent.length > 1000) {
      return CommentValidationResult.invalid('Comment cannot exceed 1000 characters');
    }
    
    // Check for spam patterns
    if (_containsSpam(trimmedContent)) {
      return CommentValidationResult.invalid('Comment appears to be spam');
    }
    
    // Check for inappropriate content
    if (_containsInappropriateContent(trimmedContent)) {
      return CommentValidationResult.invalid('Comment contains inappropriate content');
    }
    
    return CommentValidationResult.valid();
  }

  /// Check if content contains spam patterns
  bool _containsSpam(String content) {
    final lowerContent = content.toLowerCase();
    
    // Simple spam detection patterns
    final spamPatterns = [
      RegExp(r'(.)\1{10,}'), // Repeated characters
      RegExp(r'(https?://\S+.*){3,}'), // Multiple URLs
      RegExp(r'\b(buy now|click here|free money|win now)\b'), // Spam phrases
    ];
    
    return spamPatterns.any((pattern) => pattern.hasMatch(lowerContent));
  }

  /// Check if content contains inappropriate content
  bool _containsInappropriateContent(String content) {
    final lowerContent = content.toLowerCase();
    
    // Simple inappropriate content detection
    final inappropriatePatterns = [
      RegExp(r'\b(hate|violence|threat)\b'),
      // Add more patterns as needed
    ];
    
    return inappropriatePatterns.any((pattern) => pattern.hasMatch(lowerContent));
  }

  /// Check if an error type is retryable
  bool _isRetryableError(CommentSubmissionErrorType? errorType) {
    switch (errorType) {
      case CommentSubmissionErrorType.network:
      case CommentSubmissionErrorType.server:
      case CommentSubmissionErrorType.timeout:
        return true;
      case CommentSubmissionErrorType.validation:
      case CommentSubmissionErrorType.authentication:
      case CommentSubmissionErrorType.permission:
        return false;
      case null:
        return true; // Default to retryable for unknown errors
    }
  }

  /// Get submission statistics
  CommentSubmissionStats getSubmissionStats() {
    // In a real implementation, this would track actual statistics
    return CommentSubmissionStats(
      totalSubmissions: 0,
      successfulSubmissions: 0,
      failedSubmissions: 0,
      averageRetryCount: 0.0,
      lastSubmissionTime: null,
    );
  }

  /// Clear any cached data or reset state
  void reset() {
    // Reset any internal state if needed
    print('CommentSubmissionService: Service reset');
  }
}

/// Data class for comment information
class CommentData {
  final String content;
  final String postId;
  final String userId;
  final String? parentCommentId;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  CommentData({
    required this.content,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.metadata,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'postId': postId,
      'userId': userId,
      'parentCommentId': parentCommentId,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CommentData{postId: $postId, userId: $userId, contentLength: ${content.length}}';
  }
}

/// Result of comment submission
class CommentSubmissionResult {
  final bool success;
  final String? commentId;
  final String message;
  final CommentSubmissionErrorType? errorType;
  final DateTime? submittedAt;
  final int? attemptCount;

  const CommentSubmissionResult._({
    required this.success,
    this.commentId,
    required this.message,
    this.errorType,
    this.submittedAt,
    this.attemptCount,
  });

  factory CommentSubmissionResult.success({
    required String commentId,
    required String message,
    required DateTime submittedAt,
    int? attemptCount,
  }) {
    return CommentSubmissionResult._(
      success: true,
      commentId: commentId,
      message: message,
      submittedAt: submittedAt,
      attemptCount: attemptCount,
    );
  }

  factory CommentSubmissionResult.failure(
    String message,
    CommentSubmissionErrorType errorType, {
    int? attemptCount,
  }) {
    return CommentSubmissionResult._(
      success: false,
      message: message,
      errorType: errorType,
      attemptCount: attemptCount,
    );
  }

  @override
  String toString() {
    return 'CommentSubmissionResult{success: $success, message: $message, errorType: $errorType}';
  }
}

/// Types of comment submission errors
enum CommentSubmissionErrorType {
  validation,
  network,
  server,
  timeout,
  authentication,
  permission,
}

/// Result of comment validation
class CommentValidationResult {
  final bool isValid;
  final String? errorMessage;

  const CommentValidationResult._(this.isValid, this.errorMessage);

  factory CommentValidationResult.valid() {
    return const CommentValidationResult._(true, null);
  }

  factory CommentValidationResult.invalid(String errorMessage) {
    return CommentValidationResult._(false, errorMessage);
  }

  @override
  String toString() {
    return 'CommentValidationResult{isValid: $isValid, errorMessage: $errorMessage}';
  }
}

/// Statistics for comment submissions
class CommentSubmissionStats {
  final int totalSubmissions;
  final int successfulSubmissions;
  final int failedSubmissions;
  final double averageRetryCount;
  final DateTime? lastSubmissionTime;

  CommentSubmissionStats({
    required this.totalSubmissions,
    required this.successfulSubmissions,
    required this.failedSubmissions,
    required this.averageRetryCount,
    this.lastSubmissionTime,
  });

  double get successRate {
    if (totalSubmissions == 0) return 0.0;
    return successfulSubmissions / totalSubmissions;
  }

  double get failureRate {
    if (totalSubmissions == 0) return 0.0;
    return failedSubmissions / totalSubmissions;
  }

  @override
  String toString() {
    return 'CommentSubmissionStats{total: $totalSubmissions, success: $successfulSubmissions, failed: $failedSubmissions}';
  }
}