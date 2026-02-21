import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guardiancare/core/config/env.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/di/di.dart' as di;
import 'package:guardiancare/core/util/logger.dart';
import 'package:guardiancare/features/features.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (Security Audit Requirement)
  await Env.init();

  // Log backend configuration
  Log.i('=== Backend Configuration ===');
  Log.i('Provider: ${BackendConfig.provider.name}');
  Log.i('Supabase Auth: ${BackendConfig.useSupabaseAuth}');
  Log.i('Supabase Database: ${BackendConfig.useSupabaseDatabase}');
  Log.i('Supabase Storage: ${BackendConfig.useSupabaseStorage}');
  Log.i('Supabase Realtime: ${BackendConfig.useSupabaseRealtime}');
  Log.i('=============================');

  // Initialize Firebase (always - for Crashlytics, Analytics, Remote Config)
  // Firebase is initialized even when using Supabase for data
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    Log.i('Firebase initialized successfully');
  } on Object catch (e) {
    if (e.toString().contains('duplicate-app')) {
      Log.w('Firebase already initialized, skipping...');
    } else {
      rethrow;
    }
  }

  // Initialize Supabase if any Supabase features are enabled
  // This is conditional - won't initialize if only Firebase is used
  try {
    final supabaseInitialized = await SupabaseInitializer.initializeIfNeeded();
    if (supabaseInitialized) {
      Log.i('Supabase initialized successfully');
    }
  } on Object catch (e) {
    Log.e('Supabase initialization failed: $e');
    // Don't rethrow - allow app to continue with Firebase fallback
    // In production, you may want to handle this differently
  }

  // Initialize dependency injection
  await di.init();

  // Start the feature flag real-time stream as early as possible.
  // Singleton from DI — same instance used everywhere in the app.
  di.sl<FeatureFlagCubit>().startListening();
  Log.i('Feature flags stream started');

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
/// - ThemeManager: handles theme/dark mode changes
/// - AppLifecycleManager: handles app lifecycle events
///
/// Follows Dependency Inversion Principle:
/// - Uses IAuthService abstraction instead of FirebaseAuth directly
/// - Uses BackendUser instead of Firebase User
class GuardiancareState extends State<Guardiancare>
    with WidgetsBindingObserver {
  // Managers injected via dependency injection
  late final AuthStateManager _authManager;
  late final LocaleManager _localeManager;
  late final ThemeManager _themeManager;
  late final AppLifecycleManager _lifecycleManager;

  // Subscriptions for cleanup
  StreamSubscription<BackendUser?>? _authSubscription;
  StreamSubscription<AuthStateEvent>? _authEventSubscription;
  StreamSubscription<Locale>? _localeSubscription;
  StreamSubscription<ThemeMode>? _themeSubscription;

  // Local state for UI updates (now using BackendUser)
  BackendUser? _user;
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Get managers from dependency injection
    _authManager = di.sl<AuthStateManager>();
    _localeManager = di.sl<LocaleManager>();
    _themeManager = di.sl<ThemeManager>();
    _lifecycleManager = di.sl<AppLifecycleManager>();

    // Initialize managers and set up subscriptions
    _initializeManagers();

    Log.d("GuardiancareState initialized with managers");
  }

  void _initializeManagers() {
    // Load saved locale through LocaleManager
    _localeManager.loadSavedLocale().then((_) {
      setState(() {
        _locale = _localeManager.currentLocale;
      });
    });

    // Load saved theme through ThemeManager
    _themeManager.loadSavedTheme().then((_) {
      setState(() {
        _themeMode = _themeManager.currentThemeMode;
      });
    });

    // Subscribe to locale changes from LocaleManager
    _localeSubscription = _localeManager.localeChanges.listen((locale) {
      setState(() {
        _locale = locale;
      });
    });

    // Subscribe to theme changes from ThemeManager
    _themeSubscription = _themeManager.themeChanges.listen((themeMode) {
      setState(() {
        _themeMode = themeMode;
      });
    });

    // Subscribe to auth state changes through AuthStateManager
    // Now uses BackendUser instead of Firebase User (DIP compliance)
    _authSubscription =
        _authManager.authStateChanges.listen((BackendUser? user) {
      setState(() {
        _user = user;
      });
      Log.d("User state updated: ${_user?.id}");
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
    Log.d(
        'GuardiancareState: Requesting locale change to ${newLocale.languageCode}');
    _localeManager.changeLocale(newLocale);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _authEventSubscription?.cancel();
    _localeSubscription?.cancel();
    _themeSubscription?.cancel();
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
      child: BlocProvider<FeatureFlagCubit>.value(
        value: di.sl<FeatureFlagCubit>(),
        child: MaterialApp.router(
          title: AppStrings.appName,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,

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
      ),
    );
  }
}
