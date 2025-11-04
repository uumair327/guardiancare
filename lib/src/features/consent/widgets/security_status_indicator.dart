import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

/// Widget that displays the current security status for parental controls
class SecurityStatusIndicator extends StatelessWidget {
  final LockoutStatus status;
  final bool showDetails;
  final VoidCallback? onTap;

  const SecurityStatusIndicator({
    Key? key,
    required this.status,
    this.showDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getBorderColor()),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            if (showDetails) ...[
              const SizedBox(width: 8),
              Expanded(child: _buildStatusText()),
            ],
            if (status.isLockedOut && status.remainingTime != null)
              _buildCountdownBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor;

    switch (status.state) {
      case LockoutState.normal:
        iconData = Icons.security;
        iconColor = Colors.green;
        break;
      case LockoutState.warning:
        iconData = Icons.warning_amber;
        iconColor = Colors.orange;
        break;
      case LockoutState.lockedOut:
        iconData = Icons.lock;
        iconColor = Colors.red;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 20,
    );
  }

  Widget _buildStatusText() {
    String title;
    String? subtitle;
    Color textColor;

    switch (status.state) {
      case LockoutState.normal:
        title = "Security Active";
        subtitle = "Parental controls are enabled";
        textColor = Colors.green[700]!;
        break;
      case LockoutState.warning:
        title = "Warning";
        subtitle = "${status.attemptsRemaining} attempt${status.attemptsRemaining == 1 ? '' : 's'} remaining";
        textColor = Colors.orange[700]!;
        break;
      case LockoutState.lockedOut:
        title = "Locked Out";
        subtitle = "Too many failed attempts";
        textColor = Colors.red[700]!;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildCountdownBadge() {
    final remaining = status.remainingTime!;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${minutes}:${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status.state) {
      case LockoutState.normal:
        return Colors.green.withOpacity(0.1);
      case LockoutState.warning:
        return Colors.orange.withOpacity(0.1);
      case LockoutState.lockedOut:
        return Colors.red.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (status.state) {
      case LockoutState.normal:
        return Colors.green.withOpacity(0.3);
      case LockoutState.warning:
        return Colors.orange.withOpacity(0.3);
      case LockoutState.lockedOut:
        return Colors.red.withOpacity(0.3);
    }
  }
}

/// Animated security status indicator that updates in real-time
class AnimatedSecurityStatusIndicator extends StatefulWidget {
  final LockoutStatus initialStatus;
  final Stream<LockoutStatus>? statusStream;
  final bool showDetails;
  final VoidCallback? onTap;

  const AnimatedSecurityStatusIndicator({
    Key? key,
    required this.initialStatus,
    this.statusStream,
    this.showDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedSecurityStatusIndicator> createState() => _AnimatedSecurityStatusIndicatorState();
}

class _AnimatedSecurityStatusIndicatorState extends State<AnimatedSecurityStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late LockoutStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    widget.statusStream?.listen((status) {
      if (mounted && status.state != _currentStatus.state) {
        setState(() {
          _currentStatus = status;
        });
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SecurityStatusIndicator(
            status: _currentStatus,
            showDetails: widget.showDetails,
            onTap: widget.onTap,
          ),
        );
      },
    );
  }
}