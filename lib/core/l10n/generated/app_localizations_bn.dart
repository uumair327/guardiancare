// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'গার্ডিয়ান কেয়ার';

  @override
  String get home => 'হোম';

  @override
  String get learn => 'শিখুন';

  @override
  String get explore => 'এক্সপ্লোর';

  @override
  String get forum => 'ফোরাম';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get login => 'লগইন';

  @override
  String get signup => 'সাইন আপ';

  @override
  String get email => 'ইমেইল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get logout => 'লগআউট';

  @override
  String get settings => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get changeLanguage => 'ভাষা পরিবর্তন করুন';

  @override
  String get selectLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get emergencyContact => 'জরুরি যোগাযোগ';

  @override
  String get quiz => 'কুইজ';

  @override
  String get videos => 'ভিডিও';

  @override
  String get resources => 'সম্পদ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get error => 'ত্রুটি';

  @override
  String get success => 'সফলতা';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি আইটেম',
      one: '1টি আইটেম',
      zero: 'কোনো আইটেম নেই',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'স্বাগতম';

  @override
  String welcomeUser(String name) {
    return 'স্বাগতম, $name!';
  }

  @override
  String get emergency => 'জরুরি';

  @override
  String get website => 'ওয়েবসাইট';

  @override
  String get mailUs => 'আমাদের মেইল করুন';

  @override
  String get guest => 'অতিথি';

  @override
  String get quickActions => 'দ্রুত কর্ম';

  @override
  String get homeWelcomeMessage =>
      'শিশু এবং পরিবারকে নিরাপত্তা জ্ঞান দিয়ে ক্ষমতায়ন করা';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get back => 'পিছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get submit => 'জমা দিন';

  @override
  String get deleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get deleteAccountConfirm =>
      'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট মুছতে চান? এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get accountDeletedSuccess => 'অ্যাকাউন্ট সফলভাবে মুছে ফেলা হয়েছে';

  @override
  String get logoutConfirm => 'আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?';

  @override
  String get deleteMyAccount => 'আমার অ্যাকাউন্ট মুছুন';

  @override
  String get noUserSignedIn => 'বর্তমানে কোনো ব্যবহারকারী সাইন ইন করেননি';

  @override
  String get loadingProfile => 'প্রোফাইল লোড হচ্ছে...';

  @override
  String get nameLabel => 'নাম';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get accountSettings => 'অ্যাকাউন্ট সেটিংস';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা করুন';

  @override
  String get changePassword => 'পাসওয়ার্ড পরিবর্তন করুন';

  @override
  String get notificationSettings => 'বিজ্ঞপ্তি সেটিংস';

  @override
  String get privacySettings => 'গোপনীয়তা সেটিংস';

  @override
  String get helpSupport => 'সাহায্য ও সহায়তা';

  @override
  String get aboutApp => 'অ্যাপ সম্পর্কে';

  @override
  String get logoutMessage => 'আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?';

  @override
  String get deleteAccountWarning =>
      'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না। আপনার সমস্ত ডেটা স্থায়ীভাবে মুছে ফেলা হবে।';

  @override
  String get childSafetySettings => 'শিশু সুরক্ষা সেটিংস';

  @override
  String languageChangedRestarting(String language) {
    return 'ভাষা $language এ পরিবর্তিত হয়েছে। অ্যাপ পুনরায় চালু হচ্ছে...';
  }

  @override
  String get emergencyServices => 'জরুরি সেবা';

  @override
  String get childSafety => 'শিশু সুরক্ষা';

  @override
  String get loadingEmergencyContacts => 'জরুরি যোগাযোগ লোড হচ্ছে...';

  @override
  String get noQuizzesAvailable => 'কোনো কুইজ উপলব্ধ নেই';

  @override
  String get quizQuestions => 'কুইজ প্রশ্ন';

  @override
  String questionOf(int current, int total) {
    return 'প্রশ্ন $current এর $total';
  }

  @override
  String get previous => 'পূর্ববর্তী';

  @override
  String get finish => 'সমাপ্ত';

  @override
  String get quizCompleted => 'কুইজ সম্পন্ন হয়েছে!';

  @override
  String youScored(int score, int total) {
    return 'আপনি $total এর মধ্যে $score স্কোর করেছেন';
  }

  @override
  String get generatingRecommendations => 'ব্যক্তিগত সুপারিশ তৈরি করা হচ্ছে';

  @override
  String get checkExploreTab => 'আপনার সুপারিশ দেখতে এক্সপ্লোর ট্যাব দেখুন!';

  @override
  String get backToQuizzes => 'কুইজে ফিরে যান';

  @override
  String get viewRecommendations => 'সুপারিশ দেখুন';

  @override
  String get noCategoriesAvailable => 'কোনো বিভাগ উপলব্ধ নেই';

  @override
  String get noVideosAvailable => 'কোনো ভিডিও উপলব্ধ নেই';

  @override
  String get forums => 'ফোরাম';

  @override
  String get forumDiscussion => 'ফোরাম আলোচনা';

  @override
  String get parentForums => 'অভিভাবক ফোরাম';

  @override
  String get noForumsAvailable => 'কোনো ফোরাম উপলব্ধ নেই';

  @override
  String get noCommentsYet => 'এখনও কোনো মন্তব্য নেই। প্রথম মন্তব্য করুন!';

  @override
  String get commentPostedSuccess => 'মন্তব্য সফলভাবে পোস্ট করা হয়েছে!';

  @override
  String get commentSubmittedSuccess => 'মন্তব্য সফলভাবে জমা দেওয়া হয়েছে!';

  @override
  String get pleaseEnterComment => 'অনুগ্রহ করে একটি মন্তব্য লিখুন';

  @override
  String get commentMinLength => 'মন্তব্য কমপক্ষে 2 অক্ষরের হতে হবে';

  @override
  String get pullToRefresh => 'রিফ্রেশ করতে টানুন';

  @override
  String get pullDownToRefresh => 'রিফ্রেশ করতে নিচে টানুন';

  @override
  String get somethingWentWrong => 'কিছু ভুল হয়েছে';

  @override
  String get recommendedForYou => 'আপনার জন্য সুপারিশকৃত';

  @override
  String get takeAQuiz => 'একটি কুইজ নিন';

  @override
  String get noRecommendationsYet => 'এখনও কোনো সুপারিশ নেই';

  @override
  String get takeQuizForRecommendations =>
      'আপনার আগ্রহের উপর ভিত্তি করে ব্যক্তিগত ভিডিও সুপারিশ পেতে একটি কুইজ নিন!';

  @override
  String get loginToViewRecommendations =>
      'সুপারিশ দেখতে অনুগ্রহ করে লগইন করুন';

  @override
  String get agreeToTerms => 'আমি নিয়ম ও শর্তাবলীতে সম্মত';

  @override
  String get pleaseAgreeToTerms => 'অনুগ্রহ করে নিয়ম ও শর্তাবলীতে সম্মত হন';

  @override
  String get isChildAbove12 => 'শিশুটি কি 12 বছরের বেশি বয়সী?';

  @override
  String get parentalKeyMinLength => 'অভিভাবক কী কমপক্ষে 4 অক্ষরের হতে হবে';

  @override
  String get incorrectAnswer => 'ভুল উত্তর। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get parentalKeyResetSuccess => 'অভিভাবক কী সফলভাবে রিসেট করা হয়েছে!';

  @override
  String get parentGuardian => 'পিতামাতা/অভিভাবক';

  @override
  String get child => 'শিশু';

  @override
  String get couldNotLaunchEmail => 'ইমেইল ক্লায়েন্ট চালু করা যায়নি';

  @override
  String errorLaunchingEmail(String error) {
    return 'ইমেইল চালু করতে ত্রুটি: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get noResourcesAvailable => 'কোনো সম্পদ উপলব্ধ নেই';

  @override
  String get forChildren => 'শিশুদের জন্য';

  @override
  String get connectAndShare => 'সংযুক্ত হন এবং অভিজ্ঞতা শেয়ার করুন';

  @override
  String get beFirstToDiscuss => 'আলোচনা শুরু করার প্রথম ব্যক্তি হন!';

  @override
  String get guidelinesTitle => 'ফোরাম নির্দেশিকা';

  @override
  String get guidelinesWelcome =>
      'গার্ডিয়ান কেয়ার ফোরামে স্বাগতম। অনুগ্রহ করে এই নির্দেশিকাগুলি অনুসরণ করুন:';

  @override
  String get guidelineRespect => 'সকল সদস্যদের প্রতি সম্মানজনক এবং বিনয়ী হন।';

  @override
  String get guidelineNoAbuse =>
      'অপমানজনক, হয়রানিমূলক বা ক্ষতিকর ভাষা ব্যবহার করবেন না।';

  @override
  String get guidelineNoHarmful =>
      'অনুপযুক্ত বা ক্ষতিকর বিষয়বস্তু শেয়ার করা থেকে বিরত থাকুন।';

  @override
  String get guidelineConstructive =>
      'এটি শিশু সুরক্ষা সম্পর্কে গঠনমূলক আলোচনার জন্য একটি স্থান।';

  @override
  String get discussionTitle => 'আলোচনা';

  @override
  String get communityDiscussion => 'সম্প্রদায় আলোচনা';

  @override
  String get beFirstToComment => 'আপনার মতামত শেয়ার করার প্রথম ব্যক্তি হন!';

  @override
  String get startTypingBelow => 'নিচে টাইপ করা শুরু করুন';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি মন্তব্য',
      one: '1টি মন্তব্য',
      zero: 'কোনো মন্তব্য নেই',
    );
    return '$_temp0';
  }

  @override
  String get parentalAccessRequired => 'অভিভাবক অ্যাক্সেস প্রয়োজন';

  @override
  String get parentalAccessDescription =>
      'এই বিভাগটি সুরক্ষিত। চালিয়ে যেতে আপনার অভিভাবক কী প্রবেশ করুন।';

  @override
  String get invalidKeyTryAgain => 'অবৈধ কী। আবার চেষ্টা করুন।';

  @override
  String get forgotYourKey => 'আপনার কী ভুলে গেছেন?';

  @override
  String get protectedForChildSafety => 'শিশু সুরক্ষার জন্য সুরক্ষিত';

  @override
  String get unlock => 'আনলক করুন';
}
