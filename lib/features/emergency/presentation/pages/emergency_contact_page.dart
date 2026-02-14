import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';

/// Education-friendly emergency contact page with modern design
/// Features staggered animations, shimmer loading, and haptic feedback
class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimController;
  late AnimationController _contentAnimController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Header animation
    _headerAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerAnimController,
      curve: AppCurves.emphasizedDecelerate,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: AppCurves.emphasizedDecelerate,
    ));

    // Content stagger animation
    _contentAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    // Start animations
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) => sl<EmergencyBloc>()..add(LoadEmergencyContacts()),
      child: Scaffold(
        backgroundColor: AppColors.videoBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              Expanded(
                child: BlocConsumer<EmergencyBloc, EmergencyState>(
                  listener: _handleStateChanges,
                  builder: (context, state) {
                    if (state is EmergencyLoading) {
                      return _buildLoadingState();
                    }

                    if (state is EmergencyError &&
                        state is! EmergencyContactsLoaded) {
                      return _buildErrorState(context, l10n, state.message);
                    }

                    if (state is EmergencyContactsLoaded) {
                      // Start content animation when loaded
                      _contentAnimController.forward();
                      return _buildContactsList(context, l10n, state);
                    }

                    return _buildLoadingState();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, EmergencyState state) {
    if (state is EmergencyError) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
        ),
      );
    } else if (state is EmergencyCallCompleted) {
      HapticFeedback.mediumImpact();
    }
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceL),
          child: Row(
            children: [
              _buildBackButton(),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(child: _buildHeaderContent(l10n)),
              _buildEmergencyIcon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return ScaleTapWidget(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceS),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildHeaderContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.emergencyContact,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        Text(
          'Quick access to help when you need it',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyIcon() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        gradient: AppColors.emergencyRedGradient,
        borderRadius: AppDimensions.borderRadiusM,
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.emergency_rounded,
        color: AppColors.white,
        size: 28,
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceL),
            child: ShimmerLoading(
              baseColor: AppColors.emergencyShimmerBase,
              highlightColor: AppColors.emergencyShimmerHighlight,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.emergencyShimmerBase,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Something went wrong',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              message,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            ScaleTapWidget(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<EmergencyBloc>().add(LoadEmergencyContacts());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.videoGradient,
                  borderRadius: AppDimensions.borderRadiusM,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.videoPrimarySubtle30,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  l10n.retry,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(
    BuildContext context,
    AppLocalizations l10n,
    EmergencyContactsLoaded state,
  ) {
    final emergencyServices = state.getContactsByCategory('Emergency Services');
    final childSafety = state.getContactsByCategory('Child Safety');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      child: Column(
        children: [
          // Emergency banner
          _buildEmergencyBanner(),
          const SizedBox(height: AppDimensions.spaceL),
          // Emergency Services section
          if (emergencyServices.isNotEmpty)
            _buildAnimatedSection(
              index: 0,
              child: EmergencyContactCard(
                icon: Icons.medical_services_rounded,
                title: l10n.emergencyServices,
                contacts: emergencyServices,
                gradientColors: const [AppColors.cardRed, AppColors.errorDark],
                onCall: (number) => _handleCall(context, number),
              ),
            ),
          const SizedBox(height: AppDimensions.spaceL),
          // Child Safety section
          if (childSafety.isNotEmpty)
            _buildAnimatedSection(
              index: 1,
              child: EmergencyContactCard(
                icon: Icons.child_care_rounded,
                title: l10n.childSafety,
                contacts: childSafety,
                onCall: (number) => _handleCall(context, number),
              ),
            ),
          const SizedBox(height: AppDimensions.spaceXL),
          // Safety tip
          _buildAnimatedSection(
            index: 2,
            child: _buildSafetyTip(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    final delay = index * 0.15;
    final animation = CurvedAnimation(
      parent: _contentAnimController,
      curve:
          Interval(delay, delay + 0.5, curve: AppCurves.emphasizedDecelerate),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withValues(alpha: 0.15),
            AppColors.error.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: AppDimensions.borderRadiusS,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Text(
              'In case of emergency, stay calm and call the appropriate number',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTip() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.videoPrimarySubtle10,
            AppColors.videoPrimarySubtle10.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: AppColors.videoPrimarySubtle30,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceS),
                decoration: BoxDecoration(
                  gradient: AppColors.videoGradient,
                  borderRadius: AppDimensions.borderRadiusS,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Text(
                'Safety Tip',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            'Always share your location with a trusted adult when going out. '
            'Memorize important phone numbers in case you don\'t have access to your phone.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCall(BuildContext context, String number) {
    HapticFeedback.mediumImpact();
    _showCallConfirmation(context, number);
  }

  void _showCallConfirmation(BuildContext context, String number) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CallConfirmationSheet(
        number: number,
        onConfirm: () {
          Navigator.pop(ctx);
          context.read<EmergencyBloc>().add(MakeCallRequested(number));
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }
}

/// Call confirmation bottom sheet
class _CallConfirmationSheet extends StatelessWidget {

  const _CallConfirmationSheet({
    required this.number,
    required this.onConfirm,
    required this.onCancel,
  });
  final String number;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spaceM),
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: AppColors.videoSurface,
        borderRadius: AppDimensions.borderRadiusXL,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            // Phone icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              decoration: BoxDecoration(
                gradient: AppColors.emergencyGreenGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyGreen.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              'Call $number?',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              'You are about to make an emergency call',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ScaleTapWidget(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: ScaleTapWidget(
                    onTap: onConfirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceM,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.emergencyGreenGradient,
                        borderRadius: AppDimensions.borderRadiusM,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.emergencyGreen.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Call Now',
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
