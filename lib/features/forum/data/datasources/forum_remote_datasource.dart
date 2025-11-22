import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/forum/data/models/comment_model.dart';
import 'package:guardiancare/features/forum/data/models/forum_model.dart';
import 'package:guardiancare/features/forum/data/models/user_details_model.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';

/// Abstract class defining forum remote data source operations
abstract class ForumRemoteDataSource {
  Stream<List<ForumModel>> getForums(ForumCategory category);
  Stream<List<CommentModel>> getComments(String forumId);
  Future<void> addComment(String forumId, String text, String userId);
  Future<UserDetailsModel> getUserDetails(String userId);
  Future<String> createForum(
    String title,
    String description,
    ForumCategory category,
    String userId,
  );
  Future<void> deleteForum(String forumId);
  Future<void> deleteComment(String forumId, String commentId);
}

/// Implementation of ForumRemoteDataSource using Firebase
class ForumRemoteDataSourceImpl implements ForumRemoteDataSource {
  final FirebaseFirestore firestore;

  ForumRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<ForumModel>> getForums(ForumCategory category) {
    final categoryString = category == ForumCategory.parent ? 'parent' : 'children';
    print('ForumDataSource: Fetching forums for category: $categoryString');
    
    return firestore
        .collection('forum')
        .where('category', isEqualTo: categoryString)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('ForumDataSource: Stream error: $error');
          print('ForumDataSource: Error type: ${error.runtimeType}');
          // Don't throw, just return empty list
        })
        .map((snapshot) {
          print('ForumDataSource: Received ${snapshot.docs.length} forums');
          if (snapshot.docs.isEmpty) {
            print('ForumDataSource: No forums found for category: $categoryString');
          }
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              print('ForumDataSource: Parsing forum ${doc.id}: $data');
              return ForumModel.fromMap(data);
            } catch (e) {
              print('ForumDataSource: Error parsing forum ${doc.id}: $e');
              rethrow;
            }
          }).toList();
        });
  }

  @override
  Stream<List<CommentModel>> getComments(String forumId) {
    try {
      return firestore
          .collection('forum')
          .doc(forumId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to get comments: ${e.toString()}');
    }
  }

  @override
  Future<void> addComment(String forumId, String text, String userId) async {
    try {
      final commentId = DateTime.now().microsecondsSinceEpoch.toString();
      final comment = CommentModel(
        id: commentId,
        userId: userId,
        forumId: forumId,
        text: text,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection('forum')
          .doc(forumId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toMap());
    } catch (e) {
      throw ServerException('Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Future<UserDetailsModel> getUserDetails(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return const UserDetailsModel(
          userName: 'Anonymous',
          userImage: '',
          userEmail: 'anonymous@mail.com',
          role: 'child',
        );
      }

      return UserDetailsModel.fromMap(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get user details: ${e.toString()}');
    }
  }

  @override
  Future<String> createForum(
    String title,
    String description,
    ForumCategory category,
    String userId,
  ) async {
    try {
      final forumId = DateTime.now().microsecondsSinceEpoch.toString();
      final forum = ForumModel(
        id: forumId,
        userId: userId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        category: category,
      );

      await firestore.collection('forum').doc(forumId).set(forum.toMap());

      return forumId;
    } catch (e) {
      throw ServerException('Failed to create forum: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteForum(String forumId) async {
    try {
      // Delete all comments first
      final commentsSnapshot = await firestore
          .collection('forum')
          .doc(forumId)
          .collection('comments')
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the forum
      await firestore.collection('forum').doc(forumId).delete();
    } catch (e) {
      throw ServerException('Failed to delete forum: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteComment(String forumId, String commentId) async {
    try {
      await firestore
          .collection('forum')
          .doc(forumId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete comment: ${e.toString()}');
    }
  }
}
