import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modern, Play Store compliant Terms and Conditions dialog.
///
/// Features:
/// - COPPA/GDPR compliant privacy disclosures
/// - Child-friendly language and design
/// - Explicit consent checkboxes for data collection
/// - Links to full privacy policy and terms of service
/// - Educational app-specific disclosures
///
/// This widget follows Google Play's Families Policy requirements
/// for apps targeting children and families.
class TermsAndConditionsDialog extends StatefulWidget {
  /// Callback function when the user accepts all terms
  final VoidCallback onAccept;

  /// Callback function when the user declines/cancels
  final VoidCallback onDecline;

  const TermsAndConditionsDialog({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

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
  // Consent checkboxes state
  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedDataCollection = false;
  bool _isParentOrGuardian = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: AppCurves.standard,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Checks if all required consents have been given
  bool get _canAccept =>
      _acceptedTerms &&
      _acceptedPrivacy &&
      _acceptedDataCollection &&
      _isParentOrGuardian;

  /// Launches external URL for privacy policy or terms
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceL,
          vertical: AppDimensions.spaceXL,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
      padding: EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
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
            padding: EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: AppDimensions.borderRadiusM,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: AppColors.white,
              size: 28,
            ),
          ),
          SizedBox(width: AppDimensions.spaceM),
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
                SizedBox(height: 2),
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Purpose Section
          _buildInfoCard(
            icon: Icons.school_rounded,
            title: 'Educational Safety App',
            description:
                'GuardianCare helps families learn about child safety through '
                'educational content, quizzes, and community discussions.',
            color: const Color(0xFF10B981),
          ),
          SizedBox(height: AppDimensions.spaceM),

          // Data Collection Disclosure
          _buildInfoCard(
            icon: Icons.security_rounded,
            title: 'How We Protect Your Data',
            description:
                'We collect minimal data needed to provide our services:\n'
                '• Account info (name, email) for personalization\n'
                '• Quiz progress to track learning\n'
                '• No data is shared with third parties for advertising',
            color: const Color(0xFF3B82F6),
          ),
          SizedBox(height: AppDimensions.spaceL),

          // Consent Checkboxes
          Text(
            'Please confirm the following:',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceM),

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

          // Terms of Service
          _buildConsentCheckbox(
            value: _acceptedTerms,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _acceptedTerms = value ?? false);
            },
            title: 'Terms of Service',
            subtitle: 'I agree to the terms of service and community guidelines',
            icon: Icons.description_rounded,
            isRequired: true,
            onLinkTap: () => _launchUrl(
              'https://guardiancare.app/terms',
            ),
          ),

          // Privacy Policy
          _buildConsentCheckbox(
            value: _acceptedPrivacy,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _acceptedPrivacy = value ?? false);
            },
            title: 'Privacy Policy',
            subtitle: 'I have read and accept the privacy policy',
            icon: Icons.privacy_tip_rounded,
            isRequired: true,
            onLinkTap: () => _launchUrl(
              'https://guardiancare.app/privacy',
            ),
          ),

          // Data Collection Consent
          _buildConsentCheckbox(
            value: _acceptedDataCollection,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _acceptedDataCollection = value ?? false);
            },
            title: 'Data Collection',
            subtitle: 'I consent to the collection of data as described above '
                'to improve the educational experience',
            icon: Icons.analytics_rounded,
            isRequired: true,
          ),

          SizedBox(height: AppDimensions.spaceM),

          // Additional Info
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: AppDimensions.borderRadiusM,
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
                SizedBox(width: AppDimensions.spaceS),
                Expanded(
                  child: Text(
                    'You can manage your data and privacy settings anytime '
                    'from your account page. We never sell your personal information.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppDimensions.borderRadiusS,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXS),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
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
      padding: EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AppDimensions.borderRadiusM,
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withValues(alpha: 0.05)
                : AppColors.gray100,
            borderRadius: AppDimensions.borderRadiusM,
            border: Border.all(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.gray200,
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
                  color: value ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? AppColors.primary : AppColors.gray300,
                    width: 2,
                  ),
                ),
                child: value
                    ? Icon(
                        Icons.check_rounded,
                        color: AppColors.white,
                        size: 16,
                      )
                    : null,
              ),
              SizedBox(width: AppDimensions.spaceM),
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
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          title,
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: value
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (isRequired) ...[
                          SizedBox(width: AppDimensions.spaceXS),
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
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (onLinkTap != null) ...[
                      SizedBox(height: 4),
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
      padding: EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.only(
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
              padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
              decoration: BoxDecoration(
                gradient: _canAccept
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      )
                    : null,
                color: _canAccept ? null : AppColors.gray300,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: _canAccept ? AppColors.white : AppColors.gray500,
                    size: 20,
                  ),
                  SizedBox(width: AppDimensions.spaceS),
                  Text(
                    'Accept & Continue',
                    style: AppTextStyles.button.copyWith(
                      color: _canAccept ? AppColors.white : AppColors.gray500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceS),
          // Decline Button
          TextButton(
            onPressed: widget.onDecline,
            child: Text(
              'Not Now',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
