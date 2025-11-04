import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';
import 'package:guardiancare/src/features/consent/widgets/security_status_indicator.dart';

/// Comprehensive dashboard for parental control security status
class ParentalControlDashboard extends StatefulWidget {
  final ConsentController consentController;
  final bool showDetailedStats;
  final VoidCallback? onSecuritySettingsTap;

  const ParentalControlDashboard({
    Key? key,
    required this.consentController,
    this.showDetailedStats = true,
    this.onSecuritySettingsTap,
  }) : super(key: key);

  @override
  State<ParentalControlDashboard> createState() => _ParentalControlDashboardState();
}

class _ParentalControlDashboardState extends State<ParentalControlDashboard> {
  Timer? _refreshTimer;
  Map<String, dynamic>? _securityStats;

  @override
  void initState() {
    super.initState();
    _refreshSecurityStats();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshSecurityStats() {
    if (mounted) {
      setState(() {
        _securityStats = widget.consentController.getCurrentUserSecurityStats();
      });
    }
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshSecurityStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_securityStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = widget.consentController.getCurrentUserLockoutStatus();
    if (status == null) {
      return _buildUnauthenticatedView();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            SecurityStatusIndicator(
              status: status,
              showDetails: true,
              onTap: widget.onSecuritySettingsTap,
            ),
            if (widget.showDetailedStats) ...[
              const SizedBox(height: 16),
              _buildDetailedStats(status),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(status),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.security,
          color: tPrimaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Parental Control Security',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tPrimaryColor,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshSecurityStats,
          tooltip: 'Refresh Status',
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Authentication Required',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in to view parental control status',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(LockoutStatus status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Statistics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatRow('Failed Attempts', '${status.failedAttempts}'),
          if (status.attemptsRemaining != null)
            _buildStatRow('Attempts Remaining', '${status.attemptsRemaining}'),
          if (status.isLockedOut && status.remainingTime != null)
            _buildStatRow('Lockout Expires In', _formatDuration(status.remainingTime!)),
          _buildStatRow('Can Attempt Verification', 
            _securityStats!['canAttempt'] ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LockoutStatus status) {
    return Row(
      children: [
        if (status.isLockedOut)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: null, // Disabled during lockout
              icon: const Icon(Icons.timer),
              label: const Text('Locked Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
              ),
            ),
          )
        else
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _testParentalVerification(),
              icon: const Icon(Icons.verified_user),
              label: const Text('Test Verification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: tPrimaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: widget.onSecuritySettingsTap,
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  void _testParentalVerification() {
    widget.consentController.verifyParentalKey(
      context,
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parental verification successful!'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Compact version of the parental control dashboard
class CompactParentalControlStatus extends StatefulWidget {
  final ConsentController consentController;
  final VoidCallback? onTap;

  const CompactParentalControlStatus({
    Key? key,
    required this.consentController,
    this.onTap,
  }) : super(key: key);

  @override
  State<CompactParentalControlStatus> createState() => _CompactParentalControlStatusState();
}

class _CompactParentalControlStatusState extends State<CompactParentalControlStatus> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.consentController.getCurrentUserLockoutStatus();
    
    if (status == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 16,
              color: _getStatusColor(status),
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LockoutStatus status) {
    switch (status.state) {
      case LockoutState.normal:
        return Colors.green;
      case LockoutState.warning:
        return Colors.orange;
      case LockoutState.lockedOut:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(LockoutStatus status) {
    switch (status.state) {
      case LockoutState.normal:
        return Icons.security;
      case LockoutState.warning:
        return Icons.warning_amber;
      case LockoutState.lockedOut:
        return Icons.lock;
    }
  }

  String _getStatusText(LockoutStatus status) {
    switch (status.state) {
      case LockoutState.normal:
        return 'Secure';
      case LockoutState.warning:
        return '${status.attemptsRemaining} left';
      case LockoutState.lockedOut:
        if (status.remainingTime != null) {
          final minutes = status.remainingTime!.inMinutes;
          return 'Locked ${minutes}m';
        }
        return 'Locked';
    }
  }
}