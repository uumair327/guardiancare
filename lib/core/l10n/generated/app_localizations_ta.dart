// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'கார்டியன் கேர்';

  @override
  String get home => 'முகப்பு';

  @override
  String get learn => 'கற்றுக்கொள்';

  @override
  String get explore => 'ஆராய்';

  @override
  String get forum => 'மன்றம்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get login => 'உள்நுழை';

  @override
  String get signup => 'பதிவு செய்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get language => 'மொழி';

  @override
  String get changeLanguage => 'மொழியை மாற்று';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடு';

  @override
  String get account => 'கணக்கு';

  @override
  String get emergencyContact => 'அவசர தொடர்பு';

  @override
  String get quiz => 'வினாடி வினா';

  @override
  String get videos => 'வீடியோக்கள்';

  @override
  String get resources => 'வளங்கள்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get save => 'சேமி';

  @override
  String get delete => 'நீக்கு';

  @override
  String get confirm => 'உறுதிப்படுத்து';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get error => 'பிழை';

  @override
  String get success => 'வெற்றி';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count உருப்படிகள்',
      one: '1 உருப்படி',
      zero: 'உருப்படிகள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'வரவேற்கிறோம்';

  @override
  String welcomeUser(String name) {
    return 'வரவேற்கிறோம், $name!';
  }

  @override
  String get emergency => 'அவசரநிலை';

  @override
  String get website => 'இணையதளம்';

  @override
  String get mailUs => 'எங்களுக்கு மின்னஞ்சல் அனுப்பவும்';

  @override
  String get guest => 'விருந்தினர்';

  @override
  String get quickActions => 'விரைவு செயல்கள்';

  @override
  String get homeWelcomeMessage =>
      'குழந்தைகள் மற்றும் குடும்பங்களுக்கு பாதுகாப்பு அறிவை வழங்குதல்';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get back => 'பின்';

  @override
  String get next => 'அடுத்து';

  @override
  String get submit => 'சமர்ப்பிக்கவும்';

  @override
  String get deleteAccount => 'கணக்கை நீக்கு';

  @override
  String get deleteAccountConfirm =>
      'உங்கள் கணக்கை நீக்க விரும்புகிறீர்களா? இந்த செயலை மாற்ற முடியாது.';

  @override
  String get accountDeletedSuccess => 'கணக்கு வெற்றிகரமாக நீக்கப்பட்டது';

  @override
  String get logoutConfirm => 'நீங்கள் வெளியேற விரும்புகிறீர்களா?';

  @override
  String get deleteMyAccount => 'என் கணக்கை நீக்கு';

  @override
  String get noUserSignedIn => 'தற்போது எந்த பயனரும் உள்நுழையவில்லை';

  @override
  String get loadingProfile => 'சுயவிவரம் ஏற்றப்படுகிறது...';

  @override
  String get nameLabel => 'பெயர்';

  @override
  String get emailLabel => 'மின்னஞ்சல்';

  @override
  String get accountSettings => 'கணக்கு அமைப்புகள்';

  @override
  String get editProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get changePassword => 'கடவுச்சொல்லை மாற்று';

  @override
  String get notificationSettings => 'அறிவிப்பு அமைப்புகள்';

  @override
  String get privacySettings => 'தனியுரிமை அமைப்புகள்';

  @override
  String get helpSupport => 'உதவி மற்றும் ஆதரவு';

  @override
  String get aboutApp => 'பயன்பாடு பற்றி';

  @override
  String get logoutMessage => 'நீங்கள் வெளியேற விரும்புகிறீர்களா?';

  @override
  String get deleteAccountWarning =>
      'இந்த செயலை மாற்ற முடியாது. உங்கள் அனைத்து தரவும் நிரந்தரமாக நீக்கப்படும்.';

  @override
  String get childSafetySettings => 'குழந்தை பாதுகாப்பு அமைப்புகள்';

  @override
  String languageChangedRestarting(String language) {
    return 'மொழி $language ஆக மாற்றப்பட்டது. பயன்பாடு மீண்டும் தொடங்குகிறது...';
  }

  @override
  String get emergencyServices => 'அவசர சேவைகள்';

  @override
  String get childSafety => 'குழந்தை பாதுகாப்பு';

  @override
  String get loadingEmergencyContacts => 'அவசர தொடர்புகள் ஏற்றப்படுகின்றன...';

  @override
  String get noQuizzesAvailable => 'வினாடி வினாக்கள் இல்லை';

  @override
  String get quizQuestions => 'வினாடி வினா கேள்விகள்';

  @override
  String questionOf(int current, int total) {
    return 'கேள்வி $current இன் $total';
  }

  @override
  String get previous => 'முந்தைய';

  @override
  String get finish => 'முடி';

  @override
  String get quizCompleted => 'வினாடி வினா முடிந்தது!';

  @override
  String youScored(int score, int total) {
    return 'நீங்கள் $total இல் $score மதிப்பெண் பெற்றீர்கள்';
  }

  @override
  String get generatingRecommendations =>
      'தனிப்பயனாக்கப்பட்ட பரிந்துரைகளை உருவாக்குகிறது';

  @override
  String get checkExploreTab =>
      'உங்கள் பரிந்துரைகளைக் காண எக்ஸ்ப்ளோர் தாவலைச் சரிபார்க்கவும்!';

  @override
  String get backToQuizzes => 'வினாடி வினாக்களுக்குத் திரும்பு';

  @override
  String get viewRecommendations => 'பரிந்துரைகளைக் காண்க';

  @override
  String get noCategoriesAvailable => 'வகைகள் இல்லை';

  @override
  String get noVideosAvailable => 'வீடியோக்கள் இல்லை';

  @override
  String get forums => 'மன்றங்கள்';

  @override
  String get forumDiscussion => 'மன்ற விவாதம்';

  @override
  String get parentForums => 'பெற்றோர் மன்றங்கள்';

  @override
  String get noForumsAvailable => 'மன்றங்கள் இல்லை';

  @override
  String get noCommentsYet =>
      'இன்னும் கருத்துகள் இல்லை. முதலில் கருத்து தெரிவிக்கவும்!';

  @override
  String get commentPostedSuccess => 'கருத்து வெற்றிகரமாக இடுகையிடப்பட்டது!';

  @override
  String get commentSubmittedSuccess =>
      'கருத்து வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது!';

  @override
  String get pleaseEnterComment => 'தயவுசெய்து ஒரு கருத்தை உள்ளிடவும்';

  @override
  String get commentMinLength =>
      'கருத்து குறைந்தது 2 எழுத்துக்களாக இருக்க வேண்டும்';

  @override
  String get pullToRefresh => 'புதுப்பிக்க இழுக்கவும்';

  @override
  String get pullDownToRefresh => 'புதுப்பிக்க கீழே இழுக்கவும்';

  @override
  String get somethingWentWrong => 'ஏதோ தவறு நடந்தது';

  @override
  String get recommendedForYou => 'உங்களுக்கான பரிந்துரைகள்';

  @override
  String get takeAQuiz => 'வினாடி வினா எடுக்கவும்';

  @override
  String get noRecommendationsYet => 'இன்னும் பரிந்துரைகள் இல்லை';

  @override
  String get takeQuizForRecommendations =>
      'உங்கள் ஆர்வங்களின் அடிப்படையில் தனிப்பயனாக்கப்பட்ட வீடியோ பரிந்துரைகளைப் பெற வினாடி வினா எடுக்கவும்!';

  @override
  String get loginToViewRecommendations =>
      'பரிந்துரைகளைக் காண தயவுசெய்து உள்நுழையவும்';

  @override
  String get agreeToTerms => 'நான் விதிமுறைகள் மற்றும் நிபந்தனைகளை ஏற்கிறேன்';

  @override
  String get pleaseAgreeToTerms =>
      'தயவுசெய்து விதிமுறைகள் மற்றும் நிபந்தனைகளை ஏற்கவும்';

  @override
  String get isChildAbove12 => 'குழந்தை 12 வயதுக்கு மேற்பட்டதா?';

  @override
  String get parentalKeyMinLength =>
      'பெற்றோர் விசை குறைந்தது 4 எழுத்துக்களாக இருக்க வேண்டும்';

  @override
  String get incorrectAnswer => 'தவறான பதில். மீண்டும் முயற்சிக்கவும்.';

  @override
  String get parentalKeyResetSuccess =>
      'பெற்றோர் விசை வெற்றிகரமாக மீட்டமைக்கப்பட்டது!';

  @override
  String get parentGuardian => 'பெற்றோர்/பாதுகாவலர்';

  @override
  String get child => 'குழந்தை';

  @override
  String get couldNotLaunchEmail => 'மின்னஞ்சல் கிளையண்டைத் தொடங்க முடியவில்லை';

  @override
  String errorLaunchingEmail(String error) {
    return 'மின்னஞ்சலைத் தொடங்குவதில் பிழை: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'பிழை: $error';
  }

  @override
  String get noResourcesAvailable => 'வளங்கள் எதுவும் இல்லை';

  @override
  String get forChildren => 'குழந்தைகளுக்கு';

  @override
  String get connectAndShare => 'இணைந்து அனுபவங்களைப் பகிரவும்';

  @override
  String get beFirstToDiscuss => 'விவாதத்தைத் தொடங்கும் முதல் நபராக இருங்கள்!';

  @override
  String get guidelinesTitle => 'மன்ற வழிகாட்டுதல்கள்';

  @override
  String get guidelinesWelcome =>
      'கார்டியன் கேர் மன்றத்திற்கு வரவேற்கிறோம். இந்த வழிகாட்டுதல்களைப் பின்பற்றவும்:';

  @override
  String get guidelineRespect =>
      'அனைத்து உறுப்பினர்களிடமும் மரியாதையாகவும் பண்பாகவும் இருங்கள்.';

  @override
  String get guidelineNoAbuse =>
      'அவமானகரமான, துன்புறுத்தும் அல்லது தீங்கு விளைவிக்கும் மொழியைப் பயன்படுத்த வேண்டாம்.';

  @override
  String get guidelineNoHarmful =>
      'பொருத்தமற்ற அல்லது தீங்கு விளைவிக்கும் உள்ளடக்கத்தைப் பகிர்வதைத் தவிர்க்கவும்.';

  @override
  String get guidelineConstructive =>
      'இது குழந்தை பாதுகாப்பு குறித்த ஆக்கபூர்வமான விவாதங்களுக்கான இடம்.';

  @override
  String get discussionTitle => 'விவாதம்';

  @override
  String get communityDiscussion => 'சமூக விவாதம்';

  @override
  String get beFirstToComment =>
      'உங்கள் எண்ணங்களைப் பகிரும் முதல் நபராக இருங்கள்!';

  @override
  String get startTypingBelow => 'கீழே தட்டச்சு செய்யத் தொடங்குங்கள்';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கருத்துகள்',
      one: '1 கருத்து',
      zero: 'கருத்துகள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get parentalAccessRequired => 'பெற்றோர் அணுகல் தேவை';

  @override
  String get parentalAccessDescription =>
      'இந்த பகுதி பாதுகாக்கப்பட்டுள்ளது. தொடர உங்கள் பெற்றோர் விசையை உள்ளிடவும்.';

  @override
  String get invalidKeyTryAgain => 'தவறான விசை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get forgotYourKey => 'உங்கள் விசையை மறந்துவிட்டீர்களா?';

  @override
  String get protectedForChildSafety =>
      'குழந்தை பாதுகாப்பிற்காக பாதுகாக்கப்பட்டது';

  @override
  String get unlock => 'திறக்கவும்';
}
