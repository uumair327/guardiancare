import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'dart:ui';

class PasswordDialog extends StatelessWidget {
  final Function(String) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onForgotPassword; // Added callback for Forgot Password

  const PasswordDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    required this.onForgotPassword, // Added required parameter
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tCardBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Enter Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: tPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Parental Key",
                        labelStyle:
                            TextStyle(color: tPrimaryColor, fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0, // Reduce padding further
                        ),
                        isDense: true, // Makes the field more compact
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align to the right
                      children: [
                        GestureDetector(
                          onTap: onForgotPassword, // Trigger forgot password
                          child: const Text(
                            "forgot parental key",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color.fromARGB(255, 0, 105, 190),
                              decoration: TextDecoration.underline,
                              decorationColor: Color.fromARGB(255, 0, 105, 190),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {
                            onSubmit(passwordController.text);
                          },
                          child: const Text(
                            "Unlock",
                            style: TextStyle(color: tPrimaryColor),
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
            ),
          ),
        ],
      ),
    );
  }
}
