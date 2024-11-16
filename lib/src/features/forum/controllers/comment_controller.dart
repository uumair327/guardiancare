import 'package:guardiancare/src/features/forum/forum_service.dart';

class CommentController {
  final ForumService _forumService = ForumService();

  Future<void> addComment(String forumId, String text) =>
      _forumService.addComment(forumId, text);
}
