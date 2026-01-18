import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';

/// Modern emergency contact card with gradient design and animations
/// Features scale tap animations, haptic feedback, and staggered contact list
class EmergencyContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<EmergencyContactEntity> contacts;
  final List<Color> gradientColors;
  final void Function(String number) onCall;

  const EmergencyContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.contacts,
    required this.onCall,
    this.gradientColors = const [AppColors.videoPrimary, AppColors.videoPrimaryDark],
  });

  @override
  State<EmergencyContactCard> createState() => _EmergencyContactCardState();
}

class _EmergencyContactCardState extends State<EmergencyContactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.contacts.length * 100)),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.videoSurface,
          borderRadius: AppDimensions.borderRadiusL,
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors.first.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContactList(),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.gradientColors.first.withValues(alpha: 0.2),
            widget.gradientColors.last.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.gradientColors,
              ),
              borderRadius: AppDimensions.borderRadiusM,
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              color: AppColors.white,
              size: 24,
            ),
          ),
          SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXS),
                Text(
                  '${widget.contacts.length} contacts available',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      child: Column(
        children: List.generate(
          widget.contacts.length,
          (index) => _buildAnimatedContactItem(index, widget.contacts[index]),
        ),
      ),
    );
  }

  Widget _buildAnimatedContactItem(int index, EmergencyContactEntity contact) {
    final delay = index * 0.15;
    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(delay, delay + 0.5, curve: AppCurves.emphasizedDecelerate),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: _ContactItem(
        contact: contact,
        gradientColors: widget.gradientColors,
        onCall: widget.onCall,
      ),
    );
  }
}

/// Individual contact item with call button
class _ContactItem extends StatelessWidget {
  final EmergencyContactEntity contact;
  final List<Color> gradientColors;
  final void Function(String number) onCall;

  const _ContactItem({
    required this.contact,
    required this.gradientColors,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: ScaleTapWidget(
        onTap: () => onCall(contact.number),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.05),
            borderRadius: AppDimensions.borderRadiusM,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXS),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          color: gradientColors.first,
                          size: 14,
                        ),
                        SizedBox(width: AppDimensions.spaceXS),
                        Text(
                          contact.number,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    if (contact.description != null) ...[
                      SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        contact.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Call button
              _CallButton(
                gradientColors: gradientColors,
                onTap: () => onCall(contact.number),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated call button with pulse effect
class _CallButton extends StatefulWidget {
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _CallButton({
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<_CallButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.emergencyGreen, AppColors.emergencyGreenDark],
            ),
            borderRadius: AppDimensions.borderRadiusM,
            boxShadow: [
              BoxShadow(
                color: AppColors.emergencyGreen.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.phone_rounded,
            color: AppColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
