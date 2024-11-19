import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';

class ReminderDialog extends StatelessWidget {
  final VoidCallback onAgree;

  const ReminderDialog({super.key, required this.onAgree});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stay Safe Online'),
      content: const Text(
        'Please remember to be safe online and be aware of the real-world risks of online interactions before exchanging any media or information.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onAgree();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: tPrimaryColor,
          ),
          child: const Text('I Understand'),
        ),
      ],
    );
  }
}
