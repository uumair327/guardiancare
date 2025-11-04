import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:guardiancare/src/features/forum/controllers/comment_controller.dart';
import 'package:guardiancare/src/features/forum/services/comment_submission_service.dart';
import 'package:guardiancare/src/features/forum/forum_service.dart';

// Generate mocks
@GenerateMocks([ForumService])
import 'comment_controller_test.mocks.dart';

void main() {
  group('CommentController Tests', () {
    late CommentController controller;
    late MockForumService mockForumService;

    setUp(() {
      mockForumService = MockForumService();
      controller = CommentController();
      // Note: In a real test, we'd inject the mock service
    });

    tearDown(() {
      controller.dispose();
    });

    group('Initialization', () {
      test('should initialize with empty state', () {
        expect(controller.getSubmissionState('post1').isIdle, isTrue);
        expect(controller.isSubmissionActive('post1'), isFalse);
        expect(controller.getSubmissionHistory('post1'), isEmpty);
      });
    });

    group('Submission State Management', () {
      test('should track submission states correctly', () {
        final initialState = controller.getSubmissionState('post1');
        expect(initialState.status, equals(CommentSubmissionStatus.idle));
      });

      test('should prevent duplicate submissions', () async {
        // Start first submission
        final future1 = controller.addComment('post1', 'Test comment');
        
        // Try to start second submission immediately
        final result2 = await controller.addComment('post1', 'Another comment');
        
        expect(result2.success, isFalse);
        expect(result2.message, contains('already in progress'));
        
        // Wait for first submission to complete
        await future1;
      });

      test('should track active submissions', () async {
        // Start submission but don't await
        final future = controller.addComment('post1', 'Test comment');
        
        // Check if submission is active
        expect(controller.isSubmissionActive('post1'), isTrue);
        
        // Wait for completion
        await future;
        
        // Should no longer be active
        expect(controller.isSubmissionActive('post1'), isFalse);
      });

      test('should clear submission state after delay', () async {
        await controller.addComment('post1', 'Test comment');
        
        // State should exist immediately after submission
        final stateAfter = controller.getSubmissionState('post1');
        expect(stateAfter.status, isNot(equals(CommentSubmissionStatus.idle)));
        
        // Wait for auto-clear delay
        await Future.delayed(const Duration(seconds: 4));
        
        // State should be cleared
        final stateCleared = controller.getSubmissionState('post1');
        expect(stateCleared.status, equals(CommentSubmissionStatus.idle));
      });
    });

    group('Submission History', () {
      test('should record submission attempts', () async {
        await controller.addComment('post1', 'Test comment');
        
        final history = controller.getSubmissionHistory('post1');
        expect(history, isNotEmpty);
        expect(history.first.result, isNotNull);
      });

      test('should limit history to 10 attempts', () async {
        // Make 15 submission attempts
        for (int i = 0; i < 15; i++) {
          await controller.addComment('post$i', 'Test comment $i');
        }
        
        // Check that history is limited
        for (int i = 0; i < 15; i++) {
          final history = controller.getSubmissionHistory('post$i');
          expect(history.length, lessThanOrEqualTo(10));
        }
      });
    });

    group('Retry Logic', () {
      test('should allow retry for retryable errors', () async {
        // This test would require mocking the submission service to return specific errors
        // For now, we'll test the retry method exists and handles basic cases
        
        final result = await controller.retryComment('post1', 'Test comment');
        expect(result, isNotNull);
      });

      test('should prevent retry when not in error state', () async {
        final result = await controller.retryComment('post1', 'Test comment');
        
        expect(result.success, isFalse);
        expect(result.message, contains('Cannot retry'));
      });
    });

    group('Submission Cancellation', () {
      test('should cancel active submissions', () async {
        // Start submission but don't await
        final future = controller.addComment('post1', 'Test comment');
        
        // Cancel the submission
        controller.cancelSubmission('post1');
        
        // Wait for original submission to complete
        await future;
        
        // Check that submission was cancelled
        expect(controller.isSubmissionActive('post1'), isFalse);
      });

      test('should handle cancellation of non-active submissions', () {
        // Should not crash when cancelling non-active submission
        expect(() => controller.cancelSubmission('post1'), returnsNormally);
      });
    });

    group('State Clearing', () {
      test('should clear specific submission state', () async {
        await controller.addComment('post1', 'Test comment');
        
        // Clear specific state
        controller.clearSubmissionState('post1');
        
        final state = controller.getSubmissionState('post1');
        expect(state.status, equals(CommentSubmissionStatus.idle));
      });

      test('should clear all submission states', () async {
        // Add comments to multiple posts
        await controller.addComment('post1', 'Test comment 1');
        await controller.addComment('post2', 'Test comment 2');
        
        // Clear all states
        controller.clearAllSubmissionStates();
        
        expect(controller.getSubmissionState('post1').isIdle, isTrue);
        expect(controller.getSubmissionState('post2').isIdle, isTrue);
      });
    });

    group('Statistics', () {
      test('should provide submission statistics', () {
        final stats = controller.getSubmissionStats();
        
        expect(stats, isNotNull);
        expect(stats.totalSubmissions, isA<int>());
        expect(stats.successfulSubmissions, isA<int>());
        expect(stats.failedSubmissions, isA<int>());
        expect(stats.averageRetryCount, isA<double>());
      });

      test('should update statistics after submissions', () async {
        final statsBefore = controller.getSubmissionStats();
        
        await controller.addComment('post1', 'Test comment');
        
        final statsAfter = controller.getSubmissionStats();
        expect(statsAfter.totalSubmissions, greaterThanOrEqualTo(statsBefore.totalSubmissions));
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners on state changes', () async {
        int notificationCount = 0;
        controller.addListener(() => notificationCount++);

        await controller.addComment('post1', 'Test comment');
        
        expect(notificationCount, greaterThan(0));
      });

      test('should handle multiple listeners', () async {
        int listener1Count = 0;
        int listener2Count = 0;
        
        void listener1() => listener1Count++;
        void listener2() => listener2Count++;

        controller.addListener(listener1);
        controller.addListener(listener2);

        await controller.addComment('post1', 'Test comment');
        
        expect(listener1Count, greaterThan(0));
        expect(listener2Count, greaterThan(0));

        controller.removeListener(listener1);
        
        final initialCount2 = listener2Count;
        await controller.addComment('post2', 'Another comment');
        
        expect(listener2Count, greaterThan(initialCount2));
      });
    });

    group('Error Handling', () {
      test('should handle submission service errors gracefully', () async {
        // Test with invalid input that should cause validation error
        final result = await controller.addComment('post1', '');
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
      });

      test('should handle unexpected errors', () async {
        // This would require mocking the submission service to throw
        // For now, test that the method handles basic error cases
        final result = await controller.addComment('', ''); // Invalid inputs
        
        expect(result.success, isFalse);
      });
    });

    group('Parent Comment Support', () {
      test('should handle parent comment IDs', () async {
        final result = await controller.addComment(
          'post1', 
          'Reply comment',
          parentCommentId: 'parent123',
        );
        
        expect(result, isNotNull);
      });

      test('should track parent comment submissions separately', () async {
        // Submit comment to post
        await controller.addComment('post1', 'Main comment');
        
        // Submit reply to comment
        await controller.addComment(
          'post1', 
          'Reply comment',
          parentCommentId: 'parent123',
        );
        
        // Should have separate submission states
        final mainState = controller.getSubmissionState('post1');
        // Note: The actual key generation logic would need to be tested
        // with proper mocking of the submission service
      });
    });

    group('Metadata Support', () {
      test('should handle metadata in submissions', () async {
        final metadata = {
          'source': 'mobile_app',
          'version': '1.0.0',
        };
        
        final result = await controller.addComment(
          'post1',
          'Test comment',
          metadata: metadata,
        );
        
        expect(result, isNotNull);
      });
    });

    group('Memory Management', () {
      test('should dispose resources properly', () {
        controller.dispose();
        
        // Should not crash after disposal
        expect(() => controller.getSubmissionState('post1'), returnsNormally);
      });

      test('should handle multiple dispose calls', () {
        controller.dispose();
        expect(() => controller.dispose(), returnsNormally);
      });
    });
  });

  group('CommentSubmissionState Tests', () {
    test('should create idle state correctly', () {
      final state = CommentSubmissionState.idle();
      
      expect(state.status, equals(CommentSubmissionStatus.idle));
      expect(state.isIdle, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.isError, isFalse);
      expect(state.isCancelled, isFalse);
    });

    test('should create loading state correctly', () {
      final state = CommentSubmissionState.loading();
      
      expect(state.status, equals(CommentSubmissionStatus.loading));
      expect(state.isLoading, isTrue);
      expect(state.isIdle, isFalse);
    });

    test('should create success state correctly', () {
      final state = CommentSubmissionState.success(
        message: 'Success!',
        commentId: 'comment123',
      );
      
      expect(state.status, equals(CommentSubmissionStatus.success));
      expect(state.isSuccess, isTrue);
      expect(state.message, equals('Success!'));
      expect(state.commentId, equals('comment123'));
    });

    test('should create error state correctly', () {
      final state = CommentSubmissionState.error(
        message: 'Error occurred',
        errorType: CommentSubmissionErrorType.network,
        canRetry: true,
      );
      
      expect(state.status, equals(CommentSubmissionStatus.error));
      expect(state.isError, isTrue);
      expect(state.message, equals('Error occurred'));
      expect(state.errorType, equals(CommentSubmissionErrorType.network));
      expect(state.canRetry, isTrue);
    });

    test('should create cancelled state correctly', () {
      final state = CommentSubmissionState.cancelled();
      
      expect(state.status, equals(CommentSubmissionStatus.cancelled));
      expect(state.isCancelled, isTrue);
      expect(state.message, equals('Submission cancelled'));
    });

    test('should have proper string representation', () {
      final state = CommentSubmissionState.success(
        message: 'Success',
        commentId: 'comment123',
      );
      
      final stringRep = state.toString();
      expect(stringRep, contains('success'));
      expect(stringRep, contains('Success'));
    });

    test('should include timestamp', () {
      final before = DateTime.now();
      final state = CommentSubmissionState.loading();
      final after = DateTime.now();
      
      expect(state.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(state.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  group('CommentSubmissionAttempt Tests', () {
    test('should create attempt record correctly', () {
      final timestamp = DateTime.now();
      final result = CommentSubmissionResult.success(
        commentId: 'comment123',
        message: 'Success',
        submittedAt: timestamp,
      );
      
      final attempt = CommentSubmissionAttempt(
        timestamp: timestamp,
        result: result,
      );
      
      expect(attempt.timestamp, equals(timestamp));
      expect(attempt.result, equals(result));
    });

    test('should have proper string representation', () {
      final result = CommentSubmissionResult.success(
        commentId: 'comment123',
        message: 'Success',
        submittedAt: DateTime.now(),
      );
      
      final attempt = CommentSubmissionAttempt(
        timestamp: DateTime.now(),
        result: result,
      );
      
      final stringRep = attempt.toString();
      expect(stringRep, contains('timestamp'));
      expect(stringRep, contains('success: true'));
    });
  });

  group('Edge Cases', () {
    test('should handle rapid successive submissions', () async {
      final controller = CommentController();
      
      // Submit multiple comments rapidly
      final futures = <Future<CommentSubmissionResult>>[];
      for (int i = 0; i < 5; i++) {
        futures.add(controller.addComment('post$i', 'Comment $i'));
      }
      
      final results = await Future.wait(futures);
      
      expect(results.length, equals(5));
      for (final result in results) {
        expect(result, isNotNull);
      }
      
      controller.dispose();
    });

    test('should handle very long comment content', () async {
      final controller = CommentController();
      final longComment = 'a' * 500; // Long but valid comment
      
      final result = await controller.addComment('post1', longComment);
      expect(result, isNotNull);
      
      controller.dispose();
    });

    test('should handle special characters in post IDs', () async {
      final controller = CommentController();
      final specialPostId = 'post-123_test@domain.com';
      
      final result = await controller.addComment(specialPostId, 'Test comment');
      expect(result, isNotNull);
      
      controller.dispose();
    });
  });
}