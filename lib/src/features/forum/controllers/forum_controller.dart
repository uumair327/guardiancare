import 'package:guardiancare/src/features/forum/forum_service.dart';
import 'package:guardiancare/src/features/forum/models/comment.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';

class ForumController {
  final ForumService _forumService = ForumService();

  Stream<List<Forum>> getForums() => _forumService.getForums();

  Future<void> addForum(String title, String description) =>
      _forumService.addForum(title, description);

  Stream<List<Comment>> getComments(String forumId) =>
      _forumService.getComments(forumId);

  Future<void> addComment(String forumId, String text) =>
      _forumService.addComment(forumId, text);
}
