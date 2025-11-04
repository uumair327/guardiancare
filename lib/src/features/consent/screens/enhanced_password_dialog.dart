import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';

class EnhancedPasswordDialog extends StatefulWidget {
  final AttemptStatus attemptStatus;
  final Function(String) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onForgotPassword;

  const EnhancedPasswordDialog({
    Key? key,
    required this.attemptStatus,
    required this.onSubmit,
    required this.onCancel,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  _EnhancedPasswordDialogState createState() => _EnhancedPasswordDialogState();
}

class _EnhancedPasswordDialogState extends State<EnhancedPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

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
          Icon(
            widget.attemptStatus.isLockedOut ? Icons.lock : Icons.security,
            color: widget.attemptStatus.isLockedOut ? Colors.red : tPrimaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.attemptStatus.isLockedOut ? 'Account Locked' : 'Parental Verification',
              style: TextStyle(
                color: widget.attemptStatus.isLockedOut ? Colors.red : tPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security status indicator
            _buildSecurityStatusIndicator(),
            const SizedBox(height: 16),
            
            // Main content based on lockout status
            if (widget.attemptStatus.isLockedOut)
              _buildLockedOutContent()
            else
              _buildPasswordInputContent(),
          ],
        ),
      ),
      actions: _buildActionButtons(),
    );
  }

  Widget _buildSecurityStatusIndicator() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (widget.attemptStatus.isLockedOut) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = 'Locked for ${widget.attemptStatus.remainingLockoutTimeFormatted}';
    } else if (widget.attemptStatus.failedAttempts > 0) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = '${widget.attemptStatus.remainingAttempts} attempt${widget.attemptStatus.remainingAttempts == 1 ? '' : 's'} remaining';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Ready for verification';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedOutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your account has been temporarily locked due to multiple failed verification attempts.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Time remaining: ${widget.attemptStatus.remainingLockoutTimeFormatted}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Failed attempts: ${widget.attemptStatus.failedAttempts}/${widget.attemptStatus.maxAttempts}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Please wait for the lockout period to expire, or use the "Forgot Password" option to reset your parental key.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPasswordInputContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Please enter your parental key to continue:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          enabled: !_isSubmitting && widget.attemptStatus.canAttempt,
          decoration: InputDecoration(
            labelText: 'Parental Key',
            hintText: 'Enter your parental key',
            prefixIcon: const Icon(Icons.key),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: tPrimaryColor, width: 2),
            ),
          ),
          onSubmitted: (_) => _handleSubmit(),
        ),
        if (widget.attemptStatus.failedAttempts > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Previous attempts failed. ${widget.attemptStatus.remainingAttempts} attempt${widget.attemptStatus.remainingAttempts == 1 ? '' : 's'} remaining.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    if (widget.attemptStatus.isLockedOut) {
      return [
        TextButton(
          onPressed: widget.onForgotPassword,
          child: const Text('Forgot Password?'),
        ),
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Close'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: widget.onForgotPassword,
        child: const Text('Forgot Password?'),
      ),
      TextButton(
        onPressed: _isSubmitting ? null : widget.onCancel,
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _isSubmitting || !widget.attemptStatus.canAttempt || _passwordController.text.isEmpty
            ? null
            : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: tPrimaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Verify'),
      ),
    ];
  }

  void _handleSubmit() {
    if (_passwordController.text.isEmpty || _isSubmitting || !widget.attemptStatus.canAttempt) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Call the submit callback
    widget.onSubmit(_passwordController.text);

    // Reset submitting state after a delay (the dialog will be closed by parent)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }
}