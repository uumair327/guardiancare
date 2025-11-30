// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Guardian Care';

  @override
  String get home => 'Home';

  @override
  String get learn => 'Learn';

  @override
  String get explore => 'Explore';

  @override
  String get forum => 'Forum';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get signup => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get account => 'Account';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get quiz => 'Quiz';

  @override
  String get videos => 'Videos';

  @override
  String get resources => 'Resources';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get emergency => 'Emergency';

  @override
  String get website => 'Website';

  @override
  String get mailUs => 'Mail Us';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get deleteMyAccount => 'Delete My Account';

  @override
  String get noUserSignedIn => 'No user is currently signed in';

  @override
  String get loadingProfile => 'Loading profile...';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get aboutApp => 'About App';

  @override
  String get logoutMessage => 'Are you sure you want to log out?';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get childSafetySettings => 'Child Safety Settings';

  @override
  String languageChangedRestarting(String language) {
    return 'Language changed to $language. Restarting app...';
  }

  @override
  String get emergencyServices => 'Emergency Services';

  @override
  String get childSafety => 'Child Safety';

  @override
  String get loadingEmergencyContacts => 'Loading emergency contacts...';

  @override
  String get noQuizzesAvailable => 'No quizzes available';

  @override
  String get quizQuestions => 'Quiz Questions';

  @override
  String questionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get finish => 'Finish';

  @override
  String get quizCompleted => 'Quiz Completed!';

  @override
  String youScored(int score, int total) {
    return 'You scored $score out of $total';
  }

  @override
  String get generatingRecommendations =>
      'Generating Personalized Recommendations';

  @override
  String get checkExploreTab =>
      'Check the Explore tab to see your recommendations!';

  @override
  String get backToQuizzes => 'Back to Quizzes';

  @override
  String get viewRecommendations => 'View Recommendations';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get noVideosAvailable => 'No videos available';

  @override
  String get forums => 'Forums';

  @override
  String get forumDiscussion => 'Forum Discussion';

  @override
  String get parentForums => 'Parent Forums';

  @override
  String get noForumsAvailable => 'No forums available';

  @override
  String get noCommentsYet => 'No comments yet. Be the first to comment!';

  @override
  String get commentPostedSuccess => 'Comment posted successfully!';

  @override
  String get commentSubmittedSuccess => 'Comment submitted successfully!';

  @override
  String get pleaseEnterComment => 'Please enter a comment';

  @override
  String get commentMinLength => 'Comment must be at least 2 characters';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get pullDownToRefresh => 'Pull down to refresh';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get takeAQuiz => 'Take a Quiz';

  @override
  String get noRecommendationsYet => 'No Recommendations Yet';

  @override
  String get takeQuizForRecommendations =>
      'Take a quiz to get personalized video recommendations based on your interests!';

  @override
  String get loginToViewRecommendations =>
      'Please log in to view recommendations';

  @override
  String get agreeToTerms => 'I agree to the terms and conditions';

  @override
  String get pleaseAgreeToTerms => 'Please agree to the terms and conditions';

  @override
  String get isChildAbove12 => 'Is child above 12 years old?';

  @override
  String get parentalKeyMinLength =>
      'Parental key must be at least 4 characters';

  @override
  String get incorrectAnswer => 'Incorrect answer. Please try again.';

  @override
  String get parentalKeyResetSuccess => 'Parental key reset successfully!';

  @override
  String get parentGuardian => 'Parent/Guardian';

  @override
  String get child => 'Child';

  @override
  String get couldNotLaunchEmail => 'Could not launch email client';

  @override
  String errorLaunchingEmail(String error) {
    return 'Error launching email: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get noResourcesAvailable => 'No resources available';
}
