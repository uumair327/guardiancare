import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern, Play Store compliant Terms and Conditions dialog.
///
/// Features:
/// - COPPA compliant parent/guardian confirmation
/// - Child-friendly language and design
/// - Educational app-specific disclosures
///
/// This widget follows Google Play's Families Policy requirements
/// for apps targeting children and families.
class TermsAndConditionsDialog extends StatefulWidget {

  const TermsAndConditionsDialog({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });
  /// Callback function when the user accepts all terms
  final VoidCallback onAccept;

  /// Callback function when the user declines/cancels
  final VoidCallback onDecline;

  /// Shows the terms and conditions dialog and returns whether the user accepted.
  ///
  /// Returns `true` if the user accepted all terms, `false` if declined,
  /// or `null` if dismissed without action.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withValues(alpha: 0.6),
      builder: (BuildContext dialogContext) {
        return TermsAndConditionsDialog(
          onAccept: () => Navigator.of(dialogContext).pop(true),
          onDecline: () => Navigator.of(dialogContext).pop(false),
        );
      },
    );
  }

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog>
    with SingleTickerProviderStateMixin {
  // Consent checkbox state - only parent/guardian confirmation needed
  bool _isParentOrGuardian = false;

  // Scroll tracking - user must scroll to bottom to accept
  bool _hasScrolledToBottom = false;
  late ScrollController _scrollController;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: AppCurves.standard,
    );
    _animController.forward();

    // Check if content is scrollable after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollable();
    });
  }

  void _checkIfScrollable() {
    if (_scrollController.hasClients) {
      // If content doesn't need scrolling, mark as scrolled
      if (_scrollController.position.maxScrollExtent <= 0) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  void _onScroll() {
    if (!_hasScrolledToBottom && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Consider scrolled to bottom when within 20 pixels of the end
      if (currentScroll >= maxScroll - 20) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Checks if required consent has been given and user has scrolled
  bool get _canAccept => _isParentOrGuardian && _hasScrolledToBottom;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceL,
          vertical: AppDimensions.spaceXL,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppDimensions.borderRadiusXL,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(child: _buildContent()),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusXL),
          topRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: AppDimensions.borderRadiusM,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to GuardianCare',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Please review before continuing',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppDimensions.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Terms and Conditions Section
              Text(
                'Terms and Conditions',
                style: AppTextStyles.h5.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                'Please read and accept the following terms and conditions to proceed.',
                style: AppTextStyles.body2.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),

              // Terms bullet points
              _buildTermItem('Your data will be securely stored.'),
              _buildTermItem(
                  'You agree to follow the platform rules and regulations.'),
              _buildTermItem(
                  'You acknowledge the responsibility of safeguarding your account.'),

              const SizedBox(height: AppDimensions.spaceL),

              // Parent/Guardian Confirmation (COPPA Compliance)
              _buildConsentCheckbox(
                value: _isParentOrGuardian,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _isParentOrGuardian = value ?? false);
                },
                title: 'I am a parent or guardian',
                subtitle: 'I confirm I am 18+ years old and responsible for '
                    'any child using this app',
                icon: Icons.family_restroom_rounded,
                isRequired: true,
              ),
            ],
          ),
        ),
        // Scroll down indicator
        if (!_hasScrolledToBottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceS),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.surface.withValues(alpha: 0),
                    context.colors.surface,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    'Scroll down to accept',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(
                color: context.colors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isRequired,
    VoidCallback? onLinkTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AppDimensions.borderRadiusM,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withValues(alpha: 0.05)
                : context.colors.inputBackground,
            borderRadius: AppDimensions.borderRadiusM,
            border: Border.all(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : context.colors.divider,
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Checkbox
              AnimatedContainer(
                duration: AppDurations.animationShort,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : context.colors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? AppColors.primary : context.colors.divider,
                    width: 2,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: AppDimensions.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: value
                              ? AppColors.primary
                              : context.colors.textSecondary,
                        ),
                        const SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          title,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: value
                                ? AppColors.primary
                                : context.colors.textPrimary,
                          ),
                        ),
                        if (isRequired) ...[
                          const SizedBox(width: AppDimensions.spaceXS),
                          Text(
                            '*',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    if (onLinkTap != null) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onLinkTap,
                        child: Text(
                          'Read full document →',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXL),
          bottomRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Accept Button
          ScaleTapWidget(
            onTap: _canAccept ? widget.onAccept : null,
            enabled: _canAccept,
            child: AnimatedContainer(
              duration: AppDurations.animationShort,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
              decoration: BoxDecoration(
                gradient: _canAccept
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: _canAccept ? null : context.colors.divider,
                borderRadius: AppDimensions.borderRadiusM,
                boxShadow: _canAccept
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'I Agree',
                  style: AppTextStyles.button.copyWith(
                    color: _canAccept
                        ? AppColors.white
                        : context.colors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          // Cancel Button
          TextButton(
            onPressed: widget.onDecline,
            child: Text(
              'Cancel',
              style: AppTextStyles.body2.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
