// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'गार्डियन केअर';

  @override
  String get home => 'होम';

  @override
  String get learn => 'शिका';

  @override
  String get explore => 'एक्सप्लोर';

  @override
  String get forum => 'फोरम';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get login => 'लॉगिन';

  @override
  String get signup => 'साइन अप';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get language => 'भाषा';

  @override
  String get changeLanguage => 'भाषा बदला';

  @override
  String get selectLanguage => 'भाषा निवडा';

  @override
  String get account => 'खाते';

  @override
  String get emergencyContact => 'आपत्कालीन संपर्क';

  @override
  String get quiz => 'क्विझ';

  @override
  String get videos => 'व्हिडिओ';

  @override
  String get resources => 'संसाधने';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'जतन करा';

  @override
  String get delete => 'हटवा';

  @override
  String get confirm => 'पुष्टी करा';

  @override
  String get yes => 'होय';

  @override
  String get no => 'नाही';

  @override
  String get loading => 'लोड होत आहे...';

  @override
  String get error => 'त्रुटी';

  @override
  String get success => 'यश';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आयटम',
      one: '1 आयटम',
      zero: 'कोणतेही आयटम नाहीत',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'स्वागत आहे';

  @override
  String welcomeUser(String name) {
    return 'स्वागत आहे, $name!';
  }

  @override
  String get emergency => 'आणीबाणी';

  @override
  String get website => 'वेबसाइट';

  @override
  String get mailUs => 'आम्हाला मेल करा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get back => 'मागे';

  @override
  String get next => 'पुढे';

  @override
  String get submit => 'सबमिट करा';

  @override
  String get deleteAccount => 'खाते हटवा';

  @override
  String get deleteAccountConfirm =>
      'तुम्हाला खात्री आहे की तुम्ही तुमचे खाते हटवू इच्छिता? ही क्रिया पूर्ववत केली जाऊ शकत नाही.';

  @override
  String get accountDeletedSuccess => 'खाते यशस्वीरित्या हटवले';

  @override
  String get logoutConfirm =>
      'तुम्हाला खात्री आहे की तुम्ही लॉग आउट करू इच्छिता?';

  @override
  String get deleteMyAccount => 'माझे खाते हटवा';

  @override
  String get noUserSignedIn => 'सध्या कोणताही वापरकर्ता साइन इन केलेला नाही';

  @override
  String get loadingProfile => 'प्रोफाइल लोड होत आहे...';

  @override
  String get nameLabel => 'नाव';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get accountSettings => 'खाते सेटिंग्ज';

  @override
  String get editProfile => 'प्रोफाइल संपादित करा';

  @override
  String get changePassword => 'पासवर्ड बदला';

  @override
  String get notificationSettings => 'सूचना सेटिंग्ज';

  @override
  String get privacySettings => 'गोपनीयता सेटिंग्ज';

  @override
  String get helpSupport => 'मदत आणि समर्थन';

  @override
  String get aboutApp => 'अॅपबद्दल';

  @override
  String get logoutMessage =>
      'तुम्हाला खात्री आहे की तुम्ही लॉग आउट करू इच्छिता?';

  @override
  String get deleteAccountWarning =>
      'ही क्रिया पूर्ववत केली जाऊ शकत नाही. तुमचा सर्व डेटा कायमचा हटवला जाईल.';

  @override
  String get childSafetySettings => 'बाल सुरक्षा सेटिंग्ज';

  @override
  String languageChangedRestarting(String language) {
    return 'भाषा $language मध्ये बदलली. अॅप पुन्हा सुरू होत आहे...';
  }

  @override
  String get emergencyServices => 'आपत्कालीन सेवा';

  @override
  String get childSafety => 'बाल सुरक्षा';

  @override
  String get loadingEmergencyContacts => 'आपत्कालीन संपर्क लोड होत आहेत...';

  @override
  String get noQuizzesAvailable => 'कोणतीही क्विझ उपलब्ध नाही';

  @override
  String get quizQuestions => 'क्विझ प्रश्न';

  @override
  String questionOf(int current, int total) {
    return 'प्रश्न $current चा $total';
  }

  @override
  String get previous => 'मागील';

  @override
  String get finish => 'समाप्त';

  @override
  String get quizCompleted => 'क्विझ पूर्ण झाली!';

  @override
  String youScored(int score, int total) {
    return 'तुम्ही $total पैकी $score गुण मिळवले';
  }

  @override
  String get generatingRecommendations => 'वैयक्तिक शिफारसी तयार करत आहे';

  @override
  String get checkExploreTab =>
      'तुमच्या शिफारसी पाहण्यासाठी एक्सप्लोर टॅब तपासा!';

  @override
  String get backToQuizzes => 'क्विझकडे परत जा';

  @override
  String get viewRecommendations => 'शिफारसी पहा';

  @override
  String get noCategoriesAvailable => 'कोणत्याही श्रेणी उपलब्ध नाहीत';

  @override
  String get noVideosAvailable => 'कोणतेही व्हिडिओ उपलब्ध नाहीत';

  @override
  String get forums => 'फोरम';

  @override
  String get forumDiscussion => 'फोरम चर्चा';

  @override
  String get parentForums => 'पालक फोरम';

  @override
  String get noForumsAvailable => 'कोणतेही फोरम उपलब्ध नाहीत';

  @override
  String get noCommentsYet =>
      'अद्याप कोणत्याही टिप्पण्या नाहीत. पहिली टिप्पणी करा!';

  @override
  String get commentPostedSuccess => 'टिप्पणी यशस्वीरित्या पोस्ट केली!';

  @override
  String get commentSubmittedSuccess => 'टिप्पणी यशस्वीरित्या सबमिट केली!';

  @override
  String get pleaseEnterComment => 'कृपया टिप्पणी प्रविष्ट करा';

  @override
  String get commentMinLength => 'टिप्पणी किमान 2 अक्षरांची असावी';

  @override
  String get pullToRefresh => 'रिफ्रेश करण्यासाठी खेचा';

  @override
  String get pullDownToRefresh => 'रिफ्रेश करण्यासाठी खाली खेचा';

  @override
  String get somethingWentWrong => 'काहीतरी चूक झाली';

  @override
  String get recommendedForYou => 'तुमच्यासाठी शिफारस केलेले';

  @override
  String get takeAQuiz => 'क्विझ घ्या';

  @override
  String get noRecommendationsYet => 'अद्याप कोणत्याही शिफारसी नाहीत';

  @override
  String get takeQuizForRecommendations =>
      'तुमच्या आवडीनुसार वैयक्तिक व्हिडिओ शिफारसी मिळवण्यासाठी क्विझ घ्या!';

  @override
  String get loginToViewRecommendations =>
      'शिफारसी पाहण्यासाठी कृपया लॉगिन करा';

  @override
  String get agreeToTerms => 'मी अटी व शर्तींशी सहमत आहे';

  @override
  String get pleaseAgreeToTerms => 'कृपया अटी व शर्तींशी सहमत व्हा';

  @override
  String get isChildAbove12 => 'मूल 12 वर्षांपेक्षा जास्त वयाचे आहे का?';

  @override
  String get parentalKeyMinLength => 'पालक की किमान 4 अक्षरांची असावी';

  @override
  String get incorrectAnswer => 'चुकीचे उत्तर. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get parentalKeyResetSuccess => 'पालक की यशस्वीरित्या रीसेट केली!';

  @override
  String get parentGuardian => 'पालक/पालक';

  @override
  String get child => 'मूल';

  @override
  String get couldNotLaunchEmail => 'ईमेल क्लायंट लॉन्च करू शकलो नाही';

  @override
  String errorLaunchingEmail(String error) {
    return 'ईमेल लॉन्च करताना त्रुटी: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String get noResourcesAvailable => '???? ???? ????? ???';
}
