import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/router.dart';
import 'package:guardiancare/src/core/common/error_text.dart';
import 'package:guardiancare/src/core/common/loader.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/features/authentication/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardiancare/src/utils/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   // Pass all uncaught "fatal" errors from the framework to Crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // // Pass all uncaught errors from the framework to Crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  runApp(
    const ProviderScope(
      child: GuardianCare(),
    ),
  );
}

class guardiancare extends ConsumerStatefulWidget {
  const guardiancare({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _guardiancareState();
}

// ignore: camel_case_types
class _guardiancareState extends ConsumerState<guardiancare> {
  @override
  Widget build(BuildContext context) {
    return const GuardianCare();
  }
}

class GuardianCare extends ConsumerStatefulWidget {
  const GuardianCare({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuardianCareState();
}

class _GuardianCareState extends ConsumerState<GuardianCare> {
  UserModel? userModel;

  void getData(WidgetRef ref, User data) async {
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);
  }


  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: "Children of India",
  //     home: _user != null ? const Pages() : const LoginPage(),
  //     debugShowCheckedModeBanner: false,
  //   );
  // }
  
  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
          data: (data) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Guardian Care',
            theme: ref.watch(themeNotifierProvider),
            routerDelegate: RoutemasterDelegate(
              routesBuilder: (context) {
                if (data != null) {
                  getData(ref, data);
                  if (ref.watch(userProvider)!= null) {
                    return loggedInRoute;
                  }
                }
                print('Returning loggedOutRoute');
                return loggedOutRoute;
              },
            ),
            routeInformationParser: const RoutemasterParser(),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
