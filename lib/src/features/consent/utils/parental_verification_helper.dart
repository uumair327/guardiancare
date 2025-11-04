import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

/// Helper class for managing parental verification flows with enhanced UX
class ParentalVerificationHelper {
  final ConsentController _consentController;

  ParentalVerificationHelper(this._consentController);

  /// Show parental verification with pre-check and enhanced error handling
  Future<bool> showVerificationDialog(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onSuccess,
    VoidCallback? onCancel,
    bool showPreCheckDialog = true,
  }) async {
    // Pre-check if user can attempt verification
    if (!_consentController.canCurrentUserAttemptVerification()) {
      if (showPreCheckDialog) {
        await _showLockoutInfoDialog(context);
      }
      return false;
    }

    // Show custom pre-verification dialog if provided
    if (title != null || message != null) {
      final shouldProceed = await _showPreVerificationDialog(
        context,
        title: title,
        message: message,
      );
      if (!shouldProceed) {
        onCancel?.call();
        return false;
      }
    }

    // Show verification dialog
    bool verified = false;
    await _consentController.verifyParentalKeyWithError(
      context,
      onSuccess: () {
        verified = true;
        onSuccess?.call();
      },
      onError: () {
        verified = false;
        onCancel?.call();
      },
    );

    return verified;
  }

  /// Show verification with custom success/failure actions
  Future<ParentalVerificationResult> verifyWithResult(
    BuildContext context,
    String enteredKey, {
    String? context_,
  }) async {
    return await _consentController.verifyParentalKeyWithLogging(
      enteredKey,
      context: context_,
    );
  }

  /// Check if verification is currently possible
  bool canAttemptVerification() {
    return _consentController.canCurrentUserAttemptVerification();
  }

  /// Get current security status
  LockoutStatus? getCurrentStatus() {
    return _consentController.getCurrentUserLockoutStatus();
  }

  /// Show lockout information dialog
  Future<void> _showLockoutInfoDialog(BuildContext context) async {
    final status = _consentController.getCurrentUserLockoutStatus();
    if (status == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              status.isLockedOut ? Icons.lock : Icons.warning_amber,
              color: status.isLockedOut ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(
              status.isLockedOut ? 'Access Locked' : 'Security Warning',
              style: TextStyle(
                color: status.isLockedOut ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status.message),
            if (status.isLockedOut && status.remainingTime != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Time remaining: ${_formatDuration(status.remainingTime!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
  }

  /// Show pre-verification dialog with custom message
  Future<bool> _showPreVerificationDialog(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: message != null ? Text(message) : null,
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
    return result ?? false;
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Show verification with custom UI
  Future<bool> showCustomVerificationFlow(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onSuccess,
    VoidCallback? onFailure,
    Widget? customIcon,
  }) async {
    // Check if verification is possible
    if (!canAttemptVerification()) {
      await _showLockoutInfoDialog(context);
      onFailure?.call();
      return false;
    }

    // Show custom verification dialog
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CustomVerificationDialog(
        title: title,
        description: description,
        customIcon: customIcon,
        consentController: _consentController,
        onSuccess: () {
          Navigator.of(context).pop(true);
          onSuccess();
        },
        onFailure: () {
          Navigator.of(context).pop(false);
          onFailure?.call();
        },
      ),
    ) ?? false;
  }
}

/// Custom verification dialog with enhanced UI
class _CustomVerificationDialog extends StatefulWidget {
  final String title;
  final String description;
  final Widget? customIcon;
  final ConsentController consentController;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const _CustomVerificationDialog({
    required this.title,
    required this.description,
    this.customIcon,
    required this.consentController,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<_CustomVerificationDialog> createState() => _CustomVerificationDialogState();
}

class _CustomVerificationDialogState extends State<_CustomVerificationDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          widget.customIcon ?? const Icon(Icons.security, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enabled: !_isVerifying,
            decoration: InputDecoration(
              labelText: 'Parental Key',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
              suffixIcon: _isVerifying
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            onSubmitted: _isVerifying ? null : (_) => _handleVerification(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : widget.onFailure,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _handleVerification,
          child: const Text('Verify'),
        ),
      ],
    );
  }

  void _handleVerification() async {
    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your parental key';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.consentController.verifyParentalKeySecure(
        _passwordController.text,
      );

      if (result.success) {
        widget.onSuccess();
      } else {
        setState(() {
          _errorMessage = result.errorMessage;
          _isVerifying = false;
        });
        
        if (result.isLockedOut) {
          // Close dialog and show lockout info
          widget.onFailure();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
        _isVerifying = false;
      });
    }
  }
}