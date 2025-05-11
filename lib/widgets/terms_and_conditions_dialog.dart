import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terms and Conditions'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. We collect and process your personal data in accordance with our Privacy Policy.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '2. You are responsible for maintaining the confidentiality of your account.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '3. We may update these terms from time to time.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}
