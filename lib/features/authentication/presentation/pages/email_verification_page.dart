import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _isChecking = false;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(FeedbackStrings.emailSent),
              backgroundColor: AppColors.success,
              duration: AppDurations.snackbarMedium,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FeedbackStrings.errorWith(e.toString())),
            backgroundColor: AppColors.error,
            duration: AppDurations.snackbarMedium,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkEmailVerified() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;
        
        if (updatedUser != null && updatedUser.emailVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(FeedbackStrings.emailVerified),
                backgroundColor: AppColors.success,
                duration: AppDurations.snackbarMedium,
              ),
            );
            // Navigate to login
            context.go('/login');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(FeedbackStrings.emailNotVerified),
                backgroundColor: AppColors.warning,
                duration: AppDurations.snackbarMedium,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FeedbackStrings.errorWith(e.toString())),
            backgroundColor: AppColors.error,
            duration: AppDurations.snackbarMedium,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: AppDimensions.elevation0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/login'),
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
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: AppDimensions.iconXXL + AppDimensions.iconXS,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXL),

              // Title
              Text(
                'Verify Your Email',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceM),

              // Description
              Text(
                'We\'ve sent a verification link to your email address. Please check your inbox and click the link to verify your account.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceXL),

              // Check Verification Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkEmailVerified,
                  icon: _isChecking
                      ? SizedBox(
                          width: AppDimensions.iconS,
                          height: AppDimensions.iconS,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isChecking ? 'Checking...' : 'I\'ve Verified My Email',
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
              SizedBox(height: AppDimensions.spaceM),

              // Resend Email Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  icon: _isResending
                      ? SizedBox(
                          width: AppDimensions.iconS,
                          height: AppDimensions.iconS,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isResending ? 'Sending...' : 'Resend Verification Email',
                    style: AppTextStyles.button.copyWith(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: AppDimensions.borderThick),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusM,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),

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
                        Icon(Icons.info_outline, color: AppColors.info, size: AppDimensions.iconS),
                        SizedBox(width: AppDimensions.spaceS),
                        Text(
                          'Didn\'t receive the email?',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceS),
                    Text(
                      '• Check your spam/junk folder\n'
                      '• Make sure you entered the correct email\n'
                      '• Click "Resend" to get a new verification email',
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),

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
  }
}
