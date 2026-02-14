import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is EmailVerificationSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(FeedbackStrings.emailSent),
                backgroundColor: AppColors.success,
                duration: AppDurations.snackbarMedium,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(FeedbackStrings.errorWith(state.message)),
                backgroundColor: AppColors.error,
                duration: AppDurations.snackbarMedium,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // User verified, navigate home
            context.go('/');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: AppDimensions.elevation0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: AppDimensions.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Email Icon
                      Container(
                        padding: AppDimensions.paddingAllL,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySubtle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          size: AppDimensions.iconXXL + AppDimensions.iconXS,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceXL),

                      // Title
                      Text(
                        'Verify Your Email',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Description
                      Text(
                        'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spaceXL),

                      // Check Verification Button
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const ReloadUserRequested()),
                          icon: isLoading
                              ? const SizedBox(
                                  width: AppDimensions.iconS,
                                  height: AppDimensions.iconS,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white),
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            isLoading
                                ? 'Checking...'
                                : 'I\'ve Verified My Email',
                            style: AppTextStyles.button,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusM,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Resend Email Button
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(const SendEmailVerificationRequested()),
                          icon: isLoading
                              ? const SizedBox(
                                  width: AppDimensions.iconS,
                                  height: AppDimensions.iconS,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(
                            isLoading
                                ? 'Sending...'
                                : 'Resend Verification Email',
                            style: AppTextStyles.button
                                .copyWith(color: AppColors.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                                color: AppColors.primary,
                                width: AppDimensions.borderThick),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusM,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Help Text
                      Container(
                        padding: AppDimensions.paddingAllM,
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: AppDimensions.borderRadiusM,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppColors.info,
                                    size: AppDimensions.iconS),
                                const SizedBox(width: AppDimensions.spaceS),
                                Text(
                                  'Didn\'t receive the email?',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.spaceS),
                            Text(
                              '• Check your spam/junk folder\n'
                              '• Make sure you entered the correct email\n'
                              '• Click "Resend" to get a new verification email',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Back to Login
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Back to Login',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
