import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/authentication/controllers/login_controller.dart';
import 'package:get/get.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/features/authentication/screens/login_page.dart';
import 'package:guardiancare/src/routing/app_router.dart' as router;
import 'firebase_options.dart';

/// Global navigator key for accessing the navigator without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Initialize Firebase and other services
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
      reason: 'a non-fatal error',
    );
    return true;
  };

  // Only enable Crashlytics in production
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  // Set user identifier for Crashlytics
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
  }
}

void main() async {
  // Run the app in a zone to catch all errors
  runZonedGuarded<Future<void>>(
    () async {
      try {
        await initializeApp();
        
        // Initialize AuthController before the app starts
        await Get.putAsync(() async => FirebaseAuthService());
        Get.put(AuthController());
        
        runApp(const GuardianCareApp());
      } catch (error, stackTrace) {
        // Handle any errors during initialization
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          fatal: true,
          reason: 'Error during app initialization',
        );
        
        // Show error UI if the app fails to initialize
        ErrorWidget.builder = (FlutterErrorDetails details) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${details.exception}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart the app
                      main();
                    },
                    child: const Text('Restart App'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    },
    (error, stackTrace) {
      // Handle errors that occur in the app
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: true,
        reason: 'Unhandled error in main zone',
      );
    },
  );
}

class GuardianCareApp extends StatelessWidget {
  const GuardianCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guardian Care',
      debugShowCheckedModeBanner: false,
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
      ),
      initialRoute: router.AppRouter.initialRoute,
      getPages: router.AppRouter.routes,
      navigatorKey: navigatorKey,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      // Get the already initialized controllers
      final authController = Get.find<AuthController>();
      
      // Configure routes
      router.AppRouter.configureRoutes();
      
      // Initial navigation based on auth state
      void navigateBasedOnAuth() {
        if (!mounted || _disposed) return;
        
        if (_isLoading) {
          setState(() => _isLoading = false);
        }
        
        if (authController.isAuthenticated) {
          Get.offAllNamed(router.AppRouter.home);
        } else {
          Get.offAllNamed(router.AppRouter.login);
        }
      }
      
      // If already initialized, navigate immediately
      if (authController.isInitialized) {
        if (!_disposed) {
          navigateBasedOnAuth();
        }
        return;
      }
      
      // Otherwise, wait for the first auth state change
      bool shouldNavigate = false;
      _authSubscription = authController.userStream.listen((user) {
        if (authController.isInitialized && !shouldNavigate && !_disposed) {
          shouldNavigate = true;
          if (mounted && !_disposed) {
            navigateBasedOnAuth();
          }
        }
      });
      
      // Set a timeout to prevent hanging
      await Future.delayed(const Duration(seconds: 5));
      if (mounted && _isLoading && !_disposed) {
        if (!shouldNavigate) {
          debugPrint('Auth initialization timed out, navigating to login');
          setState(() => _isLoading = false);
          Get.offAllNamed(router.AppRouter.login);
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        navigatorKey.currentState?.pushReplacementNamed(router.AppRouter.login);
      }
    }
  }

  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;
  
  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
