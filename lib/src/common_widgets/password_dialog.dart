import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'dart:ui';

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

    return Dialog(
      backgroundColor:
          tTransparentBackground, // Transparent background for the dialog
      child: Stack(
        children: [
          // Blurred background effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color:
                    tTransparentBackground, // Make the background fully transparent
              ),
            ),
          ),
          // Centered dialog content (no outer container)
          Center(
            child: Material(
              color: tTransparentBackground, // Transparent material background
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: tTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Password",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            onSubmit(passwordController.text);
                          },
                          child: const Text(
                            "Unlock",
                            style: TextStyle(fontSize: 16, color: tPrimaryColor),
                          ),
                        ),
                        TextButton(
                          onPressed: onCancel,
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontSize: 16, color: tTextPrimary),
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
