import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/core/services/parental_verification_service.dart';
import 'package:guardiancare/features/consent/presentation/widgets/forgot_parental_key_dialog.dart';

class ParentalVerificationDialog extends StatefulWidget {
  final String featureName;
  final VoidCallback onVerified;

  const ParentalVerificationDialog({
    Key? key,
    required this.featureName,
    required this.onVerified,
  }) : super(key: key);

  @override
  State<ParentalVerificationDialog> createState() => _ParentalVerificationDialogState();
}

class _ParentalVerificationDialogState extends State<ParentalVerificationDialog> {
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
        const SnackBar(
          content: Text('Key must be at least 4 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isValid = await _verificationService.verifyParentalKey(_keyController.text);

    setState(() {
      _isLoading = false;
    });

    if (isValid) {
      Navigator.of(context).pop();
      widget.onVerified();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access granted to ${widget.featureName}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid parental key'),
          backgroundColor: Colors.red,
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
        children: const [
          Icon(Icons.lock, color: tPrimaryColor),
          SizedBox(width: 12),
          Expanded(child: Text('Parental Verification')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your parental key to access ${widget.featureName}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keyController,
            decoration: InputDecoration(
              labelText: 'Parental Key',
              hintText: 'Enter your key',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.vpn_key, color: tPrimaryColor),
              suffixIcon: IconButton(
                icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
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
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const ForgotParentalKeyDialog(),
                );
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can now use your new parental key'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Forgot Key?',
                style: TextStyle(color: tPrimaryColor),
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
            backgroundColor: tPrimaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
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
  VoidCallback onVerified,
) async {
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
    ),
  );
}
