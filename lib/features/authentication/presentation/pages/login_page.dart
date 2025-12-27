import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';
import 'package:sign_in_button/sign_in_button.dart';

/// Login page that composes widgets without containing dialog logic.
/// 
/// This page follows the Single Responsibility Principle by delegating
/// the terms and conditions dialog rendering to TermsAndConditionsDialog widget.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    HapticFeedback.lightImpact();
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
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                  ),
                );
              } else if (state is AuthAuthenticated) {
                // Navigate to home after successful login
                context.go('/');
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: _slideAnimation.value,
              child: child,
            ),
          );
        },
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
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Animated logo with pulse effect
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: AppDurations.animationLong,
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Image.asset(
            AppAssets.logo,
            width: AppDimensions.logoM,
          ),
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
    return Container(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
