import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/forum/data/models/comment_model.dart';
import 'package:guardiancare/features/forum/data/models/forum_model.dart';
import 'package:guardiancare/features/forum/data/models/user_details_model.dart';
import 'package:guardiancare/features/forum/domain/entities/forum_entity.dart';

/// Abstract class defining forum remote data source operations
abstract class ForumRemoteDataSource {
  Stream<List<ForumModel>> getForums(ForumCategory category);
  Stream<List<CommentModel>> getComments(String forumId);
  Future<void> addComment(String forumId, String text, String userId,
      {String? parentId});
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

/// Implementation of ForumRemoteDataSource using IDataStore abstraction
///
/// Following: DIP (Dependency Inversion Principle)
class ForumRemoteDataSourceImpl implements ForumRemoteDataSource {
  ForumRemoteDataSourceImpl({required IDataStore dataStore})
      : _dataStore = dataStore;
  final IDataStore _dataStore;

  @override
  Stream<List<ForumModel>> getForums(ForumCategory category) {
    final categoryString =
        category == ForumCategory.parent ? 'parent' : 'children';
    Log.d('ForumDataSource: Fetching forums for category: $categoryString');

    final options = QueryOptions(
      filters: [QueryFilter.equals('category', categoryString)],
      orderBy: [const OrderBy('createdAt', descending: true)],
    );

    return _dataStore.streamQuery('forum', options: options).map((result) {
      return result.when(
        success: (docs) {
          Log.d('ForumDataSource: Received ${docs.length} forums');
          if (docs.isEmpty) {
            Log.d(
                'ForumDataSource: No forums found for category: $categoryString');
          }

          return docs.map((doc) {
            try {
              Log.d('ForumDataSource: Parsing forum: $doc');
              // Ensure doc has ID, though adapter should provide it
              if (!doc.containsKey('id')) {
                Log.w('ForumDataSource: Warning - doc missing id field');
              }
              return ForumModel.fromMap(doc);
            } on Object catch (e) {
              Log.e('ForumDataSource: Error parsing forum: $e');
              rethrow;
            }
          }).toList();
        },
        failure: (error) {
          Log.e('ForumDataSource: Stream error: ${error.message}');
          return <ForumModel>[];
        },
      );
    });
  }

  @override
  Stream<List<CommentModel>> getComments(String forumId) {
    try {
      const options = QueryOptions(
        orderBy: [OrderBy('createdAt', descending: true)],
      );

      return _dataStore
          .streamSubcollection('forum', forumId, 'comments', options: options)
          .map((result) {
        return result.when(
          success: (docs) {
            return docs.map(CommentModel.fromMap).toList();
          },
          failure: (error) {
            Log.e('ForumDataSource: Error fetching comments: ${error.message}');
            return <CommentModel>[];
          },
        );
      });
    } on Object catch (e) {
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.getCommentsError, e.toString()));
    }
  }

  @override
  Future<void> addComment(String forumId, String text, String userId,
      {String? parentId}) async {
    try {
      final commentId = DateTime.now().microsecondsSinceEpoch.toString();
      final comment = CommentModel(
        id: commentId,
        userId: userId,
        forumId: forumId,
        text: text,
        createdAt: DateTime.now(),
        parentId: parentId,
      );

      final result = await _dataStore.setSubdocument(
        'forum',
        forumId,
        'comments',
        commentId,
        comment.toMap(),
      );

      if (result.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.addCommentError, result.errorOrNull!.message));
      }
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          ErrorStrings.withDetails(ErrorStrings.addCommentError, e.toString()));
    }
  }

  @override
  Future<UserDetailsModel> getUserDetails(String userId) async {
    try {
      final result = await _dataStore.get('users', userId);

      return result.when(
        success: (data) {
          if (data == null) {
            return const UserDetailsModel(
              userName: 'Anonymous',
              userImage: '',
              userEmail: 'anonymous@mail.com',
              role: 'child',
            );
          }
          return UserDetailsModel.fromMap(data);
        },
        failure: (error) {
          throw ServerException(ErrorStrings.withDetails(
              ErrorStrings.getUserDetailsError, error.message));
        },
      );
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.getUserDetailsError, e.toString()));
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

      final result = await _dataStore.set('forum', forumId, forum.toMap());

      if (result.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.createForumError, result.errorOrNull!.message));
      }

      return forumId;
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.createForumError, e.toString()));
    }
  }

  @override
  Future<void> deleteForum(String forumId) async {
    try {
      // Delete all comments first
      final commentsResult = await _dataStore.querySubcollection(
        'forum',
        forumId,
        'comments',
      );

      if (commentsResult.isSuccess) {
        final comments = commentsResult.dataOrNull!;
        for (final doc in comments) {
          final commentId = doc['id'] as String;
          await _dataStore.deleteSubdocument(
              'forum', forumId, 'comments', commentId);
        }
      }

      // Delete the forum
      final result = await _dataStore.delete('forum', forumId);

      if (result.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.deleteForumError, result.errorOrNull!.message));
      }
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.deleteForumError, e.toString()));
    }
  }

  @override
  Future<void> deleteComment(String forumId, String commentId) async {
    try {
      final result = await _dataStore.deleteSubdocument(
          'forum', forumId, 'comments', commentId);
      if (result.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.deleteCommentError, result.errorOrNull!.message));
      }
    } on Object catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.deleteCommentError, e.toString()));
    }
  }
}
