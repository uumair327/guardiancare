import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';

/// Modern, education-friendly login page
/// Features engaging animations, child-safe design, and welcoming visuals.
///
/// Supports multiple auth methods controlled by [BackendConfig] feature flags:
/// - Email/Password (when [BackendConfig.enableEmailAuth] is true)
/// - Google Sign-In (when [BackendConfig.enableGoogleSignIn] is true)
/// - Apple Sign-In (when [BackendConfig.enableAppleSignIn] is true)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;

  // Email/password form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 40),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Initiates Google Sign-In flow after user accepts terms and conditions.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    unawaited(HapticFeedback.mediumImpact());
    final accepted = await TermsAndConditionsDialog.show(context);
    if (accepted == true && context.mounted) {
      context.read<AuthBloc>().add(const SignInWithGoogleRequested());
    }
  }

  /// Handles email/password sign-in after form validation.
  void _handleEmailSignIn(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      unawaited(HapticFeedback.mediumImpact());
      context.read<AuthBloc>().add(
            SignInWithEmailRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(const CheckAuthStatus()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: context.colors.background,
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                if (state.code == 'email-not-verified') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.warning,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Verify',
                        textColor: AppColors.white,
                        onPressed: () => context.push('/email-verification'),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.white, size: 20),
                          const SizedBox(width: AppDimensions.spaceS),
                          Expanded(child: Text(state.message)),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                    ),
                  );
                }
              } else if (state is AuthAuthenticated) {
                context.go('/');
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  // Background decorations
                  _buildBackgroundDecorations(),
                  // Main content — centred on wide screens
                  SafeArea(
                    child: state is AuthLoading
                        ? _buildLoadingState()
                        : Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 480,
                              ),
                              child: _buildLoginContent(context),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Top-right decoration
        Positioned(
          top: -50,
          right: -50,
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom-left decoration
        Positioned(
          bottom: -80,
          left: -80,
          child: AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          Text(
            'Signing you in...',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH),
        child: AnimatedBuilder(
          animation: _mainController,
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
              const SizedBox(height: AppDimensions.spaceXL),
              _buildHeader(l10n),
              const SizedBox(height: AppDimensions.spaceL),
              _buildIllustration(),
              const SizedBox(height: AppDimensions.spaceL),
              _buildWelcomeCard(context, l10n),
              const SizedBox(height: AppDimensions.spaceL),
              _buildFeaturesList(l10n),
              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with app branding.
  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: AppDimensions.borderRadiusM,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceS),
        Text(
          AppStrings.appName,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.5),
          child: child,
        );
      },
      child: SizedBox(
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            // Logo
            Image.asset(
              AppAssets.logo,
              width: 110,
              height: 110,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Welcome text
          Text(
            l10n.welcome,
            style: AppTextStyles.h2.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            'Join us in keeping children safe',
            style: AppTextStyles.body2.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceL),

          // Email/Password Sign-In Form
          if (BackendConfig.enableEmailAuth) ...[
            _buildEmailSignInForm(context),
            const SizedBox(height: AppDimensions.spaceM),
          ],

          // Divider between auth methods
          if (BackendConfig.enableEmailAuth &&
              BackendConfig.enableGoogleSignIn) ...[
            _buildDivider(),
            const SizedBox(height: AppDimensions.spaceM),
          ],

          // Google Sign In Button
          if (BackendConfig.enableGoogleSignIn) ...[
            _buildGoogleSignInButton(context),
            const SizedBox(height: AppDimensions.spaceM),
          ],

          // Info text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spaceXS),
              Text(
                'Secure sign-in',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Create Account link (only when email auth is enabled)
          if (BackendConfig.enableEmailAuth) ...[
            const SizedBox(height: AppDimensions.spaceM),
            _buildCreateAccountLink(context),
          ],
        ],
      ),
    );
  }

  /// Builds the email/password sign-in form.
  Widget _buildEmailSignInForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
                borderSide: const BorderSide(
                  color: AppColors.gray200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: context.colors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceM,
                vertical: AppDimensions.spaceM,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleEmailSignIn(context),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
                borderSide: const BorderSide(
                  color: AppColors.gray200,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: context.colors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceM,
                vertical: AppDimensions.spaceM,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),

          // Forgot Password link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/password-reset'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spaceXS,
                ),
              ),
              child: Text(
                'Forgot Password?',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),

          // Sign In button
          ScaleTapWidget(
            onTap: () => _handleEmailSignIn(context),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: AppDimensions.borderRadiusM,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Sign In',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the divider between auth methods.
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.gray200,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          child: Text(
            'OR',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.gray200,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ScaleTapWidget(
      onTap: () => _handleGoogleSignIn(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppDimensions.borderRadiusM,
          border: Border.all(
            color: AppColors.gray200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google logo
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.network(
                'https://www.google.com/favicon.ico',
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.g_mobiledata_rounded,
                    color: AppColors.primary,
                    size: 24,
                  );
                },
              ),
            ),
            const SizedBox(width: AppDimensions.spaceM),
            Text(
              'Continue with Google',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 'Create Account' link.
  Widget _buildCreateAccountLink(BuildContext context) {
    return TextButton(
      onPressed: () => context.push('/signup'),
      child: Text.rich(
        TextSpan(
          text: "Don't have an account? ",
          style: AppTextStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
          children: const [
            TextSpan(
              text: 'Create Account',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    final features = [
      const _FeatureItem(
        icon: Icons.school_rounded,
        title: 'Learn Safety',
        description: 'Educational content for children',
        color: AppColors.cardEmerald,
      ),
      const _FeatureItem(
        icon: Icons.forum_rounded,
        title: 'Community',
        description: 'Connect with other parents',
        color: AppColors.videoPrimary,
      ),
      const _FeatureItem(
        icon: Icons.emergency_rounded,
        title: 'Emergency Help',
        description: 'Quick access to helplines',
        color: AppColors.error,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.spaceXS),
          child: Text(
            'What you can do',
            style: AppTextStyles.h5.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        ...features.asMap().entries.map((entry) {
          return FadeSlideWidget(
            delay: Duration(milliseconds: 600 + (entry.key * 100)),
            child: _buildFeatureCard(entry.value),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: feature.color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderRadiusM,
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  feature.description,
                  style: AppTextStyles.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
}
