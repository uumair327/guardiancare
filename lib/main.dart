import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:guardiancare/src/core/web/web_init.dart' if (dart.library.html) 'package:guardiancare/src/core/web/web_init_web.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_service.dart';
import 'package:guardiancare/src/features/authentication/controllers/login_controller.dart';
import 'package:guardiancare/src/routing/app_router.dart' as router;
import 'package:guardiancare/firebase_options.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

// Import the appropriate implementation based on the platform
import 'package:guardiancare/src/core/web/web_init.dart' if (dart.library.html) 'package:guardiancare/src/core/web/web_init_web.dart';

// This import will be tree-shaken away in non-web builds
import 'dart:io' show Platform;
// Only import flutter_web_plugins for web
// Create a stub for non-web platforms
import 'src/core/web/url_strategy_stub.dart'
  if (dart.library.html) 'package:flutter_web_plugins/flutter_web_plugins.dart';

void setPlatformSpecificUrlStrategy() {
  if (kIsWeb) {
    // Web-specific URL strategy
    try {
      setPathUrlStrategy();
    } catch (e) {
      debugPrint('Error setting web URL strategy: $e');
    }
  } else {
    debugPrint('Using default mobile URL strategy.');
  }
}

/// Global navigator key for accessing the navigator without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Handle errors during app startup
void _handleStartupError(dynamic error, StackTrace stackTrace) {
  developer.log('Startup error', error: error, stackTrace: stackTrace);
  if (!kIsWeb) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      fatal: true,
      reason: 'Error during app initialization',
    );
  }
  
  // Show error UI
  ErrorWidget.builder = (FlutterErrorDetails details) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => runApp(const GuardianCareApp()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    // Configure web URL strategy
    if (kIsWeb) {
      try {
        // This will use the web-specific implementation on web
        // and the stub implementation on other platforms
        final webInit = WebInit();
        webInit.configureApp();
      } catch (e) {
        debugPrint('Web initialization error: $e');
      }
    }

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Crashlytics (not available on web)
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }
  } catch (e, stackTrace) {
    _handleStartupError(e, stackTrace);
    rethrow; // Re-throw to prevent the app from starting in a bad state
  }
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeApp();

  // Set URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    try {
      setPathUrlStrategy();
    } catch (e) {
      debugPrint('Error setting URL strategy: $e');
    }
  }

  // Initialize GetX services and controllers
  Get.put(AuthService());
  Get.put(AuthController());
  Get.put(LoginController());

  // Set up error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // Run the app
  runApp(const GuardianCareApp());
}

// Removed as it's not needed with current Flutter web implementation

class GuardianCareApp extends StatelessWidget {
  const GuardianCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guardian Care',
      debugShowCheckedModeBanner: false,
      initialRoute: router.AppRouter.initialRoute,
      getPages: router.AppRouter.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends GetView<AuthController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading) {
        return _buildLoadingScreen();
      }

      // Use a post frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = controller.isAuthenticated 
            ? router.AppRouter.home 
            : router.AppRouter.login;
        Get.offAllNamed(route);
      });

      return _buildLoadingScreen();
    });
  }

  Widget _buildLoadingScreen() => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
}
