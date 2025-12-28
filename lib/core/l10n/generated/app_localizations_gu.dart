// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'ગાર્ડિયન કેર';

  @override
  String get home => 'હોમ';

  @override
  String get learn => 'શીખો';

  @override
  String get explore => 'એક્સપ્લોર';

  @override
  String get forum => 'ફોરમ';

  @override
  String get profile => 'પ્રોફાઇલ';

  @override
  String get login => 'લોગિન';

  @override
  String get signup => 'સાઇન અપ';

  @override
  String get email => 'ઇમેઇલ';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get forgotPassword => 'પાસવર્ડ ભૂલી ગયા?';

  @override
  String get logout => 'લોગઆઉટ';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get language => 'ભાષા';

  @override
  String get changeLanguage => 'ભાષા બદલો';

  @override
  String get selectLanguage => 'ભાષા પસંદ કરો';

  @override
  String get account => 'ખાતું';

  @override
  String get emergencyContact => 'કટોકટી સંપર્ક';

  @override
  String get quiz => 'ક્વિઝ';

  @override
  String get videos => 'વિડિઓઝ';

  @override
  String get resources => 'સંસાધનો';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get save => 'સાચવો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get confirm => 'પુષ્ટિ કરો';

  @override
  String get yes => 'હા';

  @override
  String get no => 'ના';

  @override
  String get loading => 'લોડ થઈ રહ્યું છે...';

  @override
  String get error => 'ભૂલ';

  @override
  String get success => 'સફળતા';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count આઇટમ',
      one: '1 આઇટમ',
      zero: 'કોઈ આઇટમ નથી',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'સ્વાગત છે';

  @override
  String welcomeUser(String name) {
    return 'સ્વાગત છે, $name!';
  }

  @override
  String get emergency => 'કટોકટી';

  @override
  String get website => 'વેબસાઇટ';

  @override
  String get mailUs => 'અમને મેઇલ કરો';

  @override
  String get guest => 'મહેમાન';

  @override
  String get quickActions => 'ઝડપી ક્રિયાઓ';

  @override
  String get homeWelcomeMessage =>
      'બાળકો અને પરિવારોને સુરક્ષા જ્ઞાન સાથે સશક્ત બનાવવું';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get back => 'પાછળ';

  @override
  String get next => 'આગળ';

  @override
  String get submit => 'સબમિટ કરો';

  @override
  String get deleteAccount => 'ખાતું કાઢી નાખો';

  @override
  String get deleteAccountConfirm =>
      'શું તમે ખરેખર તમારું ખાતું કાઢી નાખવા માંગો છો? આ ક્રિયા પૂર્વવત્ કરી શકાશે નહીં.';

  @override
  String get accountDeletedSuccess => 'ખાતું સફળતાપૂર્વક કાઢી નાખ્યું';

  @override
  String get logoutConfirm => 'શું તમે ખરેખર લૉગ આઉટ કરવા માંગો છો?';

  @override
  String get deleteMyAccount => 'મારું ખાતું કાઢી નાખો';

  @override
  String get noUserSignedIn => 'હાલમાં કોઈ વપરાશકર્તા સાઇન ઇન નથી';

  @override
  String get loadingProfile => 'પ્રોફાઇલ લોડ થઈ રહી છે...';

  @override
  String get nameLabel => 'નામ';

  @override
  String get emailLabel => 'ઇમેઇલ';

  @override
  String get accountSettings => 'ખાતા સેટિંગ્સ';

  @override
  String get editProfile => 'પ્રોફાઇલ સંપાદિત કરો';

  @override
  String get changePassword => 'પાસવર્ડ બદલો';

  @override
  String get notificationSettings => 'સૂચના સેટિંગ્સ';

  @override
  String get privacySettings => 'ગોપનીયતા સેટિંગ્સ';

  @override
  String get helpSupport => 'મદદ અને સપોર્ટ';

  @override
  String get aboutApp => 'એપ વિશે';

  @override
  String get logoutMessage => 'શું તમે ખરેખર લૉગ આઉટ કરવા માંગો છો?';

  @override
  String get deleteAccountWarning =>
      'આ ક્રિયા પૂર્વવત્ કરી શકાશે નહીં. તમારો તમામ ડેટા કાયમ માટે કાઢી નાખવામાં આવશે.';

  @override
  String get childSafetySettings => 'બાળ સુરક્ષા સેટિંગ્સ';

  @override
  String languageChangedRestarting(String language) {
    return 'ભાષા $language માં બદલાઈ. એપ ફરીથી શરૂ થઈ રહી છે...';
  }

  @override
  String get emergencyServices => 'કટોકટી સેવાઓ';

  @override
  String get childSafety => 'બાળ સુરક્ષા';

  @override
  String get loadingEmergencyContacts => 'કટોકટી સંપર્કો લોડ થઈ રહ્યા છે...';

  @override
  String get noQuizzesAvailable => 'કોઈ ક્વિઝ ઉપલબ્ધ નથી';

  @override
  String get quizQuestions => 'ક્વિઝ પ્રશ્નો';

  @override
  String questionOf(int current, int total) {
    return 'પ્રશ્ન $current નો $total';
  }

  @override
  String get previous => 'પહેલાનું';

  @override
  String get finish => 'સમાપ્ત';

  @override
  String get quizCompleted => 'ક્વિઝ પૂર્ણ થઈ!';

  @override
  String youScored(int score, int total) {
    return 'તમે $total માંથી $score સ્કોર કર્યો';
  }

  @override
  String get generatingRecommendations => 'વ્યક્તિગત ભલામણો બનાવી રહ્યા છીએ';

  @override
  String get checkExploreTab => 'તમારી ભલામણો જોવા માટે એક્સપ્લોર ટેબ તપાસો!';

  @override
  String get backToQuizzes => 'ક્વિઝ પર પાછા જાઓ';

  @override
  String get viewRecommendations => 'ભલામણો જુઓ';

  @override
  String get noCategoriesAvailable => 'કોઈ શ્રેણીઓ ઉપલબ્ધ નથી';

  @override
  String get noVideosAvailable => 'કોઈ વિડિઓઝ ઉપલબ્ધ નથી';

  @override
  String get forums => 'ફોરમ';

  @override
  String get forumDiscussion => 'ફોરમ ચર્ચા';

  @override
  String get parentForums => 'પેરેન્ટ ફોરમ';

  @override
  String get noForumsAvailable => 'કોઈ ફોરમ ઉપલબ્ધ નથી';

  @override
  String get noCommentsYet => 'હજી સુધી કોઈ ટિપ્પણી નથી. પ્રથમ ટિપ્પણી કરો!';

  @override
  String get commentPostedSuccess => 'ટિપ્પણી સફળતાપૂર્વક પોસ્ટ થઈ!';

  @override
  String get commentSubmittedSuccess => 'ટિપ્પણી સફળતાપૂર્વક સબમિટ થઈ!';

  @override
  String get pleaseEnterComment => 'કૃપા કરીને ટિપ્પણી દાખલ કરો';

  @override
  String get commentMinLength => 'ટિપ્પણી ઓછામાં ઓછી 2 અક્ષરની હોવી જોઈએ';

  @override
  String get pullToRefresh => 'રિફ્રેશ કરવા માટે ખેંચો';

  @override
  String get pullDownToRefresh => 'રિફ્રેશ કરવા માટે નીચે ખેંચો';

  @override
  String get somethingWentWrong => 'કંઈક ખોટું થયું';

  @override
  String get recommendedForYou => 'તમારા માટે ભલામણ કરેલ';

  @override
  String get takeAQuiz => 'ક્વિઝ લો';

  @override
  String get noRecommendationsYet => 'હજી સુધી કોઈ ભલામણ નથી';

  @override
  String get takeQuizForRecommendations =>
      'તમારી રુચિઓના આધારે વ્યક્તિગત વિડિઓ ભલામણો મેળવવા માટે ક્વિઝ લો!';

  @override
  String get loginToViewRecommendations =>
      'ભલામણો જોવા માટે કૃપા કરીને લૉગ ઇન કરો';

  @override
  String get agreeToTerms => 'હું નિયમો અને શરતો સાથે સંમત છું';

  @override
  String get pleaseAgreeToTerms => 'કૃપા કરીને નિયમો અને શરતો સાથે સંમત થાઓ';

  @override
  String get isChildAbove12 => 'શું બાળક 12 વર્ષથી વધુ ઉંમરનું છે?';

  @override
  String get parentalKeyMinLength =>
      'પેરેન્ટલ કી ઓછામાં ઓછી 4 અક્ષરની હોવી જોઈએ';

  @override
  String get incorrectAnswer => 'ખોટો જવાબ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get parentalKeyResetSuccess => 'પેરેન્ટલ કી સફળતાપૂર્વક રીસેટ થઈ!';

  @override
  String get parentGuardian => 'માતાપિતા/વાલી';

  @override
  String get child => 'બાળક';

  @override
  String get couldNotLaunchEmail => 'ઇમેઇલ ક્લાયંટ લોંચ કરી શકાયું નહીં';

  @override
  String errorLaunchingEmail(String error) {
    return 'ઇમેઇલ લોંચ કરવામાં ભૂલ: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'ભૂલ: $error';
  }

  @override
  String get noResourcesAvailable => 'કોઈ સંસાધનો ઉપલબ્ધ નથી';

  @override
  String get forChildren => 'બાળકો માટે';

  @override
  String get connectAndShare => 'જોડાઓ અને અનુભવો શેર કરો';

  @override
  String get beFirstToDiscuss => 'ચર્ચા શરૂ કરનાર પ્રથમ બનો!';

  @override
  String get guidelinesTitle => 'ફોરમ માર્ગદર્શિકા';

  @override
  String get guidelinesWelcome =>
      'ગાર્ડિયન કેર ફોરમમાં આપનું સ્વાગત છે. કૃપા કરીને આ માર્ગદર્શિકાઓનું પાલન કરો:';

  @override
  String get guidelineRespect => 'બધા સભ્યો પ્રત્યે આદરપૂર્ણ અને નમ્ર રહો.';

  @override
  String get guidelineNoAbuse =>
      'અપમાનજનક, હેરાન કરનારી અથવા હાનિકારક ભાષાનો ઉપયોગ ન કરો.';

  @override
  String get guidelineNoHarmful =>
      'અયોગ્ય અથવા હાનિકારક સામગ્રી શેર કરવાનું ટાળો.';

  @override
  String get guidelineConstructive =>
      'આ બાળ સુરક્ષા પર રચનાત્મક ચર્ચાઓ માટેની જગ્યા છે.';

  @override
  String get discussionTitle => 'ચર્ચા';

  @override
  String get communityDiscussion => 'સમુદાય ચર્ચા';

  @override
  String get beFirstToComment => 'તમારા વિચારો શેર કરનાર પ્રથમ બનો!';

  @override
  String get startTypingBelow => 'નીચે ટાઇપ કરવાનું શરૂ કરો';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ટિપ્પણીઓ',
      one: '1 ટિપ્પણી',
      zero: 'કોઈ ટિપ્પણી નથી',
    );
    return '$_temp0';
  }

  @override
  String get parentalAccessRequired => 'પેરેન્ટલ એક્સેસ જરૂરી';

  @override
  String get parentalAccessDescription =>
      'આ વિભાગ સુરક્ષિત છે। ચાલુ રાખવા માટે કૃપા કરીને તમારી પેરેન્ટલ કી દાખલ કરો.';

  @override
  String get invalidKeyTryAgain => 'અમાન્ય કી. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get forgotYourKey => 'તમારી કી ભૂલી ગયા?';

  @override
  String get protectedForChildSafety => 'બાળ સુરક્ષા માટે સુરક્ષિત';

  @override
  String get unlock => 'અનલૉક કરો';
}
