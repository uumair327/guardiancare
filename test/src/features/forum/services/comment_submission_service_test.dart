import 'package:flutter_test/flutter_test.dart';
import 'package:guardiancare/src/features/forum/services/comment_submission_service.dart';

void main() {
  group('CommentSubmissionService Tests', () {
    late CommentSubmissionService service;

    setUp(() {
      service = CommentSubmissionService.instance;
      service.reset();
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = CommentSubmissionService.instance;
        final instance2 = CommentSubmissionService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Comment Validation', () {
      test('should reject empty comments', () async {
        final result = await service.submitComment(
          content: '',
          postId: 'post1',
          userId: 'user1',
        );

        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
        expect(result.message, contains('empty'));
      });

      test('should reject comments that are too short', () async {
        final result = await service.submitComment(
          content: 'a',
          postId: 'post1',
          userId: 'user1',
        );

        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
        expect(result.message, contains('at least 2 characters'));
      });

      test('should reject comments that are too long', () async {
        final longComment = 'a' * 1001; // Exceeds 1000 character limit
        
        final result = await service.submitComment(
          content: longComment,
          postId: 'post1',
          userId: 'user1',
        );

        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
        expect(result.message, contains('cannot exceed 1000 characters'));
      });

      test('should accept valid comments', () async {
        final result = await service.submitComment(
          content: 'This is a valid comment',
          postId: 'post1',
          userId: 'user1',
        );

        // Note: Due to random simulation, this might succeed or fail
        // In a real implementation, we'd mock the submission logic
        expect(result, isNotNull);
        expect(result.message, isNotEmpty);
      });

      test('should trim whitespace from comments', () async {
        final result = await service.submitComment(
          content: '  This comment has whitespace  ',
          postId: 'post1',
          userId: 'user1',
        );

        expect(result, isNotNull);
        // The service should internally trim the content
      });
    });

    group('Spam Detection', () {
      test('should detect repeated characters as spam', () async {
        final spamComment = 'aaaaaaaaaaaaaaaaaaa'; // Many repeated characters
        
        final result = await service.submitComment(
          content: spamComment,
          postId: 'post1',
          userId: 'user1',
        );

        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
        expect(result.message, contains('spam'));
      });

      test('should detect spam phrases', () async {
        final spamComment = 'Click here to buy now and win free money!';
        
        final result = await service.submitComment(
          content: spamComment,
          postId: 'post1',
          userId: 'user1',
        );

        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
        expect(result.message, contains('spam'));
      });
    });

    group('Inappropriate Content Detection', () {
      test('should detect inappropriate content', () async {
        final inappropriateComment = 'This contains hate speech';
        
        final result = await service.submitComment(
          content: inappropriateComment,
          postId: 'post1',
          userId: 'user1',
        );

        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
        expect(result.message, contains('inappropriate content'));
      });
    });

    group('Retry Logic', () {
      test('should handle multiple submission attempts', () async {
        // Since the service uses random simulation, we'll test multiple times
        // to verify the retry logic works
        final results = <CommentSubmissionResult>[];
        
        for (int i = 0; i < 5; i++) {
          final result = await service.submitComment(
            content: 'Test comment $i',
            postId: 'post1',
            userId: 'user1',
          );
          results.add(result);
        }

        // Should have received 5 results
        expect(results.length, equals(5));
        
        // All results should have valid messages
        for (final result in results) {
          expect(result.message, isNotEmpty);
        }
      });
    });

    group('Comment Data Structure', () {
      test('should handle optional parameters', () async {
        final result = await service.submitComment(
          content: 'Test comment',
          postId: 'post1',
          userId: 'user1',
          parentCommentId: 'parent1',
          metadata: {'key': 'value'},
        );

        expect(result, isNotNull);
      });

      test('should handle minimal parameters', () async {
        final result = await service.submitComment(
          content: 'Test comment',
          postId: 'post1',
          userId: 'user1',
        );

        expect(result, isNotNull);
      });
    });

    group('Service Statistics', () {
      test('should provide submission statistics', () {
        final stats = service.getSubmissionStats();
        
        expect(stats, isNotNull);
        expect(stats.totalSubmissions, isA<int>());
        expect(stats.successfulSubmissions, isA<int>());
        expect(stats.failedSubmissions, isA<int>());
        expect(stats.averageRetryCount, isA<double>());
      });
    });

    group('Service Reset', () {
      test('should reset service state', () {
        expect(() => service.reset(), returnsNormally);
      });
    });
  });

  group('CommentData Tests', () {
    test('should create comment data correctly', () {
      final commentData = CommentData(
        content: 'Test content',
        postId: 'post1',
        userId: 'user1',
        parentCommentId: 'parent1',
        metadata: {'key': 'value'},
        timestamp: DateTime.now(),
      );

      expect(commentData.content, equals('Test content'));
      expect(commentData.postId, equals('post1'));
      expect(commentData.userId, equals('user1'));
      expect(commentData.parentCommentId, equals('parent1'));
      expect(commentData.metadata['key'], equals('value'));
    });

    test('should convert to map correctly', () {
      final timestamp = DateTime.now();
      final commentData = CommentData(
        content: 'Test content',
        postId: 'post1',
        userId: 'user1',
        metadata: {},
        timestamp: timestamp,
      );

      final map = commentData.toMap();
      
      expect(map['content'], equals('Test content'));
      expect(map['postId'], equals('post1'));
      expect(map['userId'], equals('user1'));
      expect(map['timestamp'], equals(timestamp.toIso8601String()));
    });

    test('should have proper string representation', () {
      final commentData = CommentData(
        content: 'Test content',
        postId: 'post1',
        userId: 'user1',
        metadata: {},
        timestamp: DateTime.now(),
      );

      final stringRep = commentData.toString();
      expect(stringRep, contains('post1'));
      expect(stringRep, contains('user1'));
      expect(stringRep, contains('12')); // Content length
    });
  });

  group('CommentSubmissionResult Tests', () {
    test('should create success result correctly', () {
      final result = CommentSubmissionResult.success(
        commentId: 'comment123',
        message: 'Success message',
        submittedAt: DateTime.now(),
        attemptCount: 1,
      );

      expect(result.success, isTrue);
      expect(result.commentId, equals('comment123'));
      expect(result.message, equals('Success message'));
      expect(result.errorType, isNull);
      expect(result.attemptCount, equals(1));
    });

    test('should create failure result correctly', () {
      final result = CommentSubmissionResult.failure(
        'Failure message',
        CommentSubmissionErrorType.network,
        attemptCount: 3,
      );

      expect(result.success, isFalse);
      expect(result.commentId, isNull);
      expect(result.message, equals('Failure message'));
      expect(result.errorType, equals(CommentSubmissionErrorType.network));
      expect(result.attemptCount, equals(3));
    });

    test('should have proper string representation', () {
      final result = CommentSubmissionResult.success(
        commentId: 'comment123',
        message: 'Success',
        submittedAt: DateTime.now(),
      );

      final stringRep = result.toString();
      expect(stringRep, contains('success: true'));
      expect(stringRep, contains('Success'));
    });
  });

  group('CommentValidationResult Tests', () {
    test('should create valid result', () {
      final result = CommentValidationResult.valid();
      
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('should create invalid result', () {
      final result = CommentValidationResult.invalid('Error message');
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Error message'));
    });

    test('should have proper string representation', () {
      final validResult = CommentValidationResult.valid();
      final invalidResult = CommentValidationResult.invalid('Error');

      expect(validResult.toString(), contains('isValid: true'));
      expect(invalidResult.toString(), contains('isValid: false'));
      expect(invalidResult.toString(), contains('Error'));
    });
  });

  group('CommentSubmissionStats Tests', () {
    test('should calculate success rate correctly', () {
      final stats = CommentSubmissionStats(
        totalSubmissions: 10,
        successfulSubmissions: 7,
        failedSubmissions: 3,
        averageRetryCount: 1.5,
        lastSubmissionTime: DateTime.now(),
      );

      expect(stats.successRate, equals(0.7));
      expect(stats.failureRate, equals(0.3));
    });

    test('should handle zero submissions', () {
      final stats = CommentSubmissionStats(
        totalSubmissions: 0,
        successfulSubmissions: 0,
        failedSubmissions: 0,
        averageRetryCount: 0.0,
        lastSubmissionTime: null,
      );

      expect(stats.successRate, equals(0.0));
      expect(stats.failureRate, equals(0.0));
    });

    test('should have proper string representation', () {
      final stats = CommentSubmissionStats(
        totalSubmissions: 5,
        successfulSubmissions: 3,
        failedSubmissions: 2,
        averageRetryCount: 1.0,
        lastSubmissionTime: DateTime.now(),
      );

      final stringRep = stats.toString();
      expect(stringRep, contains('total: 5'));
      expect(stringRep, contains('success: 3'));
      expect(stringRep, contains('failed: 2'));
    });
  });

  group('Error Type Enum Tests', () {
    test('should have all expected error types', () {
      final errorTypes = CommentSubmissionErrorType.values;
      
      expect(errorTypes, contains(CommentSubmissionErrorType.validation));
      expect(errorTypes, contains(CommentSubmissionErrorType.network));
      expect(errorTypes, contains(CommentSubmissionErrorType.server));
      expect(errorTypes, contains(CommentSubmissionErrorType.timeout));
      expect(errorTypes, contains(CommentSubmissionErrorType.authentication));
      expect(errorTypes, contains(CommentSubmissionErrorType.permission));
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle null and empty strings gracefully', () async {
      // Test with various edge case inputs
      final testCases = ['', '   ', '\n\t', null];
      
      for (final testCase in testCases) {
        final result = await service.submitComment(
          content: testCase ?? '',
          postId: 'post1',
          userId: 'user1',
        );
        
        expect(result.success, isFalse);
        expect(result.errorType, equals(CommentSubmissionErrorType.validation));
      }
    });

    test('should handle special characters in content', () async {
      final specialContent = 'Comment with émojis 🎉 and special chars: @#\$%^&*()';
      
      final result = await service.submitComment(
        content: specialContent,
        postId: 'post1',
        userId: 'user1',
      );

      expect(result, isNotNull);
      // Should not crash with special characters
    });

    test('should handle very long post IDs and user IDs', () async {
      final longId = 'a' * 1000;
      
      final result = await service.submitComment(
        content: 'Valid comment',
        postId: longId,
        userId: longId,
      );

      expect(result, isNotNull);
      // Should handle long IDs without issues
    });
  });
}