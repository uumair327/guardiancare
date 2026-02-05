import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern, educational-friendly Parental Consent Setup Form
///
/// Design Principles:
/// - Child-safe, family-friendly visual design
/// - COPPA/GDPR compliant consent collection
/// - Clear step-by-step wizard flow
/// - Accessible and inclusive UI
/// - Play Store Families Policy compliant
///
/// Architecture: Follows Clean Architecture + SOLID principles
/// - Single Responsibility: Each step widget handles one concern
/// - Open/Closed: Extensible step system
/// - Dependency Inversion: Uses abstractions for data operations
class EnhancedConsentFormPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const EnhancedConsentFormPage({
    super.key,
    required this.onSubmit,
  });

  @override
  State<EnhancedConsentFormPage> createState() =>
      _EnhancedConsentFormPageState();
}

class _EnhancedConsentFormPageState extends State<EnhancedConsentFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _parentEmailController = TextEditingController();
  final _childNameController = TextEditingController();
  final _keyController = TextEditingController();
  final _confirmKeyController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _agreedToTerms = false;
  bool _isChildAbove12 = false;
  bool _obscureKey = true;
  bool _obscureConfirmKey = true;
  bool _obscureAnswer = true;
  bool _isSubmitting = false;
  int _currentStep = 0;

  String? _selectedSecurityQuestion;

  // Security questions - educational and family-friendly
  final List<String> _securityQuestions = [
    'What is your favorite family activity?',
    'What is your child\'s favorite book?',
    'What city did you grow up in?',
    'What is your favorite childhood memory?',
    'What is your pet\'s name?',
  ];

  // Step configuration for wizard flow
  static const int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _parentEmailController.dispose();
    _childNameController.dispose();
    _keyController.dispose();
    _confirmKeyController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  String _hashString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      _animController.reset();
      setState(() => _currentStep++);
      _animController.forward();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    _animController.reset();
    setState(() => _currentStep--);
    _animController.forward();
  }

  Future<void> _submitConsent() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showErrorSnackBar(FeedbackStrings.agreementRequired);
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final user = sl<IAuthService>().currentUser;
      if (user == null) throw Exception('No user logged in');

      final consent = ConsentEntity(
        parentName: '', // Not collected in form
        parentEmail: _parentEmailController.text.trim(),
        childName: _childNameController.text.trim(),
        isChildAbove12: _isChildAbove12,
        parentalKeyHash: _hashString(_keyController.text),
        securityQuestion: _selectedSecurityQuestion ?? '',
        securityAnswerHash:
            _hashString(_securityAnswerController.text.toLowerCase().trim()),
        timestamp: DateTime.now(),
        consentCheckboxes: {
          'termsAccepted': true,
          'parentConsentGiven': true,
          'privacyPolicyAccepted': true,
        },
      );

      final result =
          await sl<ConsentRepository>().submitConsent(consent, user.id);

      result.fold((failure) {
        if (mounted)
          _showErrorSnackBar(FeedbackStrings.errorWith(failure.message));
      }, (_) {
        widget.onSubmit();
      });
    } catch (e) {
      if (mounted) _showErrorSnackBar(FeedbackStrings.errorWith(e.toString()));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusS),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
                      child: Form(
                        key: _formKey,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildCurrentStep(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXL),
          bottomRight: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // Icon with friendly design
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom_rounded,
              size: AppDimensions.iconXL,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppDimensions.spaceM),
          Text(
            UIStrings.parentalConsentSetup,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceXS),
          Text(
            UIStrings.protectYourChild,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceL),
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSteps, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: AppDurations.animationShort,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : Text(
                        '${index + 1}',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isActive ? AppColors.primary : AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (index < _totalSteps - 1)
              AnimatedContainer(
                duration: AppDurations.animationShort,
                width: 40,
                height: 3,
                margin: EdgeInsets.symmetric(horizontal: AppDimensions.spaceXS),
                decoration: BoxDecoration(
                  color: index < _currentStep
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ParentInfo();
      case 1:
        return _buildStep2ParentalKey();
      case 2:
        return _buildStep3SecurityQuestion();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1ParentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.person_rounded,
          title: UIStrings.parentInformation,
          subtitle: 'Help us keep your family safe',
        ),
        SizedBox(height: AppDimensions.spaceL),
        _buildModernTextField(
          controller: _parentEmailController,
          label: UIStrings.parentEmail,
          hint: UIStrings.parentEmailHint,
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty)
              return ValidationStrings.parentEmailRequired;
            if (!value.contains('@')) return ValidationStrings.emailInvalid;
            return null;
          },
        ),
        SizedBox(height: AppDimensions.spaceM),
        _buildModernTextField(
          controller: _childNameController,
          label: UIStrings.childName,
          hint: UIStrings.childNameHint,
          icon: Icons.child_care_rounded,
          validator: (value) {
            if (value == null || value.isEmpty)
              return ValidationStrings.childNameRequired;
            return null;
          },
        ),
        SizedBox(height: AppDimensions.spaceL),
        _buildAgeToggle(),
      ],
    );
  }

  Widget _buildStep2ParentalKey() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.lock_rounded,
          title: UIStrings.setParentalKey,
          subtitle: UIStrings.parentalKeyDescription,
        ),
        SizedBox(height: AppDimensions.spaceL),
        _buildModernTextField(
          controller: _keyController,
          label: UIStrings.parentalKey,
          hint: UIStrings.minCharactersHint,
          icon: Icons.vpn_key_rounded,
          obscureText: _obscureKey,
          suffixIcon: IconButton(
            icon: Icon(_obscureKey
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded),
            onPressed: () => setState(() => _obscureKey = !_obscureKey),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return ValidationStrings.parentalKeyRequired;
            if (value.length < 4) return ValidationStrings.parentalKeyMinLength;
            return null;
          },
        ),
        SizedBox(height: AppDimensions.spaceM),
        _buildModernTextField(
          controller: _confirmKeyController,
          label: UIStrings.confirmParentalKey,
          hint: UIStrings.reenterKeyHint,
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmKey,
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmKey
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded),
            onPressed: () =>
                setState(() => _obscureConfirmKey = !_obscureConfirmKey),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return ValidationStrings.confirmParentalKeyRequired;
            if (value != _keyController.text)
              return ValidationStrings.keysDoNotMatch;
            return null;
          },
        ),
        SizedBox(height: AppDimensions.spaceL),
        _buildInfoCard(
          icon: Icons.info_outline_rounded,
          text:
              'Your parental key protects sensitive features. Keep it safe and memorable!',
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStep3SecurityQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.security_rounded,
          title: UIStrings.securityQuestion,
          subtitle: UIStrings.securityQuestionDescription,
        ),
        SizedBox(height: AppDimensions.spaceL),
        _buildModernDropdown(),
        SizedBox(height: AppDimensions.spaceM),
        _buildModernTextField(
          controller: _securityAnswerController,
          label: UIStrings.yourAnswer,
          hint: UIStrings.enterAnswerHint,
          icon: Icons.question_answer_rounded,
          obscureText: _obscureAnswer,
          suffixIcon: IconButton(
            icon: Icon(_obscureAnswer
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded),
            onPressed: () => setState(() => _obscureAnswer = !_obscureAnswer),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return ValidationStrings.answerRequired;
            if (value.length < 2) return ValidationStrings.answerMinLength;
            return null;
          },
        ),
        SizedBox(height: AppDimensions.spaceL),
        _buildTermsCheckbox(),
        SizedBox(height: AppDimensions.spaceM),
        _buildInfoCard(
          icon: Icons.shield_rounded,
          text:
              'Your security answer helps recover your parental key if forgotten.',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusL,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceS),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: AppDimensions.borderRadiusM,
            ),
            child:
                Icon(icon, color: AppColors.primary, size: AppDimensions.iconM),
          ),
          SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXXS),
                Text(
                  subtitle,
                  style: AppTextStyles.caption
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.body1.copyWith(color: context.colors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              AppTextStyles.label.copyWith(color: context.colors.textSecondary),
          hintText: hint,
          hintStyle:
              AppTextStyles.hint.copyWith(color: context.colors.textTertiary),
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide(color: context.colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: EdgeInsets.all(AppDimensions.spaceM),
        ),
        validator: validator,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
  }

  Widget _buildModernDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedSecurityQuestion,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: UIStrings.selectSecurityQuestion,
          labelStyle:
              AppTextStyles.label.copyWith(color: context.colors.textSecondary),
          prefixIcon:
              Icon(Icons.help_outline_rounded, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide(color: context.colors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusL,
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: EdgeInsets.all(AppDimensions.spaceM),
        ),
        items: _securityQuestions.map((question) {
          return DropdownMenuItem(
            value: question,
            child: Text(
              question,
              style: AppTextStyles.body2
                  .copyWith(color: context.colors.textPrimary),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedSecurityQuestion = value),
        validator: (value) {
          if (value == null || value.isEmpty)
            return ValidationStrings.securityQuestionRequired;
          return null;
        },
      ),
    );
  }

  Widget _buildAgeToggle() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: _isChildAbove12 ? AppColors.primary : context.colors.border,
          width: _isChildAbove12 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _isChildAbove12 = !_isChildAbove12);
        },
        borderRadius: AppDimensions.borderRadiusL,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceS),
              decoration: BoxDecoration(
                color: _isChildAbove12
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.gray100,
                borderRadius: AppDimensions.borderRadiusM,
              ),
              child: Icon(
                Icons.cake_rounded,
                color: _isChildAbove12
                    ? AppColors.primary
                    : context.colors.textSecondary,
              ),
            ),
            SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UIStrings.isChildAbove12,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    'Additional features for older children',
                    style: AppTextStyles.caption
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _isChildAbove12,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _isChildAbove12 = value);
              },
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.gray400;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: _agreedToTerms
            ? AppColors.success.withValues(alpha: 0.08)
            : context.colors.surface,
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: _agreedToTerms ? AppColors.success : context.colors.border,
          width: _agreedToTerms ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _agreedToTerms = !_agreedToTerms);
        },
        borderRadius: AppDimensions.borderRadiusL,
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppDurations.animationShort,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color:
                    _agreedToTerms ? AppColors.success : context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _agreedToTerms ? AppColors.success : AppColors.gray400,
                  width: 2,
                ),
              ),
              child: _agreedToTerms
                  ? Icon(Icons.check_rounded, color: AppColors.white, size: 18)
                  : null,
            ),
            SizedBox(width: AppDimensions.spaceM),
            Expanded(
              child: Text(
                UIStrings.agreeToTerms,
                style: AppTextStyles.body2.copyWith(
                  color: _agreedToTerms
                      ? AppColors.success
                      : context.colors.textPrimary,
                  fontWeight:
                      _agreedToTerms ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconS),
          SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0)
              Expanded(
                child: ScaleTapWidget(
                  onTap: _previousStep,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceVariant,
                      borderRadius: AppDimensions.borderRadiusM,
                    ),
                    child: Center(
                      child: Text(
                        UIStrings.back,
                        style: AppTextStyles.button
                            .copyWith(color: context.colors.textSecondary),
                      ),
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            SizedBox(width: AppDimensions.spaceM),
            // Next/Submit button
            Expanded(
              flex: 2,
              child: ScaleTapWidget(
                onTap: _isSubmitting
                    ? null
                    : (_currentStep < _totalSteps - 1
                        ? _nextStep
                        : _submitConsent),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: AppDimensions.borderRadiusM,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.white),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentStep < _totalSteps - 1
                                    ? UIStrings.next
                                    : UIStrings.submit,
                                style: AppTextStyles.button,
                              ),
                              if (_currentStep < _totalSteps - 1) ...[
                                SizedBox(width: AppDimensions.spaceXS),
                                Icon(Icons.arrow_forward_rounded,
                                    color: AppColors.white, size: 18),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
