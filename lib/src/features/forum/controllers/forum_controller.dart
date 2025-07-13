import 'package:guardiancare/src/features/forum/forum_service.dart';
import 'package:guardiancare/src/features/forum/models/comment.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';

class ForumController {
  final ForumService _service = ForumService();

  Stream<List<Forum>> getForums(ForumCategory category) =>
      _service.getForums(category);

  Stream<List<Comment>> getComments(String forumId) =>
      _service.getComments(forumId);

  Future<void> addComment(String forumId, String text) =>
      _service.addComment(forumId, text);
}
