import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';
import 'package:guardiancare/core/di/di.dart' as di;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

  // Crashlytics is not supported on web
  if (!kIsWeb) {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    const AppRestartWidget(
      child: GuardiancareApp(),
    ),
  );
}

class GuardiancareApp extends StatelessWidget {
  const GuardiancareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Guardiancare();
  }
}

class Guardiancare extends StatefulWidget {
  const Guardiancare({super.key});

  @override
  State<Guardiancare> createState() => GuardiancareState();
  
  // Static method to access state from anywhere
  static GuardiancareState? of(BuildContext context) {
    return context.findAncestorStateOfType<GuardiancareState>();
  }
}

/// Main application state
/// Follows Single Responsibility Principle by delegating to managers:
/// - AuthStateManager: handles authentication state
/// - LocaleManager: handles locale/language changes
/// - AppLifecycleManager: handles app lifecycle events
class GuardiancareState extends State<Guardiancare> with WidgetsBindingObserver {
  // Managers injected via dependency injection
  late final AuthStateManager _authManager;
  late final LocaleManager _localeManager;
  late final AppLifecycleManager _lifecycleManager;

  // Subscriptions for cleanup
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AuthStateEvent>? _authEventSubscription;
  StreamSubscription<Locale>? _localeSubscription;

  // Local state for UI updates
  User? _user;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Get managers from dependency injection
    _authManager = di.sl<AuthStateManager>();
    _localeManager = di.sl<LocaleManager>();
    _lifecycleManager = di.sl<AppLifecycleManager>();
    
    // Initialize managers and set up subscriptions
    _initializeManagers();
    
    debugPrint("GuardiancareState initialized with managers");
  }

  void _initializeManagers() {
    // Load saved locale through LocaleManager
    _localeManager.loadSavedLocale().then((_) {
      setState(() {
        _locale = _localeManager.currentLocale;
      });
    });

    // Subscribe to locale changes from LocaleManager
    _localeSubscription = _localeManager.localeChanges.listen((locale) {
      setState(() {
        _locale = locale;
      });
    });

    // Subscribe to auth state changes through AuthStateManager
    _authSubscription = _authManager.authStateChanges.listen((User? user) {
      setState(() {
        _user = user;
      });
      debugPrint("User state updated: ${_user?.uid}");
    });

    // Subscribe to auth events for logout notifications
    _authEventSubscription = _authManager.authEvents.listen((event) {
      if (event.type == AuthStateEventType.logout) {
        // Delegate logout handling to lifecycle manager
        _lifecycleManager.onPaused();
      }
    });
  }

  /// Change locale - delegates to LocaleManager
  void changeLocale(Locale newLocale) {
    debugPrint('GuardiancareState: Requesting locale change to ${newLocale.languageCode}');
    _localeManager.changeLocale(newLocale);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _authEventSubscription?.cancel();
    _localeSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Delegate lifecycle events to AppLifecycleManager
    switch (state) {
      case AppLifecycleState.paused:
        _lifecycleManager.onPaused();
        break;
      case AppLifecycleState.detached:
        _lifecycleManager.onDetached();
        break;
      case AppLifecycleState.resumed:
        _lifecycleManager.onResumed();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: MaterialApp.router(
        title: AppStrings.appName,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        
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
