import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/forum/domain/entities/comment_entity.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';
import 'package:guardiancare/features/forum/domain/entities/user_details_entity.dart';

/// Abstract repository for forum operations
abstract class ForumRepository {
  /// Get forums by category
  Stream<Either<Failure, List<ForumEntity>>> getForums(ForumCategory category);

  /// Get comments for a specific forum
  Stream<Either<Failure, List<CommentEntity>>> getComments(String forumId);

  /// Add a comment to a forum
  Future<Either<Failure, void>> addComment({
    required String forumId,
    required String text,
    required String userId,
    String? parentId,
  });

  /// Get user details by user ID
  Future<Either<Failure, UserDetailsEntity>> getUserDetails(String userId);

  /// Create a new forum post
  Future<Either<Failure, String>> createForum({
    required String title,
    required String description,
    required ForumCategory category,
    required String userId,
  });

  /// Delete a forum post
  Future<Either<Failure, void>> deleteForum(String forumId);

  /// Delete a comment
  Future<Either<Failure, void>> deleteComment({
    required String forumId,
    required String commentId,
  });
}
