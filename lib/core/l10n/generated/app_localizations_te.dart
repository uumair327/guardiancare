// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'గార్డియన్ కేర్';

  @override
  String get home => 'హోమ్';

  @override
  String get learn => 'నేర్చుకోండి';

  @override
  String get explore => 'అన్వేషించండి';

  @override
  String get forum => 'ఫోరమ్';

  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get login => 'లాగిన్';

  @override
  String get signup => 'సైన్ అప్';

  @override
  String get email => 'ఇమెయిల్';

  @override
  String get password => 'పాస్‌వర్డ్';

  @override
  String get forgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get logout => 'లాగ్అవుట్';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get language => 'భాష';

  @override
  String get changeLanguage => 'భాషను మార్చండి';

  @override
  String get selectLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get account => 'ఖాతా';

  @override
  String get emergencyContact => 'అత్యవసర సంప్రదింపు';

  @override
  String get quiz => 'క్విజ్';

  @override
  String get videos => 'వీడియోలు';

  @override
  String get resources => 'వనరులు';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get delete => 'తొలగించండి';

  @override
  String get confirm => 'నిర్ధారించండి';

  @override
  String get yes => 'అవును';

  @override
  String get no => 'కాదు';

  @override
  String get loading => 'లోడ్ అవుతోంది...';

  @override
  String get error => 'లోపం';

  @override
  String get success => 'విజయం';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అంశాలు',
      one: '1 అంశం',
      zero: 'అంశాలు లేవు',
    );
    return '$_temp0';
  }

  @override
  String get welcome => 'స్వాగతం';

  @override
  String welcomeUser(String name) {
    return 'స్వాగతం, $name!';
  }

  @override
  String get emergency => 'అత్యవసరం';

  @override
  String get website => 'వెబ్‌సైట్';

  @override
  String get mailUs => 'మాకు మెయిల్ చేయండి';

  @override
  String get guest => 'అతిథి';

  @override
  String get quickActions => 'త్వరిత చర్యలు';

  @override
  String get homeWelcomeMessage =>
      'పిల్లలు మరియు కుటుంబాలకు భద్రతా జ్ఞానంతో శక్తినిస్తోంది';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get back => 'వెనుకకు';

  @override
  String get next => 'తదుపరి';

  @override
  String get submit => 'సమర్పించండి';

  @override
  String get deleteAccount => 'ఖాతాను తొలగించండి';

  @override
  String get deleteAccountConfirm =>
      'మీరు మీ ఖాతాను తొలగించాలనుకుంటున్నారా? ఈ చర్యను రద్దు చేయలేరు.';

  @override
  String get accountDeletedSuccess => 'ఖాతా విజయవంతంగా తొలగించబడింది';

  @override
  String get logoutConfirm => 'మీరు లాగ్ అవుట్ చేయాలనుకుంటున్నారా?';

  @override
  String get deleteMyAccount => 'నా ఖాతాను తొలగించండి';

  @override
  String get noUserSignedIn => 'ప్రస్తుతం ఎవరూ సైన్ ఇన్ చేయలేదు';

  @override
  String get loadingProfile => 'ప్రొఫైల్ లోడ్ అవుతోంది...';

  @override
  String get nameLabel => 'పేరు';

  @override
  String get emailLabel => 'ఇమెయిల్';

  @override
  String get accountSettings => 'ఖాతా సెట్టింగ్‌లు';

  @override
  String get editProfile => 'ప్రొఫైల్‌ను సవరించండి';

  @override
  String get changePassword => 'పాస్‌వర్డ్ మార్చండి';

  @override
  String get notificationSettings => 'నోటిఫికేషన్ సెట్టింగ్‌లు';

  @override
  String get privacySettings => 'గోప్యత సెట్టింగ్‌లు';

  @override
  String get helpSupport => 'సహాయం & మద్దతు';

  @override
  String get aboutApp => 'యాప్ గురించి';

  @override
  String get logoutMessage => 'మీరు లాగ్ అవుట్ చేయాలనుకుంటున్నారా?';

  @override
  String get deleteAccountWarning =>
      'ఈ చర్యను రద్దు చేయలేరు. మీ మొత్తం డేటా శాశ్వతంగా తొలగించబడుతుంది.';

  @override
  String get childSafetySettings => 'పిల్లల భద్రత సెట్టింగ్‌లు';

  @override
  String languageChangedRestarting(String language) {
    return 'భాష $languageకి మార్చబడింది. యాప్ పునఃప్రారంభమవుతోంది...';
  }

  @override
  String get emergencyServices => 'అత్యవసర సేవలు';

  @override
  String get childSafety => 'పిల్లల భద్రత';

  @override
  String get loadingEmergencyContacts =>
      'అత్యవసర సంప్రదింపులు లోడ్ అవుతున్నాయి...';

  @override
  String get noQuizzesAvailable => 'క్విజ్‌లు అందుబాటులో లేవు';

  @override
  String get quizQuestions => 'క్విజ్ ప్రశ్నలు';

  @override
  String questionOf(int current, int total) {
    return 'ప్రశ్న $current యొక్క $total';
  }

  @override
  String get previous => 'మునుపటి';

  @override
  String get finish => 'ముగించు';

  @override
  String get quizCompleted => 'క్విజ్ పూర్తయింది!';

  @override
  String youScored(int score, int total) {
    return 'మీరు $total లో $score స్కోర్ చేసారు';
  }

  @override
  String get generatingRecommendations =>
      'వ్యక్తిగత సిఫార్సులను రూపొందిస్తోంది';

  @override
  String get checkExploreTab =>
      'మీ సిఫార్సులను చూడటానికి ఎక్స్‌ప్లోర్ ట్యాబ్‌ను తనిఖీ చేయండి!';

  @override
  String get backToQuizzes => 'క్విజ్‌లకు తిరిగి వెళ్ళండి';

  @override
  String get viewRecommendations => 'సిఫార్సులను చూడండి';

  @override
  String get noCategoriesAvailable => 'వర్గాలు అందుబాటులో లేవు';

  @override
  String get noVideosAvailable => 'వీడియోలు అందుబాటులో లేవు';

  @override
  String get forums => 'ఫోరమ్‌లు';

  @override
  String get forumDiscussion => 'ఫోరమ్ చర్చ';

  @override
  String get parentForums => 'తల్లిదండ్రుల ఫోరమ్‌లు';

  @override
  String get noForumsAvailable => 'ఫోరమ్‌లు అందుబాటులో లేవు';

  @override
  String get noCommentsYet => 'ఇంకా వ్యాఖ్యలు లేవు. మొదటి వ్యాఖ్య చేయండి!';

  @override
  String get commentPostedSuccess => 'వ్యాఖ్య విజయవంతంగా పోస్ట్ చేయబడింది!';

  @override
  String get commentSubmittedSuccess => 'వ్యాఖ్య విజయవంతంగా సమర్పించబడింది!';

  @override
  String get pleaseEnterComment => 'దయచేసి వ్యాఖ్యను నమోదు చేయండి';

  @override
  String get commentMinLength => 'వ్యాఖ్య కనీసం 2 అక్షరాలు ఉండాలి';

  @override
  String get pullToRefresh => 'రిఫ్రెష్ చేయడానికి లాగండి';

  @override
  String get pullDownToRefresh => 'రిఫ్రెష్ చేయడానికి క్రిందికి లాగండి';

  @override
  String get somethingWentWrong => 'ఏదో తప్పు జరిగింది';

  @override
  String get recommendedForYou => 'మీ కోసం సిఫార్సు చేయబడినవి';

  @override
  String get takeAQuiz => 'క్విజ్ తీసుకోండి';

  @override
  String get noRecommendationsYet => 'ఇంకా సిఫార్సులు లేవు';

  @override
  String get takeQuizForRecommendations =>
      'మీ ఆసక్తుల ఆధారంగా వ్యక్తిగతీకరించిన వీడియో సిఫార్సులను పొందడానికి క్విజ్ తీసుకోండి!';

  @override
  String get loginToViewRecommendations =>
      'సిఫార్సులను చూడటానికి దయచేసి లాగిన్ అవ్వండి';

  @override
  String get agreeToTerms => 'నేను నిబంధనలు మరియు షరతులను అంగీకరిస్తున్నాను';

  @override
  String get pleaseAgreeToTerms => 'దయచేసి నిబంధనలు మరియు షరతులను అంగీకరించండి';

  @override
  String get isChildAbove12 =>
      'పిల్లవాడు 12 సంవత్సరాల కంటే ఎక్కువ వయస్సు ఉన్నారా?';

  @override
  String get parentalKeyMinLength => 'తల్లిదండ్రుల కీ కనీసం 4 అక్షరాలు ఉండాలి';

  @override
  String get incorrectAnswer => 'తప్పు సమాధానం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get parentalKeyResetSuccess =>
      'తల్లిదండ్రుల కీ విజయవంతంగా రీసెట్ చేయబడింది!';

  @override
  String get parentGuardian => 'తల్లిదండ్రులు/సంరక్షకుడు';

  @override
  String get child => 'పిల్లవాడు';

  @override
  String get couldNotLaunchEmail => 'ఇమెయిల్ క్లయింట్‌ను ప్రారంభించలేకపోయింది';

  @override
  String errorLaunchingEmail(String error) {
    return 'ఇమెయిల్ ప్రారంభించడంలో లోపం: $error';
  }

  @override
  String errorPrefix(String error) {
    return 'లోపం: $error';
  }

  @override
  String get noResourcesAvailable => 'వనరులు అందుబాటులో లేవు';

  @override
  String get forChildren => 'పిల్లల కోసం';

  @override
  String get connectAndShare => 'కనెక్ట్ అవ్వండి మరియు అనుభవాలను పంచుకోండి';

  @override
  String get beFirstToDiscuss => 'చర్చను ప్రారంభించే మొదటి వ్యక్తి అవ్వండి!';

  @override
  String get guidelinesTitle => 'ఫోరమ్ మార్గదర్శకాలు';

  @override
  String get guidelinesWelcome =>
      'గార్డియన్ కేర్ ఫోరమ్‌కు స్వాగతం. దయచేసి ఈ మార్గదర్శకాలను అనుసరించండి:';

  @override
  String get guidelineRespect =>
      'అన్ని సభ్యులతో గౌరవంగా మరియు మర్యాదగా ఉండండి.';

  @override
  String get guidelineNoAbuse =>
      'అవమానకరమైన, వేధింపు లేదా హానికరమైన భాషను ఉపయోగించకండి.';

  @override
  String get guidelineNoHarmful =>
      'అనుచితమైన లేదా హానికరమైన కంటెంట్‌ను పంచుకోకుండా ఉండండి.';

  @override
  String get guidelineConstructive =>
      'ఇది పిల్లల భద్రతపై నిర్మాణాత్మక చర్చల కోసం ఒక స్థలం.';

  @override
  String get discussionTitle => 'చర్చ';

  @override
  String get communityDiscussion => 'సమాజ చర్చ';

  @override
  String get beFirstToComment => 'మీ ఆలోచనలను పంచుకునే మొదటి వ్యక్తి అవ్వండి!';

  @override
  String get startTypingBelow => 'క్రింద టైప్ చేయడం ప్రారంభించండి';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count వ్యాఖ్యలు',
      one: '1 వ్యాఖ్య',
      zero: 'వ్యాఖ్యలు లేవు',
    );
    return '$_temp0';
  }

  @override
  String get parentalAccessRequired => 'తల్లిదండ్రుల యాక్సెస్ అవసరం';

  @override
  String get parentalAccessDescription =>
      'ఈ విభాగం రక్షించబడింది. కొనసాగించడానికి దయచేసి మీ తల్లిదండ్రుల కీని నమోదు చేయండి.';

  @override
  String get invalidKeyTryAgain => 'చెల్లని కీ. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get forgotYourKey => 'మీ కీని మర్చిపోయారా?';

  @override
  String get protectedForChildSafety => 'పిల్లల భద్రత కోసం రక్షించబడింది';

  @override
  String get unlock => 'అన్‌లాక్ చేయండి';
}
