import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

class ParentalVerificationDialog extends StatefulWidget {
  final String featureName;
  final VoidCallback onVerified;
  final VoidCallback? onForgotKey;

  const ParentalVerificationDialog({
    Key? key,
    required this.featureName,
    required this.onVerified,
    this.onForgotKey,
  }) : super(key: key);

  @override
  State<ParentalVerificationDialog> createState() =>
      _ParentalVerificationDialogState();
}

class _ParentalVerificationDialogState
    extends State<ParentalVerificationDialog> {
  final TextEditingController _keyController = TextEditingController();
  final _verificationService = ParentalVerificationService();
  bool _obscureKey = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_keyController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Key must be at least 4 characters'),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isValid =
        await _verificationService.verifyParentalKey(_keyController.text);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop();
      widget.onVerified();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access granted to ${widget.featureName}'),
          backgroundColor: context.colors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid parental key'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.lock, color: context.colors.primary),
          SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child:
                Text('Parental Verification', style: AppTextStyles.dialogTitle),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your parental key to access ${widget.featureName}',
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            decoration: InputDecoration(
              labelText: 'Parental Key',
              hintText: 'Enter your key',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.vpn_key, color: context.colors.primary),
              suffixIcon: IconButton(
                icon:
                    Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureKey = !_obscureKey;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.text,
            obscureText: _obscureKey,
            onSubmitted: (_) => _verify(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                if (widget.onForgotKey != null) {
                  Navigator.of(context).pop();
                  widget.onForgotKey!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forgot key feature not available'),
                      backgroundColor: AppColors.gray500,
                    ),
                  );
                }
              },
              child: Text(
                'Forgot Key?',
                style: AppTextStyles.link,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verify,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}

/// Helper function to show parental verification dialog
Future<void> showParentalVerification(
  BuildContext context,
  String featureName,
  VoidCallback onVerified, {
  VoidCallback? onForgotKey,
}) async {
  final verificationService = ParentalVerificationService();

  // Check if already verified in this session
  if (verificationService.isVerifiedForSession) {
    onVerified();
    return;
  }

  // Show verification dialog
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ParentalVerificationDialog(
      featureName: featureName,
      onVerified: onVerified,
      onForgotKey: onForgotKey,
    ),
  );
}
