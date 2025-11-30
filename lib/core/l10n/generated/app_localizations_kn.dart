// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಗಾರ್ಡಿಯನ್ ಕೇರ್';

  @override
  String get home => 'ಮುಖಪುಟ';

  @override
  String get learn => 'ಕಲಿಯಿರಿ';

  @override
  String get explore => 'ಅನ್ವೇಷಿಸಿ';

  @override
  String get forum => 'ವೇದಿಕೆ';

  @override
  String get profile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get login => 'ಲಾಗಿನ್';

  @override
  String get signup => 'ಸೈನ್ ಅಪ್';

  @override
  String get email => 'ಇಮೇಲ್';

  @override
  String get password => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get forgotPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರುವಿರಾ?';

  @override
  String get logout => 'ಲಾಗ್ಔಟ್';

  @override
  String get settings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get changeLanguage => 'ಭಾಷೆ ಬದಲಾಯಿಸಿ';

  @override
  String get selectLanguage => 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get account => 'ಖಾತೆ';

  @override
  String get emergencyContact => 'ತುರ್ತು ಸಂಪರ್ಕ';

  @override
  String get quiz => 'ಕ್ವಿಜ್';

  @override
  String get videos => 'ವೀಡಿಯೊಗಳು';

  @override
  String get resources => 'ಸಂಪನ್ಮೂಲಗಳು';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get confirm => 'ದೃಢೀಕರಿಸಿ';

  @override
  String get yes => 'ಹೌದು';

  @override
  String get no => 'ಇಲ್ಲ';

  @override
  String get loading => 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...';

  @override
  String get error => 'ದೋಷ';

  @override
  String get success => 'ಯಶಸ್ಸು';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಐಟಂಗಳು',
      one: '1 ಐಟಂ',
      zero: 'ಯಾವುದೇ ಐಟಂಗಳಿಲ್ಲ',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'ಸ್ವಾಗತ';

  @override
  String welcomeUser(String name) {
    return 'ಸ್ವಾಗತ, $name!';
  }

  @override
  String get emergency => 'ತುರ್ತು';

  @override
  String get website => 'ವೆಬ್‌ಸೈಟ್';

  @override
  String get mailUs => 'ನಮಗೆ ಮೇಲ್ ಮಾಡಿ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get next => 'ಮುಂದೆ';

  @override
  String get submit => 'ಸಲ್ಲಿಸಿ';

  @override
  String get deleteAccount => 'ಖಾತೆಯನ್ನು ಅಳಿಸಿ';

  @override
  String get deleteAccountConfirm =>
      'ನೀವು ನಿಮ್ಮ ಖಾತೆಯನ್ನು ಅಳಿಸಲು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ? ಈ ಕ್ರಿಯೆಯನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get accountDeletedSuccess => 'ಖಾತೆಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಅಳಿಸಲಾಗಿದೆ';

  @override
  String get logoutConfirm => 'ನೀವು ಲಾಗ್ ಔಟ್ ಮಾಡಲು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ?';

  @override
  String get deleteMyAccount => 'ನನ್ನ ಖಾತೆಯನ್ನು ಅಳಿಸಿ';

  @override
  String get noUserSignedIn => 'ಪ್ರಸ್ತುತ ಯಾವುದೇ ಬಳಕೆದಾರರು ಸೈನ್ ಇನ್ ಆಗಿಲ್ಲ';

  @override
  String get loadingProfile => 'ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ...';

  @override
  String get nameLabel => 'ಹೆಸರು';

  @override
  String get emailLabel => 'ಇಮೇಲ್';

  @override
  String get accountSettings => 'ಖಾತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get editProfile => 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ';

  @override
  String get changePassword => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಾಯಿಸಿ';

  @override
  String get notificationSettings => 'ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get privacySettings => 'ಗೌಪ್ಯತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get helpSupport => 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ';

  @override
  String get aboutApp => 'ಅಪ್ಲಿಕೇಶನ್ ಬಗ್ಗೆ';

  @override
  String get logoutMessage => 'ನೀವು ಲಾಗ್ ಔಟ್ ಮಾಡಲು ಖಚಿತವಾಗಿ ಬಯಸುವಿರಾ?';

  @override
  String get deleteAccountWarning =>
      'ಈ ಕ್ರಿಯೆಯನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗುವುದಿಲ್ಲ. ನಿಮ್ಮ ಎಲ್ಲಾ ಡೇಟಾವನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get childSafetySettings => 'ಮಕ್ಕಳ ಸುರಕ್ಷತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String languageChangedRestarting(String language) {
    return 'ಭಾಷೆಯನ್ನು $languageಗೆ ಬದಲಾಯಿಸಲಾಗಿದೆ. ಅಪ್ಲಿಕೇಶನ್ ಮರುಪ್ರಾರಂಭಿಸುತ್ತಿದೆ...';
  }

  @override
  String get emergencyServices => 'ತುರ್ತು ಸೇವೆಗಳು';

  @override
  String get childSafety => 'ಮಕ್ಕಳ ಸುರಕ್ಷತೆ';

  @override
  String get loadingEmergencyContacts =>
      'ತುರ್ತು ಸಂಪರ್ಕಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...';

  @override
  String get noQuizzesAvailable => 'ಯಾವುದೇ ಕ್ವಿಜ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get quizQuestions => 'ಕ್ವಿಜ್ ಪ್ರಶ್ನೆಗಳು';

  @override
  String questionOf(int current, int total) {
    return 'ಪ್ರಶ್ನೆ $current ರ $total';
  }

  @override
  String get previous => 'ಹಿಂದಿನ';

  @override
  String get finish => 'ಮುಗಿಸಿ';

  @override
  String get quizCompleted => 'ಕ್ವಿಜ್ ಪೂರ್ಣಗೊಂಡಿದೆ!';

  @override
  String youScored(int score, int total) {
    return 'ನೀವು $total ರಲ್ಲಿ $score ಅಂಕಗಳನ್ನು ಗಳಿಸಿದ್ದೀರಿ';
  }

  @override
  String get generatingRecommendations =>
      'ವೈಯಕ್ತಿಕ ಶಿಫಾರಸುಗಳನ್ನು ರಚಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get checkExploreTab =>
      'ನಿಮ್ಮ ಶಿಫಾರಸುಗಳನ್ನು ನೋಡಲು ಎಕ್ಸ್‌ಪ್ಲೋರ್ ಟ್ಯಾಬ್ ಪರಿಶೀಲಿಸಿ!';

  @override
  String get backToQuizzes => 'ಕ್ವಿಜ್‌ಗಳಿಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get viewRecommendations => 'ಶಿಫಾರಸುಗಳನ್ನು ವೀಕ್ಷಿಸಿ';

  @override
  String get noCategoriesAvailable => 'ಯಾವುದೇ ವರ್ಗಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get noVideosAvailable => 'ಯಾವುದೇ ವೀಡಿಯೊಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get forums => 'ವೇದಿಕೆಗಳು';

  @override
  String get forumDiscussion => 'ವೇದಿಕೆ ಚರ್ಚೆ';

  @override
  String get parentForums => 'ಪೋಷಕರ ವೇದಿಕೆಗಳು';

  @override
  String get noForumsAvailable => 'ಯಾವುದೇ ವೇದಿಕೆಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get noCommentsYet => 'ಇನ್ನೂ ಯಾವುದೇ ಕಾಮೆಂಟ್‌ಗಳಿಲ್ಲ. ಮೊದಲ ಕಾಮೆಂಟ್ ಮಾಡಿ!';

  @override
  String get commentPostedSuccess => 'ಕಾಮೆಂಟ್ ಯಶಸ್ವಿಯಾಗಿ ಪೋಸ್ಟ್ ಮಾಡಲಾಗಿದೆ!';

  @override
  String get commentSubmittedSuccess => 'ಕಾಮೆಂಟ್ ಯಶಸ್ವಿಯಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ!';

  @override
  String get pleaseEnterComment => 'ದಯವಿಟ್ಟು ಕಾಮೆಂಟ್ ನಮೂದಿಸಿ';

  @override
  String get commentMinLength => 'ಕಾಮೆಂಟ್ ಕನಿಷ್ಠ 2 ಅಕ್ಷರಗಳಾಗಿರಬೇಕು';

  @override
  String get pullToRefresh => 'ರಿಫ್ರೆಶ್ ಮಾಡಲು ಎಳೆಯಿರಿ';

  @override
  String get pullDownToRefresh => 'ರಿಫ್ರೆಶ್ ಮಾಡಲು ಕೆಳಗೆ ಎಳೆಯಿರಿ';

  @override
  String get somethingWentWrong => 'ಏನೋ ತಪ್ಪಾಗಿದೆ';

  @override
  String get recommendedForYou => 'ನಿಮಗಾಗಿ ಶಿಫಾರಸು ಮಾಡಲಾಗಿದೆ';

  @override
  String get takeAQuiz => 'ಕ್ವಿಜ್ ತೆಗೆದುಕೊಳ್ಳಿ';

  @override
  String get noRecommendationsYet => 'ಇನ್ನೂ ಯಾವುದೇ ಶಿಫಾರಸುಗಳಿಲ್ಲ';

  @override
  String get takeQuizForRecommendations =>
      'ನಿಮ್ಮ ಆಸಕ್ತಿಗಳ ಆಧಾರದ ಮೇಲೆ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ವೀಡಿಯೊ ಶಿಫಾರಸುಗಳನ್ನು ಪಡೆಯಲು ಕ್ವಿಜ್ ತೆಗೆದುಕೊಳ್ಳಿ!';

  @override
  String get loginToViewRecommendations =>
      'ಶಿಫಾರಸುಗಳನ್ನು ವೀಕ್ಷಿಸಲು ದಯವಿಟ್ಟು ಲಾಗಿನ್ ಮಾಡಿ';

  @override
  String get agreeToTerms => 'ನಾನು ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳನ್ನು ಒಪ್ಪುತ್ತೇನೆ';

  @override
  String get pleaseAgreeToTerms =>
      'ದಯವಿಟ್ಟು ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳನ್ನು ಒಪ್ಪಿಕೊಳ್ಳಿ';

  @override
  String get isChildAbove12 => 'ಮಗು 12 ವರ್ಷಕ್ಕಿಂತ ಹೆಚ್ಚು ವಯಸ್ಸಿನವರೇ?';

  @override
  String get parentalKeyMinLength => 'ಪೋಷಕರ ಕೀ ಕನಿಷ್ಠ 4 ಅಕ್ಷರಗಳಾಗಿರಬೇಕು';

  @override
  String get incorrectAnswer => 'ತಪ್ಪು ಉತ್ತರ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get parentalKeyResetSuccess => 'ಪೋಷಕರ ಕೀ ಯಶಸ್ವಿಯಾಗಿ ರೀಸೆಟ್ ಮಾಡಲಾಗಿದೆ!';

  @override
  String get parentGuardian => 'ಪೋಷಕರು/ಪಾಲಕರು';

  @override
  String get child => 'ಮಗು';

  @override
  String get couldNotLaunchEmail =>
      'ಇಮೇಲ್ ಕ್ಲೈಂಟ್ ಅನ್ನು ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String errorLaunchingEmail(String error) {
    return 'ಇಮೇಲ್ ಪ್ರಾರಂಭಿಸುವಲ್ಲಿ ದೋಷ: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'ದೋಷ: $error';
  }

  @override
  String get noResourcesAvailable => '??? ??????? ??????';
}
