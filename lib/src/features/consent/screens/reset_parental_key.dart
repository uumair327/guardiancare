import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';

class ResetPasswordDialog extends StatelessWidget {
  final Function(String, String) onSubmit; // Question, answer, new password
  final VoidCallback onCancel;

  final String securityQuestion = "What is your favorite color ?";

  const ResetPasswordDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController securityAnswerController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Reset Password",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: tPrimaryColor),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: securityAnswerController,
              decoration: InputDecoration(
                label: Text(
                  "Security Question: $securityQuestion",
                  style: const TextStyle(color: tPrimaryColor, fontSize: 14),
                ),
                labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0.0, // Reduce padding further
                ),
                isDense: true, // Makes the field more compact
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a security answer'
                  : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: "New Parental Key",
                labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 0.0), // Reduce padding further
                isDense: true,
              ),
              obscureText: true,
              validator: validateParentalKey,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onSubmit(
                      securityAnswerController.text,
                      newPasswordController.text,
                    );
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      color: tPrimaryColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: tTextPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
