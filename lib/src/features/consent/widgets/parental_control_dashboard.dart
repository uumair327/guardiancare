import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';
import 'package:guardiancare/src/features/consent/widgets/security_status_indicator.dart';

/// Dashboard widget for parental control security management
class ParentalControlDashboard extends StatefulWidget {
  final AttemptStatus attemptStatus;
  final VoidCallback? onResetAttempts;
  final VoidCallback? onChangePassword;
  final VoidCallback? onViewSecurityLog;

  const ParentalControlDashboard({
    Key? key,
    required this.attemptStatus,
    this.onResetAttempts,
    this.onChangePassword,
    this.onViewSecurityLog,
  }) : super(key: key);

  @override
  _ParentalControlDashboardState createState() => _ParentalControlDashboardState();
}

class _ParentalControlDashboardState extends State<ParentalControlDashboard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: tPrimaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Parental Control Security',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      // Trigger rebuild to refresh status
                    });
                  },
                  tooltip: 'Refresh Status',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Security Status Indicator
            SecurityStatusIndicator(
              attemptStatus: widget.attemptStatus,
              showDetails: true,
            ),
            const SizedBox(height: 20),

            // Security Statistics
            _buildSecurityStatistics(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildStatRow(
                'Failed Attempts',
                '${widget.attemptStatus.failedAttempts}',
                Icons.error_outline,
                widget.attemptStatus.failedAttempts > 0 ? Colors.red : Colors.grey,
              ),
              const Divider(height: 16),
              _buildStatRow(
                'Remaining Attempts',
                '${widget.attemptStatus.remainingAttempts}',
                Icons.security,
                widget.attemptStatus.remainingAttempts > 1 ? Colors.green : Colors.orange,
              ),
              const Divider(height: 16),
              _buildStatRow(
                'Max Attempts Allowed',
                '${widget.attemptStatus.maxAttempts}',
                Icons.policy,
                Colors.blue,
              ),
              const Divider(height: 16),
              _buildStatRow(
                'Lockout Duration',
                '${widget.attemptStatus.lockoutDurationMinutes} minutes',
                Icons.timer,
                Colors.purple,
              ),
              if (widget.attemptStatus.lastAttemptTime != null) ...[
                const Divider(height: 16),
                _buildStatRow(
                  'Last Attempt',
                  _formatLastAttemptTime(widget.attemptStatus.lastAttemptTime!),
                  Icons.access_time,
                  Colors.grey,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: tTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: tTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Change Password Button
            _buildActionButton(
              label: 'Change Password',
              icon: Icons.key,
              color: tPrimaryColor,
              onPressed: widget.onChangePassword,
              enabled: true,
            ),
            
            // Reset Attempts Button (only show if there are failed attempts)
            if (widget.attemptStatus.failedAttempts > 0 && widget.onResetAttempts != null)
              _buildActionButton(
                label: 'Reset Attempts',
                icon: Icons.refresh,
                color: Colors.orange,
                onPressed: widget.onResetAttempts,
                enabled: true,
              ),
            
            // View Security Log Button
            if (widget.onViewSecurityLog != null)
              _buildActionButton(
                label: 'Security Log',
                icon: Icons.history,
                color: Colors.blue,
                onPressed: widget.onViewSecurityLog,
                enabled: true,
              ),
          ],
        ),
        
        // Emergency Actions (if locked out)
        if (widget.attemptStatus.isLockedOut) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Options',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account is locked. You can either wait for the lockout to expire or reset your password using the security question.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: widget.onChangePassword,
                  icon: const Icon(Icons.lock_reset, size: 16),
                  label: const Text('Reset Password Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required bool enabled,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  String _formatLastAttemptTime(DateTime lastAttempt) {
    final now = DateTime.now();
    final difference = now.difference(lastAttempt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Simplified version of the dashboard for embedding in other screens
class CompactParentalControlDashboard extends StatelessWidget {
  final AttemptStatus attemptStatus;
  final VoidCallback? onTap;

  const CompactParentalControlDashboard({
    Key? key,
    required this.attemptStatus,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.security,
                  color: tPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Parental Control Security',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right,
                    color: tPrimaryColor,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            CompactSecurityStatusIndicator(
              attemptStatus: attemptStatus,
            ),
          ],
        ),
      ),
    );
  }
}