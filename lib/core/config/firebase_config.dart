/// Firebase collection and field configuration.
///
/// This class follows the Interface Segregation Principle (ISP) by separating
/// Firebase-specific configuration from general app configuration.
///
/// ## Purpose
/// - Provides a single source of truth for all Firebase collection names
/// - Enables easy refactoring of database schema
/// - Prevents typos in collection and field names
///
/// ## Usage
/// ```dart
/// final collection = firestore.collection(FirebaseConfig.collections.users);
/// final field = FirebaseConfig.fields.displayName;
/// ```
abstract final class FirebaseConfig {
  FirebaseConfig._();

  /// Collection name configuration
  static const collections = _FirebaseCollections();

  /// Field name configuration
  static const fields = _FirebaseFields();

  /// Document path helpers
  static const paths = _FirebasePaths();
}

/// Firebase collection names.
///
/// All collection names are centralized here to prevent typos and allow
/// easy schema modifications.
class _FirebaseCollections {
  const _FirebaseCollections();

  // ==================== Core Collections ====================
  /// Users collection - stores user profiles
  String get users => 'users';

  /// Consents collection - stores parental consent forms
  String get consents => 'consents';

  /// Notifications collection - stores user notifications
  String get notifications => 'notifications';

  /// Settings collection - stores app configuration
  String get settings => 'settings';

  // ==================== Content Collections ====================
  /// Forum collection - stores forum posts
  String get forum => 'forum';

  /// Comments subcollection name (used under forum documents)
  String get comments => 'comments';

  /// Carousel items collection - stores home page carousel
  String get carouselItems => 'carousel_items';

  // ==================== Learning Collections ====================
  /// Learn collection - stores learning categories
  String get learn => 'learn';

  /// Videos collection - stores educational videos
  String get videos => 'videos';

  /// Resources collection - stores external resources
  String get resources => 'resources';

  /// Recommendations collection - stores personalized recommendations
  String get recommendations => 'recommendations';

  // ==================== Quiz Collections ====================
  /// Quizzes collection - stores quiz definitions
  String get quizzes => 'quizes';

  /// Quiz questions collection - stores quiz questions
  String get quizQuestions => 'quiz_questions';

  /// Quiz results collection - stores user quiz results
  String get quizResults => 'quiz_results';

  // ==================== Reports Collection ====================
  /// Reports collection - stores user reports
  String get reports => 'reports';
}

/// Firebase document field names.
///
/// Centralizes all field names to ensure consistency across the application.
class _FirebaseFields {
  const _FirebaseFields();

  // ==================== User Fields ====================
  String get uid => 'uid';
  String get email => 'email';
  String get displayName => 'displayName';
  String get photoURL => 'photoURL';
  String get role => 'role';
  String get emailVerified => 'emailVerified';

  // ==================== Consent Fields ====================
  String get parentName => 'parentName';
  String get parentEmail => 'parentEmail';
  String get childName => 'childName';
  String get isChildAbove12 => 'isChildAbove12';
  String get parentalKey => 'parentalKey';
  String get securityQuestion => 'securityQuestion';
  String get securityAnswer => 'securityAnswer';
  String get consentCheckboxes => 'consentCheckboxes';

  // ==================== Forum Fields ====================
  String get id => 'id';
  String get userId => 'userId';
  String get title => 'title';
  String get description => 'description';
  String get category => 'category';
  String get text => 'text';
  String get forumId => 'forumId';

  // ==================== Content Fields ====================
  String get type => 'type';
  String get imageUrl => 'imageUrl';
  String get link => 'link';
  String get thumbnailUrl => 'thumbnailUrl';
  String get content => 'content';
  String get order => 'order';
  String get isActive => 'isActive';
  String get name => 'name';
  String get thumbnail => 'thumbnail';
  String get videoUrl => 'videoUrl';
  String get url => 'url';

  // ==================== Recommendation Fields ====================
  /// Note: Recommendations use 'UID' (uppercase) for user ID
  String get recommendationUserId => 'UID';

  /// Note: Recommendations use 'video' instead of 'videoUrl'
  String get recommendationVideoUrl => 'video';

  // ==================== Timestamp Fields ====================
  String get createdAt => 'createdAt';
  String get updatedAt => 'updatedAt';
  String get timestamp => 'timestamp';
  String get lastUpdated => 'lastUpdated';

  // ==================== Notification Fields ====================
  String get message => 'message';
  String get read => 'read';

  // ==================== Quiz Fields ====================
  String get quizId => 'quizId';
  String get question => 'question';
  String get options => 'options';
  String get correctAnswer => 'correctAnswer';
  String get explanation => 'explanation';
  String get score => 'score';
  String get totalQuestions => 'totalQuestions';
  String get completedAt => 'completedAt';
}

/// Firebase document path helpers.
///
/// Provides methods to construct document and collection paths.
class _FirebasePaths {
  const _FirebasePaths();

  /// Get the path to a user document
  String userDoc(String uid) => 'users/$uid';

  /// Get the path to a consent document
  String consentDoc(String uid) => 'consents/$uid';

  /// Get the path to a forum document
  String forumDoc(String forumId) => 'forum/$forumId';

  /// Get the path to forum comments collection
  String forumComments(String forumId) => 'forum/$forumId/comments';

  /// Get the path to a specific comment
  String commentDoc(String forumId, String commentId) =>
      'forum/$forumId/comments/$commentId';

  /// Get the path to a video document
  String videoDoc(String videoId) => 'videos/$videoId';

  /// Get the path to a notification document
  String notificationDoc(String notifId) => 'notifications/$notifId';
}
