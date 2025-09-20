import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/core/core.dart';
import 'package:guardiancare/src/features/authentication/authentication.dart';
import 'package:guardiancare/src/features/consent/consent.dart';
import 'package:guardiancare/src/features/home/home.dart';
import 'package:guardiancare/src/features/forum/forum.dart';
import 'package:guardiancare/src/features/profile/profile.dart';
import 'package:guardiancare/src/features/quiz/quiz.dart';
import 'package:guardiancare/src/features/authentication/screens/login_page.dart';
import 'package:guardiancare/src/routing/pages.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await DependencyInjection.init();

  // Set up BLoC observer for logging and error reporting
  if (kDebugMode) {
    // Use enhanced debugging observer in debug mode
    Bloc.observer = DebugBlocObserver();
    BlocPerformanceMonitor.startMonitoring();
    
    // Run architecture validation after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      BlocValidation.printValidationReport();
    });
  } else {
    // Use standard observer in release mode
    Bloc.observer = AppBlocObserver();
  }

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const GuardianCareApp());
}

class GuardianCareApp extends StatelessWidget {
  const GuardianCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => DependencyInjection.get<AuthenticationBloc>()
            ..add(const AuthenticationStarted()),
        ),
        BlocProvider<NavigationCubit>(
          create: (context) => DependencyInjection.get<NavigationCubit>(),
        ),
        BlocProvider<ConsentBloc>(
          create: (context) => DependencyInjection.get<ConsentBloc>(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => DependencyInjection.get<HomeBloc>(),
        ),
        BlocProvider<ForumBloc>(
          create: (context) => DependencyInjection.get<ForumBloc>(),
        ),
        BlocProvider<CommentBloc>(
          create: (context) => DependencyInjection.get<CommentBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => DependencyInjection.get<ProfileBloc>(),
        ),
        BlocProvider<QuizBloc>(
          create: (context) => DependencyInjection.get<QuizBloc>(),
        ),
      ],
      child: const GuardianCare(),
    );
  }
}

class GuardianCare extends StatelessWidget {
  const GuardianCare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Guardian Care",
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationLoading || state is AuthenticationInitial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthenticationAuthenticated) {
            return const Pages();
          } else if (state is AuthenticationUnauthenticated) {
            return const LoginPage();
          } else if (state is AuthenticationError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthenticationBloc>().add(
                          const AuthenticationStarted(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Fallback state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false, // debug symbol remove
    );
  }
}
