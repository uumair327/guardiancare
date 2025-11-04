import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';
import 'package:guardiancare/src/features/consent/widgets/security_status_indicator.dart';

/// Helper class for parental verification operations
class ParentalVerificationHelper {
  static final ConsentController _consentController = ConsentController();

  /// Show parental verification dialog with enhanced security features
  static Future<bool> showVerificationDialog(
    BuildContext context, {
    String? title,
    String? message,
    bool showSecurityStatus = true,
  }) async {
    // Get current attempt status
    final attemptStatus = await _consentController.getCurrentUserAttemptStatus();
    if (attemptStatus == null) {
      _showErrorSnackBar(context, 'Unable to verify user authentication status');
      return false;
    }

    // Show pre-verification security status if requested
    if (showSecurityStatus) {
      final shouldProceed = await _showSecurityStatusDialog(context, attemptStatus);
      if (!shouldProceed) return false;
    }

    // Show verification dialog
    bool verificationResult = false;
    
    await _consentController.verifyParentalKeyWithError(
      context,
      onSuccess: () {
        verificationResult = true;
      },
      onError: () {
        verificationResult = false;
      },
    );

    return verificationResult;
  }

  /// Show security status dialog before verification
  static Future<bool> _showSecurityStatusDialog(
    BuildContext context,
    AttemptStatus attemptStatus,
  ) async {
    if (attemptStatus.isLockedOut) {
      // Show lockout information
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Account Locked'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'You cannot attempt verification while your account is locked. Please wait for the lockout to expire or reset your password.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    if (attemptStatus.failedAttempts > 0) {
      // Show warning for previous failed attempts
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Security Warning'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SecurityStatusIndicator(
                attemptStatus: attemptStatus,
                showDetails: true,
              ),
              const SizedBox(height: 16),
              const Text(
                'Previous verification attempts have failed. Be careful with your parental key to avoid account lockout.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      return shouldProceed ?? false;
    }

    return true; // No issues, proceed with verification
  }

  /// Quick verification without showing security status
  static Future<bool> quickVerification(BuildContext context) async {
    return await showVerificationDialog(
      context,
      showSecurityStatus: false,
    );
  }

  /// Verification with custom message
  static Future<bool> verifyWithMessage(
    BuildContext context,
    String message,
  ) async {
    bool verificationResult = false;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Parental Verification Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              verificationResult = await showVerificationDialog(context);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    return verificationResult;
  }

  /// Check if verification is currently possible
  static Future<bool> canVerify() async {
    final attemptStatus = await _consentController.getCurrentUserAttemptStatus();
    return attemptStatus?.canAttempt ?? false;
  }

  /// Get current security status
  static Future<AttemptStatus?> getSecurityStatus() async {
    return await _consentController.getCurrentUserAttemptStatus();
  }

  /// Show security dashboard
  static void showSecurityDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ParentalSecurityDashboardScreen(),
      ),
    );
  }

  /// Reset attempts (admin function)
  static Future<void> resetAttempts() async {
    await _consentController.resetCurrentUserAttempts();
  }

  /// Show error snack bar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success snack bar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Verify and execute action
  static Future<void> verifyAndExecute(
    BuildContext context,
    VoidCallback action, {
    String? verificationMessage,
  }) async {
    final verified = verificationMessage != null
        ? await verifyWithMessage(context, verificationMessage)
        : await showVerificationDialog(context);

    if (verified) {
      action();
    }
  }

  /// Batch verification for multiple actions
  static Future<bool> batchVerification(
    BuildContext context,
    List<String> actionDescriptions,
  ) async {
    final message = 'You are about to perform the following actions:\n\n'
        '${actionDescriptions.map((desc) => '• $desc').join('\n')}\n\n'
        'Please verify your parental key to continue.';

    return await verifyWithMessage(context, message);
  }
}

/// Full-screen security dashboard
class ParentalSecurityDashboardScreen extends StatefulWidget {
  const ParentalSecurityDashboardScreen({Key? key}) : super(key: key);

  @override
  _ParentalSecurityDashboardScreenState createState() => _ParentalSecurityDashboardScreenState();
}

class _ParentalSecurityDashboardScreenState extends State<ParentalSecurityDashboardScreen> {
  final ConsentController _consentController = ConsentController();
  AttemptStatus? _attemptStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _consentController.getCurrentUserAttemptStatus();
      setState(() {
        _attemptStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading security status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parental Control Security'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attemptStatus == null
              ? const Center(child: Text('Unable to load security status'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Security Dashboard
                      // ParentalControlDashboard(
                      //   attemptStatus: _attemptStatus!,
                      //   onResetAttempts: _handleResetAttempts,
                      //   onChangePassword: _handleChangePassword,
                      //   onViewSecurityLog: _handleViewSecurityLog,
                      // ),
                      
                      // Additional security information
                      _buildSecurityTips(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSecurityTips() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTip(
              'Use a strong, memorable parental key that only you know.',
              Icons.key,
            ),
            _buildTip(
              'Never share your parental key with children or unauthorized users.',
              Icons.visibility_off,
            ),
            _buildTip(
              'Change your parental key regularly for better security.',
              Icons.refresh,
            ),
            _buildTip(
              'Remember your security question answer for password recovery.',
              Icons.help_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handleResetAttempts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Failed Attempts'),
        content: const Text(
          'Are you sure you want to reset the failed attempt counter? This will clear the security warning.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _consentController.resetCurrentUserAttempts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed attempts have been reset'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSecurityStatus(); // Refresh the status
    }
  }

  void _handleChangePassword() {
    // This would typically navigate to a password change screen
    // or show the reset dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password change feature coming soon')),
    );
  }

  void _handleViewSecurityLog() {
    // This would typically show a security log screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security log feature coming soon')),
    );
  }
}