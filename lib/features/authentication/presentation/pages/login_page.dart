import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _showTermsAndConditions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: AppDimensions.dialogElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
          ),
          title: Text(
            'Terms and Conditions',
            style: AppTextStyles.dialogTitle,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'Please read and accept the following terms and conditions to proceed.',
                  style: AppTextStyles.body2,
                ),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  '• Your data will be securely stored.\n'
                  '• You agree to follow the platform rules and regulations.\n'
                  '• You acknowledge the responsibility of safeguarding your account.',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('I Agree', style: AppTextStyles.button),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const SignInWithGoogleRequested());
              },
            ),
            TextButton(
              child: Text('Cancel', style: AppTextStyles.button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(const CheckAuthStatus()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  duration: AppDurations.snackbarMedium,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.screenPaddingH),
              child: Column(
                children: [
                  SizedBox(height: AppDimensions.spaceXXL),
                  // Logo and Title
                  Image.asset(
                    AppAssets.logo,
                    width: AppDimensions.logoM,
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    AppStrings.appTagline,
                    style: AppTextStyles.italic.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    'Sign in to continue',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXL),

                  // Google Sign In Button
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    width: double.infinity,
                    child: SignInButton(
                      Buttons.google,
                      text: "Sign In With Google",
                      onPressed: () {
                        _showTermsAndConditions(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppDimensions.spaceM),
                  
                  // Info text
                  Text(
                    'Sign in with your Google account to continue',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppDimensions.spaceL),
                ],
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}
