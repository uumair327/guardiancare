import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';
import 'package:sign_in_button/sign_in_button.dart';

/// Login page that composes widgets without containing dialog logic.
/// 
/// This page follows the Single Responsibility Principle by delegating
/// the terms and conditions dialog rendering to TermsAndConditionsDialog widget.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final accepted = await TermsAndConditionsDialog.show(context);
    if (accepted == true && context.mounted) {
      context.read<AuthBloc>().add(const SignInWithGoogleRequested());
    }
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

              return _buildLoginContent(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      child: Column(
        children: [
          SizedBox(height: AppDimensions.spaceXXL),
          _buildLogoSection(),
          SizedBox(height: AppDimensions.spaceL),
          _buildWelcomeSection(),
          SizedBox(height: AppDimensions.spaceXL),
          _buildSignInButton(context),
          SizedBox(height: AppDimensions.spaceM),
          _buildInfoText(),
          SizedBox(height: AppDimensions.spaceL),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      child: SignInButton(
        Buttons.google,
        text: "Sign In With Google",
        onPressed: () => _handleGoogleSignIn(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Text(
      'Sign in with your Google account to continue',
      style: AppTextStyles.body2.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
