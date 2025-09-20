import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:guardiancare/src/features/authentication/authentication.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _showTermsAndConditions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 16.0,
          title: const Text('Terms and Conditions',
              style:
                  TextStyle(color: tPrimaryColor, fontWeight: FontWeight.bold)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please read and accept the following terms and conditions to proceed.',
                ),
                SizedBox(height: 10),
                Text(
                  '• Your data will be securely stored.\n'
                  '• You agree to follow the platform rules and regulations.\n'
                  '• You acknowledge the responsibility of safeguarding your account.',
                ),
                // Add more terms and conditions here.
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('I Agree', style: TextStyle(color: tPrimaryColor)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Proceed with Google sign-in if terms are accepted
                context.read<AuthenticationBloc>().add(
                  const AuthenticationSignInRequested(),
                );
              },
            ),
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: tPrimaryColor)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo/logo.png',
                          width: 120,
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'A Children of India App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome to Guardian Care',
                    style: TextStyle(
                      color: Color.fromRGBO(239, 72, 53, 1),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (state is AuthenticationLoading)
                    const CircularProgressIndicator()
                  else
                    Center(
                      child: SizedBox(
                        height: 50,
                        width: 250,
                        child: SignInButton(
                          Buttons.google,
                          text: "Sign In With Google",
                          onPressed: () {
                            // Show the terms and conditions dialog before signing in
                            _showTermsAndConditions(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
