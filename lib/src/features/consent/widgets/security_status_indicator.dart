import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

/// Widget that displays the current security status for parental controls
class SecurityStatusIndicator extends StatelessWidget {
  final AttemptStatus attemptStatus;
  final bool showDetails;
  final VoidCallback? onTap;

  const SecurityStatusIndicator({
    Key? key,
    required this.attemptStatus,
    this.showDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusTitle(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: _getStatusColor(),
                  ),
              ],
            ),
            if (showDetails) ...[
              const SizedBox(height: 8),
              Text(
                _getStatusDescription(),
                style: TextStyle(
                  fontSize: 14,
                  color: _getStatusColor().withOpacity(0.8),
                ),
              ),
              if (attemptStatus.isLockedOut) ...[
                const SizedBox(height: 12),
                _buildLockoutDetails(),
              ] else if (attemptStatus.failedAttempts > 0) ...[
                const SizedBox(height: 12),
                _buildWarningDetails(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLockoutDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(
                'Time remaining: ${attemptStatus.remainingLockoutTimeFormatted}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Failed attempts: ${attemptStatus.failedAttempts}/${attemptStatus.maxAttempts}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your account has been temporarily locked for security. You can use "Forgot Password" to reset your parental key.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                '${attemptStatus.remainingAttempts} attempt${attemptStatus.remainingAttempts == 1 ? '' : 's'} remaining',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Previous attempts: ${attemptStatus.failedAttempts}/${attemptStatus.maxAttempts}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be careful! Your account will be locked for ${attemptStatus.lockoutDurationMinutes} minutes after ${attemptStatus.maxAttempts} failed attempts.',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (attemptStatus.isLockedOut) {
      return Colors.red;
    } else if (attemptStatus.failedAttempts > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    if (attemptStatus.isLockedOut) {
      return Icons.block;
    } else if (attemptStatus.failedAttempts > 0) {
      return Icons.warning;
    } else {
      return Icons.security;
    }
  }

  String _getStatusTitle() {
    if (attemptStatus.isLockedOut) {
      return 'Account Locked';
    } else if (attemptStatus.failedAttempts > 0) {
      return 'Security Warning';
    } else {
      return 'Security Status: Good';
    }
  }

  String _getStatusDescription() {
    if (attemptStatus.isLockedOut) {
      return 'Your account is temporarily locked due to multiple failed verification attempts.';
    } else if (attemptStatus.failedAttempts > 0) {
      return 'Recent failed verification attempts detected. Please be careful with your parental key.';
    } else {
      return 'Your parental controls are secure and ready for verification.';
    }
  }
}

/// Compact version of the security status indicator
class CompactSecurityStatusIndicator extends StatelessWidget {
  final AttemptStatus attemptStatus;
  final VoidCallback? onTap;

  const CompactSecurityStatusIndicator({
    Key? key,
    required this.attemptStatus,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: _getStatusColor(),
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (attemptStatus.isLockedOut) {
      return Colors.red;
    } else if (attemptStatus.failedAttempts > 0) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon() {
    if (attemptStatus.isLockedOut) {
      return Icons.block;
    } else if (attemptStatus.failedAttempts > 0) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  String _getStatusText() {
    if (attemptStatus.isLockedOut) {
      return 'Locked (${attemptStatus.remainingLockoutTimeFormatted})';
    } else if (attemptStatus.failedAttempts > 0) {
      return '${attemptStatus.remainingAttempts} attempts left';
    } else {
      return 'Secure';
    }
  }
}