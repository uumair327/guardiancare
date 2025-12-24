import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Guardian Care'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Learn tab label
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// Explore tab label
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Forum tab label
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get forum;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Change language option
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Account page title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Emergency contact label
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// Quiz label
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// Videos label
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// Resources label
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message prefix
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message prefix
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Number of items with plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeUser(String name);

  /// Emergency button label
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// Website button label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Mail us button label
  ///
  /// In en, this message translates to:
  /// **'Mail Us'**
  String get mailUs;

  /// Guest user label
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Welcome message on home page
  ///
  /// In en, this message translates to:
  /// **'Empowering children and families with safety knowledge'**
  String get homeWelcomeMessage;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirm;

  /// Account deletion success message
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// Delete my account button text
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No user signed in message
  ///
  /// In en, this message translates to:
  /// **'No user is currently signed in'**
  String get noUserSignedIn;

  /// Loading profile message
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get loadingProfile;

  /// Name label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Account settings menu item
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Edit profile menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Change password menu item
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Notification settings menu item
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Privacy settings menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// About app menu item
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Logout confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutMessage;

  /// Delete account warning message
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAccountWarning;

  /// Child safety settings section title
  ///
  /// In en, this message translates to:
  /// **'Child Safety Settings'**
  String get childSafetySettings;

  /// Language change notification with restart message
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}. Restarting app...'**
  String languageChangedRestarting(String language);

  /// Emergency services section title
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// Child safety section title
  ///
  /// In en, this message translates to:
  /// **'Child Safety'**
  String get childSafety;

  /// Loading message for emergency contacts
  ///
  /// In en, this message translates to:
  /// **'Loading emergency contacts...'**
  String get loadingEmergencyContacts;

  /// Message when no quizzes are available
  ///
  /// In en, this message translates to:
  /// **'No quizzes available'**
  String get noQuizzesAvailable;

  /// Quiz questions page title
  ///
  /// In en, this message translates to:
  /// **'Quiz Questions'**
  String get quizQuestions;

  /// Question progress indicator
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionOf(int current, int total);

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Quiz completion message
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed!'**
  String get quizCompleted;

  /// Quiz score message
  ///
  /// In en, this message translates to:
  /// **'You scored {score} out of {total}'**
  String youScored(int score, int total);

  /// Generating recommendations message
  ///
  /// In en, this message translates to:
  /// **'Generating Personalized Recommendations'**
  String get generatingRecommendations;

  /// Message to check explore tab
  ///
  /// In en, this message translates to:
  /// **'Check the Explore tab to see your recommendations!'**
  String get checkExploreTab;

  /// Back to quizzes button
  ///
  /// In en, this message translates to:
  /// **'Back to Quizzes'**
  String get backToQuizzes;

  /// View recommendations button
  ///
  /// In en, this message translates to:
  /// **'View Recommendations'**
  String get viewRecommendations;

  /// Message when no categories are available
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// Message when no videos are available
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideosAvailable;

  /// Forums page title
  ///
  /// In en, this message translates to:
  /// **'Forums'**
  String get forums;

  /// Forum discussion page title
  ///
  /// In en, this message translates to:
  /// **'Forum Discussion'**
  String get forumDiscussion;

  /// Parent forums category title
  ///
  /// In en, this message translates to:
  /// **'Parent Forums'**
  String get parentForums;

  /// Message when no forums are available
  ///
  /// In en, this message translates to:
  /// **'No forums available'**
  String get noForumsAvailable;

  /// Empty state message for comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment!'**
  String get noCommentsYet;

  /// Success message after posting comment
  ///
  /// In en, this message translates to:
  /// **'Comment posted successfully!'**
  String get commentPostedSuccess;

  /// Success message after submitting comment
  ///
  /// In en, this message translates to:
  /// **'Comment submitted successfully!'**
  String get commentSubmittedSuccess;

  /// Validation message for empty comment
  ///
  /// In en, this message translates to:
  /// **'Please enter a comment'**
  String get pleaseEnterComment;

  /// Validation message for short comment
  ///
  /// In en, this message translates to:
  /// **'Comment must be at least 2 characters'**
  String get commentMinLength;

  /// Pull to refresh hint text
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Pull down to refresh hint text
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Recommended section title
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// Take a quiz button text
  ///
  /// In en, this message translates to:
  /// **'Take a Quiz'**
  String get takeAQuiz;

  /// Empty recommendations title
  ///
  /// In en, this message translates to:
  /// **'No Recommendations Yet'**
  String get noRecommendationsYet;

  /// Empty recommendations description
  ///
  /// In en, this message translates to:
  /// **'Take a quiz to get personalized video recommendations based on your interests!'**
  String get takeQuizForRecommendations;

  /// Login required message for recommendations
  ///
  /// In en, this message translates to:
  /// **'Please log in to view recommendations'**
  String get loginToViewRecommendations;

  /// Terms agreement checkbox label
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and conditions'**
  String get agreeToTerms;

  /// Validation message for terms agreement
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms and conditions'**
  String get pleaseAgreeToTerms;

  /// Child age verification question
  ///
  /// In en, this message translates to:
  /// **'Is child above 12 years old?'**
  String get isChildAbove12;

  /// Validation message for parental key
  ///
  /// In en, this message translates to:
  /// **'Parental key must be at least 4 characters'**
  String get parentalKeyMinLength;

  /// Error message for incorrect answer
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer. Please try again.'**
  String get incorrectAnswer;

  /// Success message for parental key reset
  ///
  /// In en, this message translates to:
  /// **'Parental key reset successfully!'**
  String get parentalKeyResetSuccess;

  /// Parent/Guardian role label
  ///
  /// In en, this message translates to:
  /// **'Parent/Guardian'**
  String get parentGuardian;

  /// Child role label
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// Error message when email client fails to launch
  ///
  /// In en, this message translates to:
  /// **'Could not launch email client'**
  String get couldNotLaunchEmail;

  /// Error message with details when launching email
  ///
  /// In en, this message translates to:
  /// **'Error launching email: {error}'**
  String errorLaunchingEmail(String error);

  /// Generic error prefix with message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// Message when no resources are available
  ///
  /// In en, this message translates to:
  /// **'No resources available'**
  String get noResourcesAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'bn',
        'en',
        'gu',
        'hi',
        'kn',
        'ml',
        'mr',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
