import 'package:flutter/material.dart';

class PasswordDialog extends StatelessWidget {
  final Function(String) onSubmit;
  final VoidCallback onCancel;

  const PasswordDialog({
    Key? key,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    return AlertDialog(
      title: const Text("Enter Password"),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: "Password",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onSubmit(passwordController.text);
          },
          child: const Text("Unlock"),
        ),
        TextButton(
          onPressed: onCancel,
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
