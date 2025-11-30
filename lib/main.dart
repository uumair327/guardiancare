import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/core/routing/app_router.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/core/services/parental_verification_service.dart';
import 'package:guardiancare/core/services/locale_service.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';
import 'package:guardiancare/core/widgets/app_restart_widget.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    const AppRestartWidget(
      child: guardiancareApp(),
    ),
  );
}

class guardiancareApp extends StatelessWidget {
  const guardiancareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const guardiancare();
  }
}

class guardiancare extends StatefulWidget {
  const guardiancare({super.key});

  @override
  State<guardiancare> createState() => GuardiancareState();
  
  // Static method to access state from anywhere
  static GuardiancareState? of(BuildContext context) {
    return context.findAncestorStateOfType<GuardiancareState>();
  }
}

class GuardiancareState extends State<guardiancare> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _verificationService = ParentalVerificationService();
  User? _user;
  Locale _locale = const Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load saved locale
    _loadSavedLocale();
    
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      // Reset verification when user logs out
      if (user == null) {
        _verificationService.resetVerification();
      }
    });
    print("I am the user: $_user");
  }

  Future<void> _loadSavedLocale() async {
    final localeService = di.sl<LocaleService>();
    final savedLocale = localeService.getSavedLocale();
    print('📱 Loading saved locale: ${savedLocale?.languageCode ?? "none (using default)"}');
    if (savedLocale != null) {
      setState(() {
        _locale = savedLocale;
      });
      print('✅ Loaded locale: ${_locale.languageCode}');
    }
  }

  void changeLocale(Locale newLocale) {
    print('🔄 GuardiancareState.changeLocale called with: ${newLocale.languageCode}');
    
    // Update state FIRST
    setState(() {
      _locale = newLocale;
    });
    
    // Then save to storage
    final localeService = di.sl<LocaleService>();
    localeService.saveLocale(newLocale);
    
    print('✅ Locale changed to: ${_locale.languageCode}');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reset verification when app is paused/closed
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _verificationService.resetVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp.router(
        key: ValueKey(_locale.languageCode), // Force rebuild on locale change
        title: "Guardian Care",
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        
        // Localization configuration
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('hi'), // Hindi
          Locale('mr'), // Marathi
          Locale('gu'), // Gujarati
          Locale('bn'), // Bengali
          Locale('ta'), // Tamil
          Locale('te'), // Telugu
          Locale('kn'), // Kannada
          Locale('ml'), // Malayalam
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Always use the saved/selected locale
          return _locale;
        },
      ),
    );
  }
}
