import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';

class ConsentForm extends StatelessWidget {
  final ConsentController consentController;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  ConsentForm({
    required this.consentController,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Consent Form'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Enter Parent Key',
        ),
        obscureText: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            onSubmit();
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
