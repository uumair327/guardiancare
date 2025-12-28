/// UI text constants (labels, buttons, titles) for the GuardianCare application.
///
/// This class provides a single source of truth for all common UI text elements
/// used throughout the application, ensuring visual and textual consistency.
///
/// ## Purpose
/// - Ensures consistent UI text across all screens
/// - Simplifies UI development with ready-to-use text constants
/// - Enables easy updates to UI text without code changes
/// - Supports future localization efforts
///
/// ## Categories
/// - **Common Buttons**: OK, Cancel, Save, Submit, etc.
/// - **Authentication Buttons**: Sign In, Sign Out, Sign Up, etc.
/// - **Agreement Buttons**: I Agree, Accept, Decline
/// - **Common Labels**: Email, Password, Name, etc.
/// - **Role Labels**: Child, Parent, Teacher, Guardian
/// - **Common Titles**: Loading, Error, Success, Warning
/// - **Time-based Greetings**: Good Morning, Good Afternoon, Good Evening
/// - **Relative Time**: Just now, minutes ago, hours ago
/// - **Content States**: No data, Empty, Content unavailable
/// - **Actions**: Show more, See All, Share, Download
/// - **Explore Page Labels**: Discovery and learning labels
/// - **Profile/Account Labels**: Account management labels
/// - **Quiz Feedback**: Quiz result messages
/// - **Placeholders**: Search hints, input placeholders
/// - **Consent Form Labels**: Parental consent form labels
///
/// ## Usage Example
/// ```dart
/// import 'package:guardiancare/core/constants/constants.dart';
///
/// // Button text
/// ElevatedButton(
///   onPressed: onSubmit,
///   child: Text(UIStrings.submit),
/// );
///
/// // Title text
/// AppBar(title: Text(UIStrings.settings));
///
/// // Time-based greeting
/// Text(getGreeting()); // Uses UIStrings.goodMorning, etc.
///
/// // Template methods for dynamic text
/// Text(UIStrings.minutesAgo(5)); // "5m ago"
/// Text(UIStrings.itemCount(3, 'comment')); // "3 comments"
/// ```
///
/// ## Best Practices
/// - Use UIStrings for non-localized UI text
/// - For localized text, use AppLocalizations instead
/// - Use template methods for dynamic text with counts or times
/// - Keep button text concise and action-oriented
///
/// See also:
/// - [FeedbackStrings] for SnackBar/toast messages
/// - [ValidationStrings] for form validation messages
/// - [AppStrings] for app-level constants (URLs, keys)
class UIStrings {
  UIStrings._();

  // ==================== Common Buttons ====================
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String goBack = 'Go Back';
  static const String submit = 'Submit';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String tryAgain = 'Try Again';
  static const String close = 'Close';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String continueText = 'Continue';
  static const String skip = 'Skip';
  static const String refresh = 'Refresh';

  // ==================== Authentication Buttons ====================
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String signUp = 'Sign Up';
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';

  // ==================== Agreement Buttons ====================
  static const String iAgree = 'I Agree';
  static const String accept = 'Accept';
  static const String decline = 'Decline';

  // ==================== Common Labels ====================
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String name = 'Name';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String description = 'Description';
  static const String title = 'Title';
  static const String message = 'Message';
  static const String comment = 'Comment';

  // ==================== Role Labels ====================
  static const String child = 'Child';
  static const String parent = 'Parent';
  static const String parentGuardian = 'Parent/Guardian';
  static const String teacher = 'Teacher';
  static const String guardian = 'Guardian';

  // ==================== Common Titles ====================
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Information';
  static const String alert = 'Alert';
  static const String notification = 'Notification';
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String account = 'Account';
  static const String help = 'Help';
  static const String about = 'About';
  static const String dangerZone = 'Danger Zone';
  static const String oopsSomethingWentWrong = 'Oops! Something went wrong';

  // ==================== Time-based Greetings ====================
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String welcome = 'Welcome';
  static const String welcomeBack = 'Welcome Back';

  // ==================== Relative Time ====================
  static const String justNow = 'Just now';
  static const String today = 'Today';
  static const String yesterday = 'Yesterday';


  // ==================== Content States ====================
  static const String noData = 'No data available.';
  static const String empty = 'Nothing here yet.';
  static const String contentUnavailable = 'Content unavailable';
  static const String imageUnavailable = 'Image unavailable';
  static const String noResults = 'No results found.';
  static const String noItems = 'No items to display.';
  static const String comingSoon = 'Coming soon';

  // ==================== Actions ====================
  static const String showMore = 'Show more';
  static const String showLess = 'Show less';
  static const String seeAll = 'See All';
  static const String viewAll = 'View All';
  static const String readMore = 'Read more';
  static const String learnMore = 'Learn more';
  static const String share = 'Share';
  static const String copy = 'Copy';
  static const String download = 'Download';
  static const String upload = 'Upload';
  static const String tapToExplore = 'Tap to explore';
  static const String startQuiz = 'Start Quiz';

  // ==================== Explore Page Labels ====================
  static const String discoverLearningResources = 'Discover learning resources';
  static const String recommended = 'Recommended';
  static const String learningCategories = 'Learning Categories';
  static const String videos = 'Videos';
  static const String topics = 'topics';
  static const String checkBackLater = 'Check back later for new content';
  static const String newVideosComingSoon = 'New videos coming soon!';
  static const String checkBackLaterQuizzes = 'Check back later for new quizzes!';

  // ==================== Carousel Labels ====================
  static const String learn = 'Learn';
  static const String watchVideo = 'Watch Video';
  static const String interactiveContent = 'Interactive Content';
  static const String readArticle = 'Read Article';

  // ==================== Profile/Account Labels ====================
  static const String setUpEmergencyContacts = 'Set up emergency contacts';
  static const String signOutOfYourAccount = 'Sign out of your account';
  static const String permanentlyDeleteAccount = 'Permanently delete your account';
  static const String quizzes = 'Quizzes';
  static const String badges = 'Badges';
  static const String correct = 'Correct';
  static const String wrong = 'Wrong';
  static const String total = 'Total';
  static const String score = 'Score';
  static const String tryAgainButton = 'Try Again';
  static const String quizComplete = 'Quiz Complete';

  // ==================== Quiz Feedback Messages ====================
  static const String excellentFeedback = 'Excellent! 🎉';
  static const String greatJobFeedback = 'Great Job! 👏';
  static const String goodEffortFeedback = 'Good Effort! 💪';
  static const String keepLearningFeedback = 'Keep Learning! 📚';
  static const String quizMasterMessage = "You're a quiz master!";
  static const String doingGreatMessage = "You're doing great!";
  static const String onRightTrackMessage = "You're on the right track!";
  static const String practiceMessage = 'Practice makes perfect!';

  // ==================== Placeholders ====================
  static const String searchHint = 'Search...';
  static const String enterText = 'Enter text...';
  static const String typeHere = 'Type here...';
  static const String writeComment = 'Write a comment...';

  // ==================== Consent Form Labels ====================
  static const String parentInformation = 'Parent Information';
  static const String parentEmail = 'Parent Email';
  static const String childName = 'Child Name';
  static const String isChildAbove12 = 'Is child above 12 years old?';
  static const String setParentalKey = 'Set Parental Key';
  static const String parentalKey = 'Parental Key';
  static const String confirmParentalKey = 'Confirm Parental Key';
  static const String newParentalKey = 'New Parental Key';
  static const String confirmNewKey = 'Confirm New Key';
  static const String securityQuestion = 'Security Question';
  static const String selectSecurityQuestion = 'Select Security Question';
  static const String yourAnswer = 'Your Answer';
  static const String parentalConsentSetup = 'Parental Consent Setup';
  static const String protectYourChild = 'Protect your child with parental controls';
  static const String parentalKeyDescription = 'This key will be used to access restricted features like the forum.';
  static const String securityQuestionDescription = 'This will help you recover your parental key if you forget it.';
  static const String agreeToTerms = 'I agree to the terms and conditions';
  static const String answerSecurityQuestion = 'Answer Security Question';
  static const String setNewParentalKey = 'Set New Parental Key';
  static const String forgotParentalKey = 'Forgot Parental Key';
  static const String verify = 'Verify';
  static const String resetKey = 'Reset Key';

  // ==================== Hint Text ====================
  static const String parentEmailHint = 'parent@example.com';
  static const String childNameHint = "Enter child's name";
  static const String minCharactersHint = 'Min 4 characters';
  static const String reenterKeyHint = 'Re-enter your key';
  static const String enterAnswerHint = 'Enter your answer';

  // ==================== Template Methods ====================
  /// Creates a relative time string for minutes ago
  static String minutesAgo(int minutes) => '${minutes}m ago';

  /// Creates a relative time string for hours ago
  static String hoursAgo(int hours) => '${hours}h ago';

  /// Creates a relative time string for days ago
  static String daysAgo(int days) => '${days}d ago';

  /// Creates a relative time string for weeks ago
  static String weeksAgo(int weeks) => '${weeks}w ago';

  /// Creates a count display string
  static String itemCount(int count, String item) =>
      count == 1 ? '1 $item' : '$count ${item}s';
}
