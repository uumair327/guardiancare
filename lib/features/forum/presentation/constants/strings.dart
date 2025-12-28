/// Forum feature-specific strings for the GuardianCare application.
///
/// This class provides string constants specific to the Forum feature,
/// following Clean Architecture principles by keeping feature-specific
/// strings within the feature module.
///
/// ## Purpose
/// - Centralizes all forum-related text constants
/// - Keeps forum strings isolated from other features
/// - Simplifies forum UI development
/// - Supports future localization efforts
///
/// ## Categories
/// - **Page Titles**: Forum page and section titles
/// - **Tab Labels**: Tab navigation labels
/// - **Category Labels**: Forum category names
/// - **Header Subtitles**: Section header descriptions
/// - **Guidelines Content**: Forum rules and guidelines
/// - **Comment Section**: Comment-related labels
/// - **Actions**: Forum action button labels
/// - **Error States**: Forum-specific error messages
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/features/forum/presentation/constants/strings.dart';
///
/// // Page title
/// AppBar(title: Text(ForumStrings.pageTitle));
///
/// // Tab labels
/// Tab(text: ForumStrings.forChildren);
/// Tab(text: ForumStrings.parentForums);
///
/// // Comment count with template method
/// Text(ForumStrings.commentCount(5)); // "5 Comments"
///
/// // Relative time
/// Text(ForumStrings.minutesAgo(10)); // "10 minutes ago"
/// ```
///
/// ## Best Practices
/// - Use ForumStrings only within the forum feature
/// - For common UI text, use [UIStrings] instead
/// - For feedback messages, use [FeedbackStrings]
/// - Keep forum-specific text in this class
///
/// See also:
/// - [UIStrings] for common UI text
/// - [FeedbackStrings] for SnackBar/toast messages
/// - [ErrorStrings] for error messages
class ForumStrings {
  ForumStrings._();

  // ==================== Page Titles ====================
  static const String pageTitle = 'Forum';
  static const String guidelinesTitle = 'Forum Guidelines';
  static const String discussionTitle = 'Discussion';

  // ==================== Tab Labels ====================
  static const String forChildren = 'For Children';
  static const String parentForums = 'Parent Forums';

  // ==================== Category Labels ====================
  static const String communityDiscussion = 'Community Discussion';
  static const String discussion = 'Discussion';
  static const String family = 'Family';

  // ==================== Header Subtitles ====================
  static const String connectAndShare = 'Connect and share experiences';
  static const String beFirstToDiscuss = 'Be the first to start a discussion!';
  static const String beFirstToComment = 'Be the first to share your thoughts!';
  static const String startTypingBelow = 'Start typing below';

  // ==================== Guidelines Content ====================
  static const String guidelinesWelcome =
      'Welcome to the GuardianCare Forum. Please follow these guidelines:';
  static const String guidelineRespect =
      'Be respectful and courteous to all members.';
  static const String guidelineNoAbuse =
      'Do not use abusive, harassing, or harmful language.';
  static const String guidelineNoHarmful =
      'Avoid sharing inappropriate or harmful content.';
  static const String guidelineConstructive =
      'This is a space for constructive discussions on child safety.';

  // ==================== Comment Section ====================
  static const String noCommentsYet = 'No comments yet';
  static const String shareYourThoughts = 'Share your thoughts...';
  static const String beRespectful = 'Be respectful and constructive';
  static const String member = 'Member';

  // ==================== Actions ====================
  static const String postComment = 'Post Comment';
  static const String replyToComment = 'Reply';
  static const String tapToJoin = 'Tap to join';

  // ==================== Error States ====================
  static const String somethingWentWrong = 'Something went wrong';

  // ==================== Template Methods ====================
  /// Creates a comment count string
  static String commentCount(int count) =>
      '$count ${count == 1 ? 'Comment' : 'Comments'}';

  /// Creates a relative time string for days ago
  static String daysAgo(int days) => '$days days ago';

  /// Creates a relative time string for hours ago
  static String hoursAgo(int hours) => '$hours hours ago';

  /// Creates a relative time string for minutes ago
  static String minutesAgo(int minutes) => '$minutes minutes ago';
}
