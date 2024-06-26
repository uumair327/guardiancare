import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardiancare/src/core/common/loader.dart';
import 'package:guardiancare/src/core/common/sign_in_button.dart';
import 'package:guardiancare/src/features/authentication/controllers/auth_controller.dart';
import 'package:guardiancare/src/responsive/responsive.dart';
import 'package:guardiancare/src/constants/colors.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      // appBar: AppBar(
      //   title: Image.asset(
      //     Constants.logoPath,
      //     height: 40,
      //   ),
      //   actions: [
      //     TextButton(
      //       onPressed: () => signInAsGuest(ref, context),
      //       child: const Text(
      //         'Skip',
      //         style: TextStyle(
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: isLoading
          ? const Loader()
          : Column(
              children: [
                const SizedBox(height: 100),
                const Text(
                  'Children of India',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: tPrimaryColor,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/logo/logo_CIF.jpg',
                    height: 200,
                  ),
                ),
                const SizedBox(height: 20),
                const Responsive(child: SignInButton()),
              ],
            ),
    );
  }
}
