// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'गार्जियन केयर';

  @override
  String get home => 'होम';

  @override
  String get learn => 'सीखें';

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
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get changeLanguage => 'भाषा बदलें';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get account => 'खाता';

  @override
  String get emergencyContact => 'आपातकालीन संपर्क';

  @override
  String get quiz => 'क्विज';

  @override
  String get videos => 'वीडियो';

  @override
  String get resources => 'संसाधन';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get yes => 'हां';

  @override
  String get no => 'नहीं';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get success => 'सफलता';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count आइटम',
      one: '1 आइटम',
      zero: 'कोई आइटम नहीं',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'स्वागत है';

  @override
  String welcomeUser(String name) {
    return 'स्वागत है, $name!';
  }

  @override
  String get emergency => 'आपातकाल';

  @override
  String get website => 'वेबसाइट';

  @override
  String get mailUs => 'हमें मेल करें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get back => 'वापस';

  @override
  String get next => 'अगला';

  @override
  String get submit => 'जमा करें';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountConfirm =>
      'क्या आप वाकई अपना खाता हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get accountDeletedSuccess => 'खाता सफलतापूर्वक हटा दिया गया';

  @override
  String get logoutConfirm => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get deleteMyAccount => 'मेरा खाता हटाएं';

  @override
  String get noUserSignedIn => 'वर्तमान में कोई उपयोगकर्ता साइन इन नहीं है';

  @override
  String get loadingProfile => 'प्रोफाइल लोड हो रहा है...';

  @override
  String get nameLabel => 'नाम';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get accountSettings => 'खाता सेटिंग्स';

  @override
  String get editProfile => 'प्रोफाइल संपादित करें';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get notificationSettings => 'सूचना सेटिंग्स';

  @override
  String get privacySettings => 'गोपनीयता सेटिंग्स';

  @override
  String get helpSupport => 'सहायता और समर्थन';

  @override
  String get aboutApp => 'ऐप के बारे में';

  @override
  String get logoutMessage => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get deleteAccountWarning =>
      'यह क्रिया पूर्ववत नहीं की जा सकती। आपका सभी डेटा स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get childSafetySettings => 'बाल सुरक्षा सेटिंग्स';

  @override
  String languageChangedRestarting(String language) {
    return 'भाषा $language में बदल गई। ऐप पुनः आरंभ हो रहा है...';
  }

  @override
  String get emergencyServices => 'आपातकालीन सेवाएं';

  @override
  String get childSafety => 'बाल सुरक्षा';

  @override
  String get loadingEmergencyContacts => 'आपातकालीन संपर्क लोड हो रहे हैं...';

  @override
  String get noQuizzesAvailable => 'कोई क्विज उपलब्ध नहीं';

  @override
  String get quizQuestions => 'क्विज प्रश्न';

  @override
  String questionOf(int current, int total) {
    return 'प्रश्न $current का $total';
  }

  @override
  String get previous => 'पिछला';

  @override
  String get finish => 'समाप्त';

  @override
  String get quizCompleted => 'क्विज़ पूर्ण हुआ!';

  @override
  String youScored(int score, int total) {
    return 'आपने $total में से $score अंक प्राप्त किए';
  }

  @override
  String get generatingRecommendations =>
      'व्यक्तिगत सिफारिशें तैयार की जा रही हैं';

  @override
  String get checkExploreTab =>
      'अपनी सिफारिशें देखने के लिए एक्सप्लोर टैब देखें!';

  @override
  String get backToQuizzes => 'क्विज़ पर वापस जाएं';

  @override
  String get viewRecommendations => 'सिफारिशें देखें';

  @override
  String get noCategoriesAvailable => 'कोई श्रेणी उपलब्ध नहीं है';

  @override
  String get noVideosAvailable => 'कोई वीडियो उपलब्ध नहीं है';

  @override
  String get forums => 'फोरम';

  @override
  String get forumDiscussion => 'फोरम चर्चा';

  @override
  String get parentForums => 'अभिभावक फोरम';

  @override
  String get noForumsAvailable => 'कोई फोरम उपलब्ध नहीं';

  @override
  String get noCommentsYet => 'अभी तक कोई टिप्पणी नहीं। पहले टिप्पणी करें!';

  @override
  String get commentPostedSuccess => 'टिप्पणी सफलतापूर्वक पोस्ट की गई!';

  @override
  String get commentSubmittedSuccess => 'टिप्पणी सफलतापूर्वक सबमिट की गई!';

  @override
  String get pleaseEnterComment => 'कृपया एक टिप्पणी दर्ज करें';

  @override
  String get commentMinLength => 'टिप्पणी कम से कम 2 अक्षर की होनी चाहिए';

  @override
  String get pullToRefresh => 'रिफ्रेश करने के लिए खींचें';

  @override
  String get pullDownToRefresh => 'रिफ्रेश करने के लिए नीचे खींचें';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get recommendedForYou => 'आपके लिए अनुशंसित';

  @override
  String get takeAQuiz => 'एक क्विज लें';

  @override
  String get noRecommendationsYet => 'अभी तक कोई अनुशंसा नहीं';

  @override
  String get takeQuizForRecommendations =>
      'अपनी रुचियों के आधार पर व्यक्तिगत वीडियो अनुशंसाएं प्राप्त करने के लिए एक क्विज लें!';

  @override
  String get loginToViewRecommendations =>
      'अनुशंसाएं देखने के लिए कृपया लॉगिन करें';

  @override
  String get agreeToTerms => 'मैं नियम और शर्तों से सहमत हूं';

  @override
  String get pleaseAgreeToTerms => 'कृपया नियम और शर्तों से सहमत हों';

  @override
  String get isChildAbove12 => 'क्या बच्चा 12 वर्ष से अधिक उम्र का है?';

  @override
  String get parentalKeyMinLength =>
      'अभिभावक कुंजी कम से कम 4 अक्षर की होनी चाहिए';

  @override
  String get incorrectAnswer => 'गलत उत्तर। कृपया पुनः प्रयास करें।';

  @override
  String get parentalKeyResetSuccess =>
      'अभिभावक कुंजी सफलतापूर्वक रीसेट की गई!';

  @override
  String get parentGuardian => 'माता-पिता/अभिभावक';

  @override
  String get child => 'बच्चा';

  @override
  String get couldNotLaunchEmail => 'ईमेल क्लाइंट लॉन्च नहीं किया जा सका';

  @override
  String errorLaunchingEmail(String error) {
    return 'ईमेल लॉन्च करने में त्रुटि: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get noResourcesAvailable => '?? ???? ????? ??';
}
