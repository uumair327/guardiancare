import 'package:guardiancare/src/features/forum/forum_service.dart';

class CommentController {
  final ForumService _service = ForumService();
  Future<void> addComment(String forumId, String text) =>
      _service.addComment(forumId, text);
}
