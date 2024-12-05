// consent_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConsentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> verifyParentalKey(
    BuildContext context, {
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    try {
      final String? parentKey = await _getParentKeyFromUserInput(context);
      if (parentKey == null || parentKey.isEmpty) {
        onError();
        return;
      }

      final hashedParentKey = await _hashParentalKey(parentKey);

      // Verify the parent key in Firestore
      DocumentSnapshot consentDoc = await _firestore
          .collection('parental_keys')
          .doc(hashedParentKey)
          .get();

      if (consentDoc.exists) {
        // Success
        onSuccess();
      } else {
        // Error: key not found
        onError();
      }
    } catch (e) {
      print("Error verifying parental key: $e");
      onError();
    }
  }

  Future<String?> _getParentKeyFromUserInput(BuildContext context) async {
    // Your logic for collecting parental key input, possibly using a dialog or text field
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController keyController = TextEditingController();
        return AlertDialog(
          title: const Text("Enter Parental Key"),
          content: TextField(
            controller: keyController,
            decoration: const InputDecoration(hintText: 'Parental Key'),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, keyController.text);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<String> _hashParentalKey(String parentKey) async {
    // Implement your hashing logic here (e.g., SHA256 or other secure hashing method)
    return parentKey; // Example: return the parentKey directly (implement actual hashing)
  }
}
