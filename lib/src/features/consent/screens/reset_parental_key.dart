import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';

class ResetPasswordDialog extends StatefulWidget {
  final Function(String, String) onSubmit; // Security answer, new password
  final VoidCallback onCancel;

  final String securityQuestion = "What is your favorite color?";

  const ResetPasswordDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  _ResetPasswordDialogState createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _securityAnswerController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _securityAnswerController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String? validateInput(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parental key is required.';
    }
    if (value.length < 6) {
      return 'Parental key must be at least 6 characters.';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _securityAnswerController.text,
        _newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
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
                controller: _securityAnswerController,
                decoration: InputDecoration(
                  label: Text(
                    "Security Question: ${widget.securityQuestion}",
                    style: const TextStyle(color: tPrimaryColor, fontSize: 14),
                  ),
                ),
                validator: (value) => validateInput(value, 'Security answer'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: "New Parental Key",
                  labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text("Submit"),
                  ),
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
