import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';

/// Modern, education-friendly login page
/// Features engaging animations, child-safe design, and welcoming visuals
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
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
    super.dispose();
  }

  /// Initiates Google Sign-In flow after user accepts terms and conditions.
  ///
  /// Shows terms dialog first, then triggers authentication if accepted.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final accepted = await TermsAndConditionsDialog.show(context);
    if (accepted == true && context.mounted) {
      context.read<AuthBloc>().add(const SignInWithGoogleRequested());
    }
  }

  // NOTE: Skip functionality has been removed for production.
  // Authentication is now required to access the app.
  // If guest access is needed in the future, implement a proper
  // guest user flow with limited permissions instead of bypassing auth.

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: AppColors.white, size: 20),
                        SizedBox(width: AppDimensions.spaceS),
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
              } else if (state is AuthAuthenticated) {
                context.go('/');
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  // Background decorations
                  _buildBackgroundDecorations(),
                  // Main content
                  SafeArea(
                    child: state is AuthLoading
                        ? _buildLoadingState()
                        : _buildLoginContent(context),
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
                    AppColors.primary.withValues(alpha: 0.0),
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
                    AppColors.primary.withValues(alpha: 0.0),
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
            padding: EdgeInsets.all(AppDimensions.spaceL),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: AppDimensions.spaceL),
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
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
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
              SizedBox(height: AppDimensions.spaceXL),
              _buildHeader(l10n),
              SizedBox(height: AppDimensions.spaceXL),
              _buildIllustration(),
              SizedBox(height: AppDimensions.spaceXL),
              _buildWelcomeCard(context, l10n),
              SizedBox(height: AppDimensions.spaceL),
              _buildFeaturesList(l10n),
              SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with app branding.
  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
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
          child: Icon(
            Icons.shield_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
        SizedBox(width: AppDimensions.spaceS),
        Text(
          AppStrings.appName,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        // NOTE: Skip button removed - authentication is required for production.
        // To re-enable guest access, add a proper guest user implementation
        // with appropriate permission restrictions.
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
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background glow
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // Logo
            Image.asset(
              AppAssets.logo,
              width: 140,
              height: 140,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceL),
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
          SizedBox(height: AppDimensions.spaceXS),
          Text(
            'Join us in keeping children safe',
            style: AppTextStyles.body2.copyWith(
              color: context.colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceL),
          // Google Sign In Button
          _buildGoogleSignInButton(context),
          SizedBox(height: AppDimensions.spaceM),
          // Info text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppDimensions.spaceXS),
              Text(
                'Secure sign-in with Google',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ScaleTapWidget(
      onTap: () => _handleGoogleSignIn(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
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
                  return Icon(
                    Icons.g_mobiledata_rounded,
                    color: AppColors.primary,
                    size: 24,
                  );
                },
              ),
            ),
            SizedBox(width: AppDimensions.spaceM),
            Text(
              'Continue with Google',
              style: AppTextStyles.button.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations l10n) {
    final features = [
      _FeatureItem(
        icon: Icons.school_rounded,
        title: 'Learn Safety',
        description: 'Educational content for children',
        color: AppColors.cardEmerald,
      ),
      _FeatureItem(
        icon: Icons.forum_rounded,
        title: 'Community',
        description: 'Connect with other parents',
        color: AppColors.videoPrimary,
      ),
      _FeatureItem(
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
          padding: EdgeInsets.only(left: AppDimensions.spaceXS),
          child: Text(
            'What you can do',
            style: AppTextStyles.h5.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spaceM),
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
      margin: EdgeInsets.only(bottom: AppDimensions.spaceS),
      padding: EdgeInsets.all(AppDimensions.spaceM),
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
            padding: EdgeInsets.all(AppDimensions.spaceS),
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
          SizedBox(width: AppDimensions.spaceM),
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
          Icon(
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
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
