import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';

/// Modern parental lock overlay widget
/// Displays inline on the page with blur effect
/// Syncs with ParentalVerificationService session state
/// Follows SRP - only handles UI presentation
class ParentalLockOverlay extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onForgotKey;
  final Widget child;

  const ParentalLockOverlay({
    super.key,
    required this.onUnlocked,
    this.onForgotKey,
    required this.child,
  });

  @override
  State<ParentalLockOverlay> createState() => _ParentalLockOverlayState();
}

class _ParentalLockOverlayState extends State<ParentalLockOverlay>
    with SingleTickerProviderStateMixin {
  final TextEditingController _keyController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  bool _obscureKey = true;
  bool _isLoading = false;
  bool _showError = false;
  bool _isLocked = true;
  bool _serviceAvailable = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Check session state after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionState();
    });
  }

  void _checkSessionState() {
    try {
      final service = ParentalVerificationService();
      _serviceAvailable = true;
      
      if (service.isVerifiedForSession) {
        // Already verified in this session
        setState(() => _isLocked = false);
        widget.onUnlocked();
      } else {
        // Need to show lock overlay
        setState(() => _isLocked = true);
        _animationController.forward();
      }
    } catch (e) {
      // Service not initialized - show lock overlay
      debugPrint('ParentalVerificationService not available: $e');
      setState(() => _isLocked = true);
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final key = _keyController.text.trim();
    
    if (key.length < 4) {
      setState(() => _showError = true);
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    bool isValid = false;
    
    if (_serviceAvailable) {
      try {
        final service = ParentalVerificationService();
        isValid = await service.verifyParentalKey(key);
      } catch (e) {
        debugPrint('Verification error: $e');
      }
    }

    if (!mounted) return;

    if (isValid) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isLoading = false;
        _isLocked = false;
      });
      
      // Animate out then call callback
      await _animationController.reverse();
      widget.onUnlocked();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isLoading = false;
        _showError = true;
      });
      _keyController.clear();
      
      // Shake animation
      _shakeAnimation();
    }
  }

  void _shakeAnimation() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        _animationController.value = 0.95;
      }
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        _animationController.value = 1.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If unlocked, just show the child
    if (!_isLocked) {
      return widget.child;
    }

    return Stack(
      children: [
        // Blurred background content (show placeholder when locked)
        AbsorbPointer(
          absorbing: true,
          child: widget.child,
        ),
        
        // Blur overlay
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10 * _fadeAnimation.value,
                  sigmaY: 10 * _fadeAnimation.value,
                ),
                child: Container(
                  color: AppColors.black.withValues(
                    alpha: 0.4 * _fadeAnimation.value,
                  ),
                ),
              );
            },
          ),
        ),
        
        // Lock card
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
              );
            },
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDimensions.screenPaddingH),
                  child: _buildLockCard(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(AppDimensions.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderRadiusXL,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon with animation
          _buildLockIcon(),
          SizedBox(height: AppDimensions.spaceL),
          
          // Title
          Text(
            l10n.parentalAccessRequired,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceS),
          
          // Subtitle
          Text(
            l10n.parentalAccessDescription,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceXL),
          
          // Input field
          _buildInputField(context),
          
          // Error message
          if (_showError) ...[
            SizedBox(height: AppDimensions.spaceS),
            FadeSlideWidget(
              duration: AppDurations.animationShort,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: AppDimensions.iconXS,
                  ),
                  SizedBox(width: AppDimensions.spaceXS),
                  Text(
                    l10n.invalidKeyTryAgain,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: AppDimensions.spaceL),
          
          // Unlock button
          _buildUnlockButton(context),
          
          SizedBox(height: AppDimensions.spaceM),
          
          // Forgot key link
          if (widget.onForgotKey != null)
            ScaleTapWidget(
              onTap: widget.onForgotKey,
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spaceS),
                child: Text(
                  l10n.forgotYourKey,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          SizedBox(height: AppDimensions.spaceM),
          
          // Info badge
          _buildInfoBadge(context),
        ],
      ),
    );
  }

  Widget _buildLockIcon() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spaceM),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8B5CF6),
              Color(0xFF7C3AED),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_rounded,
          color: AppColors.white,
          size: AppDimensions.iconXL,
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(
          color: _showError
              ? AppColors.error
              : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: _showError ? 2 : 1.5,
        ),
      ),
      child: TextField(
        controller: _keyController,
        focusNode: _focusNode,
        obscureText: _obscureKey,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: AppTextStyles.h4.copyWith(
          letterSpacing: 8,
        ),
        decoration: InputDecoration(
          hintText: '• • • •',
          hintStyle: AppTextStyles.h4.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            letterSpacing: 12,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM,
            vertical: AppDimensions.spaceM,
          ),
          prefixIcon: Icon(
            Icons.vpn_key_rounded,
            color: const Color(0xFF8B5CF6),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureKey ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _obscureKey = !_obscureKey);
            },
          ),
        ),
        onSubmitted: (_) => _verify(),
        onChanged: (_) {
          if (_showError) {
            setState(() => _showError = false);
          }
        },
      ),
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return SizedBox(
      width: double.infinity,
      child: ScaleTapWidget(
        onTap: _isLoading ? null : _verify,
        child: AnimatedContainer(
          duration: AppDurations.animationShort,
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isLoading
                  ? [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                      const Color(0xFF7C3AED).withValues(alpha: 0.3),
                    ]
                  : [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF7C3AED),
                    ],
            ),
            borderRadius: AppDimensions.borderRadiusM,
            boxShadow: _isLoading
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_open_rounded,
                        color: AppColors.white,
                        size: AppDimensions.iconS,
                      ),
                      SizedBox(width: AppDimensions.spaceS),
                      Text(
                        l10n.unlock,
                        style: AppTextStyles.button,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_rounded,
            color: AppColors.info,
            size: AppDimensions.iconXS,
          ),
          SizedBox(width: AppDimensions.spaceS),
          Flexible(
            child: Text(
              l10n.protectedForChildSafety,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
