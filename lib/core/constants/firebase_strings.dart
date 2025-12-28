/// Firebase collection and document name constants for the GuardianCare application.
///
/// This class provides a single source of truth for all Firebase Firestore
/// collection names and document field names used throughout the application.
///
/// ## Purpose
/// - Ensures consistent Firebase collection/field naming
/// - Prevents typos in collection and field names
/// - Simplifies database schema changes
/// - Provides clear documentation of database structure
///
/// ## Categories
/// - **Collections**: Firestore collection names
/// - **User Document Fields**: User profile field names
/// - **Common Document Fields**: Shared field names (timestamps, IDs)
/// - **Content Document Fields**: Content-related field names
/// - **Forum/Comment Fields**: Forum and comment field names
/// - **Quiz/Report Fields**: Quiz and report field names
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // Accessing a collection
/// final usersCollection = FirebaseFirestore.instance
///     .collection(FirebaseStrings.users);
///
/// // Creating a document with field names
/// await usersCollection.doc(userId).set({
///   FirebaseStrings.fieldName: name,
///   FirebaseStrings.fieldEmail: email,
///   FirebaseStrings.fieldRole: role,
///   FirebaseStrings.fieldCreatedAt: FieldValue.serverTimestamp(),
/// });
///
/// // Querying with field names
/// final query = usersCollection
///     .where(FirebaseStrings.fieldRole, isEqualTo: 'parent')
///     .orderBy(FirebaseStrings.fieldCreatedAt, descending: true);
/// ```
///
/// ## Best Practices
/// - Always use FirebaseStrings for collection and field names
/// - Never hardcode collection or field names in code
/// - Update this file when database schema changes
/// - Use consistent naming conventions (camelCase for fields)
///
/// See also:
/// - [ApiStrings] for external API constants
/// - [AppStrings] for app-level constants
class FirebaseStrings {
  FirebaseStrings._();

  // ==================== Collections ====================
  static const String users = 'users';
  static const String carouselItems = 'carousel_items';
  static const String forumPosts = 'forum_posts';
  static const String comments = 'comments';
  static const String recommendations = 'recommendations';
  static const String reports = 'reports';
  static const String quizResults = 'quiz_results';
  static const String videos = 'videos';
  static const String categories = 'categories';
  static const String notifications = 'notifications';
  static const String settings = 'settings';

  // ==================== User Document Fields ====================
  static const String fieldUserId = 'userId';
  static const String fieldEmail = 'email';
  static const String fieldName = 'name';
  static const String fieldDisplayName = 'displayName';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldRole = 'role';
  static const String fieldAge = 'age';
  static const String fieldGrade = 'grade';

  // ==================== Common Document Fields ====================
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldCreatedBy = 'createdBy';
  static const String fieldUpdatedBy = 'updatedBy';
  static const String fieldIsActive = 'isActive';
  static const String fieldIsDeleted = 'isDeleted';

  // ==================== Content Document Fields ====================
  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldContent = 'content';
  static const String fieldImageUrl = 'imageUrl';
  static const String fieldVideoUrl = 'videoUrl';
  static const String fieldThumbnailUrl = 'thumbnailUrl';
  static const String fieldCategory = 'category';
  static const String fieldTags = 'tags';
  static const String fieldOrder = 'order';

  // ==================== Forum/Comment Fields ====================
  static const String fieldAuthorId = 'authorId';
  static const String fieldAuthorName = 'authorName';
  static const String fieldPostId = 'postId';
  static const String fieldParentId = 'parentId';
  static const String fieldLikes = 'likes';
  static const String fieldReplies = 'replies';
  static const String fieldReplyCount = 'replyCount';

  // ==================== Quiz/Report Fields ====================
  static const String fieldScore = 'score';
  static const String fieldTotalQuestions = 'totalQuestions';
  static const String fieldCorrectAnswers = 'correctAnswers';
  static const String fieldCompletedAt = 'completedAt';
  static const String fieldStatus = 'status';
  static const String fieldType = 'type';
}
