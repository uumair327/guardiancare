// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'ഗാർഡിയൻ കെയർ';

  @override
  String get home => 'ഹോം';

  @override
  String get learn => 'പഠിക്കുക';

  @override
  String get explore => 'പര്യവേക്ഷണം';

  @override
  String get forum => 'ഫോറം';

  @override
  String get profile => 'പ്രൊഫൈൽ';

  @override
  String get login => 'ലോഗിൻ';

  @override
  String get signup => 'സൈൻ അപ്പ്';

  @override
  String get email => 'ഇമെയിൽ';

  @override
  String get password => 'പാസ്‌വേഡ്';

  @override
  String get forgotPassword => 'പാസ്‌വേഡ് മറന്നോ?';

  @override
  String get logout => 'ലോഗൗട്ട്';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get changeLanguage => 'ഭാഷ മാറ്റുക';

  @override
  String get selectLanguage => 'ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get account => 'അക്കൗണ്ട്';

  @override
  String get emergencyContact => 'അടിയന്തര ബന്ധം';

  @override
  String get quiz => 'ക്വിസ്';

  @override
  String get videos => 'വീഡിയോകൾ';

  @override
  String get resources => 'വിഭവങ്ങൾ';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get save => 'സംരക്ഷിക്കുക';

  @override
  String get delete => 'ഇല്ലാതാക്കുക';

  @override
  String get confirm => 'സ്ഥിരീകരിക്കുക';

  @override
  String get yes => 'അതെ';

  @override
  String get no => 'ഇല്ല';

  @override
  String get loading => 'ലോഡ് ചെയ്യുന്നു...';

  @override
  String get error => 'പിശക്';

  @override
  String get success => 'വിജയം';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഇനങ്ങൾ',
      one: '1 ഇനം',
      zero: 'ഇനങ്ങളൊന്നുമില്ല',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'സ്വാഗതം';

  @override
  String welcomeUser(String name) {
    return 'സ്വാഗതം, $name!';
  }

  @override
  String get emergency => 'അടിയന്തരം';

  @override
  String get website => 'വെബ്‌സൈറ്റ്';

  @override
  String get mailUs => 'ഞങ്ങൾക്ക് മെയിൽ ചെയ്യുക';

  @override
  String get guest => 'അതിഥി';

  @override
  String get quickActions => 'പെട്ടെന്നുള്ള പ്രവർത്തനങ്ങൾ';

  @override
  String get homeWelcomeMessage =>
      'കുട്ടികൾക്കും കുടുംബങ്ങൾക്കും സുരക്ഷാ അറിവ് നൽകുന്നു';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get back => 'പിന്നോട്ട്';

  @override
  String get next => 'അടുത്തത്';

  @override
  String get submit => 'സമർപ്പിക്കുക';

  @override
  String get deleteAccount => 'അക്കൗണ്ട് ഇല്ലാതാക്കുക';

  @override
  String get deleteAccountConfirm =>
      'നിങ്ങളുടെ അക്കൗണ്ട് ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഈ പ്രവർത്തനം പഴയപടിയാക്കാൻ കഴിയില്ല.';

  @override
  String get accountDeletedSuccess => 'അക്കൗണ്ട് വിജയകരമായി ഇല്ലാതാക്കി';

  @override
  String get logoutConfirm => 'നിങ്ങൾ ലോഗൗട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?';

  @override
  String get deleteMyAccount => 'എന്റെ അക്കൗണ്ട് ഇല്ലാതാക്കുക';

  @override
  String get noUserSignedIn => 'നിലവിൽ ഒരു ഉപയോക്താവും സൈൻ ഇൻ ചെയ്തിട്ടില്ല';

  @override
  String get loadingProfile => 'പ്രൊഫൈൽ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get nameLabel => 'പേര്';

  @override
  String get emailLabel => 'ഇമെയിൽ';

  @override
  String get accountSettings => 'അക്കൗണ്ട് ക്രമീകരണങ്ങൾ';

  @override
  String get editProfile => 'പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യുക';

  @override
  String get changePassword => 'പാസ്‌വേഡ് മാറ്റുക';

  @override
  String get notificationSettings => 'അറിയിപ്പ് ക്രമീകരണങ്ങൾ';

  @override
  String get privacySettings => 'സ്വകാര്യത ക്രമീകരണങ്ങൾ';

  @override
  String get helpSupport => 'സഹായവും പിന്തുണയും';

  @override
  String get aboutApp => 'ആപ്പിനെക്കുറിച്ച്';

  @override
  String get logoutMessage => 'നിങ്ങൾ ലോഗൗട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?';

  @override
  String get deleteAccountWarning =>
      'ഈ പ്രവർത്തനം പഴയപടിയാക്കാൻ കഴിയില്ല. നിങ്ങളുടെ എല്ലാ ഡാറ്റയും ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';

  @override
  String get childSafetySettings => 'കുട്ടികളുടെ സുരക്ഷാ ക്രമീകരണങ്ങൾ';

  @override
  String languageChangedRestarting(String language) {
    return 'ഭാഷ $language ആയി മാറ്റി. ആപ്പ് പുനരാരംഭിക്കുന്നു...';
  }

  @override
  String get emergencyServices => 'അടിയന്തര സേവനങ്ങൾ';

  @override
  String get childSafety => 'കുട്ടികളുടെ സുരക്ഷ';

  @override
  String get loadingEmergencyContacts => 'അടിയന്തര ബന്ധങ്ങൾ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get noQuizzesAvailable => 'ക്വിസുകളൊന്നുമില്ല';

  @override
  String get quizQuestions => 'ക്വിസ് ചോദ്യങ്ങൾ';

  @override
  String questionOf(int current, int total) {
    return 'ചോദ്യം $current ന്റെ $total';
  }

  @override
  String get previous => 'മുമ്പത്തെ';

  @override
  String get finish => 'പൂർത്തിയാക്കുക';

  @override
  String get quizCompleted => 'ക്വിസ് പൂർത്തിയായി!';

  @override
  String youScored(int score, int total) {
    return 'നിങ്ങൾ $total ൽ $score സ്കോർ ചെയ്തു';
  }

  @override
  String get generatingRecommendations => 'വ്യക്തിഗത ശുപാർശകൾ സൃഷ്ടിക്കുന്നു';

  @override
  String get checkExploreTab =>
      'നിങ്ങളുടെ ശുപാർശകൾ കാണാൻ എക്സ്പ്ലോർ ടാബ് പരിശോധിക്കുക!';

  @override
  String get backToQuizzes => 'ക്വിസുകളിലേക്ക് മടങ്ങുക';

  @override
  String get viewRecommendations => 'ശുപാർശകൾ കാണുക';

  @override
  String get noCategoriesAvailable => 'വിഭാഗങ്ങളൊന്നുമില്ല';

  @override
  String get noVideosAvailable => 'വീഡിയോകളൊന്നുമില്ല';

  @override
  String get forums => 'ഫോറങ്ങൾ';

  @override
  String get forumDiscussion => 'ഫോറം ചർച്ച';

  @override
  String get parentForums => 'രക്ഷിതാവ് ഫോറങ്ങൾ';

  @override
  String get noForumsAvailable => 'ഫോറങ്ങളൊന്നുമില്ല';

  @override
  String get noCommentsYet =>
      'ഇതുവരെ അഭിപ്രായങ്ങളൊന്നുമില്ല. ആദ്യം അഭിപ്രായമിടൂ!';

  @override
  String get commentPostedSuccess => 'അഭിപ്രായം വിജയകരമായി പോസ്റ്റ് ചെയ്തു!';

  @override
  String get commentSubmittedSuccess => 'അഭിപ്രായം വിജയകരമായി സമർപ്പിച്ചു!';

  @override
  String get pleaseEnterComment => 'ദയവായി ഒരു അഭിപ്രായം നൽകുക';

  @override
  String get commentMinLength =>
      'അഭിപ്രായം കുറഞ്ഞത് 2 അക്ഷരങ്ങൾ ഉണ്ടായിരിക്കണം';

  @override
  String get pullToRefresh => 'പുതുക്കാൻ വലിക്കുക';

  @override
  String get pullDownToRefresh => 'പുതുക്കാൻ താഴേക്ക് വലിക്കുക';

  @override
  String get somethingWentWrong => 'എന്തോ തെറ്റ് സംഭവിച്ചു';

  @override
  String get recommendedForYou => 'നിങ്ങൾക്കായി ശുപാർശ ചെയ്യുന്നു';

  @override
  String get takeAQuiz => 'ഒരു ക്വിസ് എടുക്കുക';

  @override
  String get noRecommendationsYet => 'ഇതുവരെ ശുപാർശകളൊന്നുമില്ല';

  @override
  String get takeQuizForRecommendations =>
      'നിങ്ങളുടെ താൽപ്പര്യങ്ങളെ അടിസ്ഥാനമാക്കി വ്യക്തിഗത വീഡിയോ ശുപാർശകൾ ലഭിക്കാൻ ഒരു ക്വിസ് എടുക്കുക!';

  @override
  String get loginToViewRecommendations =>
      'ശുപാർശകൾ കാണാൻ ദയവായി ലോഗിൻ ചെയ്യുക';

  @override
  String get agreeToTerms => 'ഞാൻ നിബന്ധനകളും വ്യവസ്ഥകളും അംഗീകരിക്കുന്നു';

  @override
  String get pleaseAgreeToTerms =>
      'ദയവായി നിബന്ധനകളും വ്യവസ്ഥകളും അംഗീകരിക്കുക';

  @override
  String get isChildAbove12 => 'കുട്ടിക്ക് 12 വയസ്സിന് മുകളിലാണോ?';

  @override
  String get parentalKeyMinLength =>
      'രക്ഷിതാവ് കീ കുറഞ്ഞത് 4 അക്ഷരങ്ങൾ ഉണ്ടായിരിക്കണം';

  @override
  String get incorrectAnswer => 'തെറ്റായ ഉത്തരം. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get parentalKeyResetSuccess =>
      'രക്ഷിതാവ് കീ വിജയകരമായി റീസെറ്റ് ചെയ്തു!';

  @override
  String get parentGuardian => 'രക്ഷിതാവ്/രക്ഷാധികാരി';

  @override
  String get child => 'കുട്ടി';

  @override
  String get couldNotLaunchEmail => 'ഇമെയിൽ ക്ലയന്റ് ലോഞ്ച് ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String errorLaunchingEmail(String error) {
    return 'ഇമെയിൽ ലോഞ്ച് ചെയ്യുന്നതിൽ പിശക്: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'പിശക്: $error';
  }

  @override
  String get noResourcesAvailable => 'വിഭവങ്ങളൊന്നും ലഭ്യമല്ല';

  @override
  String get forChildren => 'കുട്ടികൾക്കായി';

  @override
  String get connectAndShare => 'ബന്ധപ്പെടുക, അനുഭവങ്ങൾ പങ്കിടുക';

  @override
  String get beFirstToDiscuss => 'ചർച്ച ആരംഭിക്കുന്ന ആദ്യത്തെയാളാകൂ!';

  @override
  String get guidelinesTitle => 'ഫോറം മാർഗ്ഗനിർദ്ദേശങ്ങൾ';

  @override
  String get guidelinesWelcome =>
      'ഗാർഡിയൻ കെയർ ഫോറത്തിലേക്ക് സ്വാഗതം. ദയവായി ഈ മാർഗ്ഗനിർദ്ദേശങ്ങൾ പാലിക്കുക:';

  @override
  String get guidelineRespect =>
      'എല്ലാ അംഗങ്ങളോടും ബഹുമാനവും മര്യാദയും കാണിക്കുക.';

  @override
  String get guidelineNoAbuse =>
      'അപമാനകരമായ, ഉപദ്രവിക്കുന്ന അല്ലെങ്കിൽ ദോഷകരമായ ഭാഷ ഉപയോഗിക്കരുത്.';

  @override
  String get guidelineNoHarmful =>
      'അനുചിതമായ അല്ലെങ്കിൽ ദോഷകരമായ ഉള്ളടക്കം പങ്കിടുന്നത് ഒഴിവാക്കുക.';

  @override
  String get guidelineConstructive =>
      'ഇത് കുട്ടികളുടെ സുരക്ഷയെക്കുറിച്ചുള്ള ക്രിയാത്മക ചർച്ചകൾക്കുള്ള ഒരു ഇടമാണ്.';

  @override
  String get discussionTitle => 'ചർച്ച';

  @override
  String get communityDiscussion => 'കമ്മ്യൂണിറ്റി ചർച്ച';

  @override
  String get beFirstToComment => 'നിങ്ങളുടെ ചിന്തകൾ പങ്കിടുന്ന ആദ്യത്തെയാളാകൂ!';

  @override
  String get startTypingBelow => 'താഴെ ടൈപ്പ് ചെയ്യാൻ തുടങ്ങുക';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count അഭിപ്രായങ്ങൾ',
      one: '1 അഭിപ്രായം',
      zero: 'അഭിപ്രായങ്ങളൊന്നുമില്ല',
    );
    return '$_temp0';
  }

  @override
  String get parentalAccessRequired => 'രക്ഷിതാവ് ആക്സസ് ആവശ്യമാണ്';

  @override
  String get parentalAccessDescription =>
      'ഈ വിഭാഗം സംരക്ഷിതമാണ്. തുടരാൻ ദയവായി നിങ്ങളുടെ രക്ഷിതാവ് കീ നൽകുക.';

  @override
  String get invalidKeyTryAgain => 'അസാധുവായ കീ. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get forgotYourKey => 'നിങ്ങളുടെ കീ മറന്നോ?';

  @override
  String get protectedForChildSafety => 'കുട്ടികളുടെ സുരക്ഷയ്ക്കായി സംരക്ഷിതം';

  @override
  String get unlock => 'അൺലോക്ക് ചെയ്യുക';
}
