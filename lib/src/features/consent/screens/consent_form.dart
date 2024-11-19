import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';

class ConsentForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final TextEditingController controller;
  final ConsentController consentController;

  const ConsentForm({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.consentController,
  });

  @override
  _ConsentFormState createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentEmailController = TextEditingController();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController parentalKeyController = TextEditingController();
  final TextEditingController confirmParentalKeyController =
      TextEditingController();
  final TextEditingController securityQuestionController =
      TextEditingController();

  bool isChildAbove12 = false;
  bool isParentConsentGiven = false;
  String? errorMessage;

  final String securityQuestion = "What is your favorite color ?";

  /// Validation for Parental Key
  String? _validateParentalKey(String? key) {
    if (key == null || key.isEmpty) {
      return 'Parental Key is required';
    }
    if (key.length < 8) {
      return 'Key must be at least 8 characters long';
    }

    final hasUppercase = key.contains(RegExp(r'[A-Z]'));
    final hasLowercase = key.contains(RegExp(r'[a-z]'));
    final hasDigits = key.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters =
        key.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:]'));

    if (!(hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters)) {
      return 'Include Uppercase, Lowercase, Numbers, and Special Characters.';
    }

    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if parental key and confirm parental key match
      if (parentalKeyController.text != confirmParentalKeyController.text) {
        setState(() {
          errorMessage = 'Parental Key and Confirm Parental Key do not match.';
        });
        return;
      }

      // Ensure consents are provided
      if (!isChildAbove12 || !isParentConsentGiven) {
        setState(() {
          errorMessage = 'Please provide all required consents.';
        });
        return;
      }

      // Save form data (send to backend or database)
      try {
        // Submit form to the backend
        bool result = await widget.consentController.submitConsentForm(
          parentName: parentNameController.text,
          parentEmail: parentEmailController.text,
          childName: childNameController.text,
          parentalKey: parentalKeyController.text,
          securityQuestion: securityQuestion,
          securityAnswer: securityQuestionController.text,
          isChildAbove12: isChildAbove12,
          isParentConsentGiven: isParentConsentGiven,
        );

        if (result) {
          // Clear error message on successful submission
          setState(() {
            errorMessage = null;
          });
          // Proceed to the next step (e.g., OTP screen)
          widget.onSubmit();
        } else {
          setState(() {
            errorMessage =
                'There was an error saving the consent. Please try again.';
          });
        }
        // Proceed to the next step (e.g., OTP screen)
        widget.onSubmit();
      } catch (e) {
        setState(() {
          errorMessage = 'Error saving consent: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(40.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Head text
                  const Text(
                    'Parental Consent Form',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: tPrimaryColor),
                  ),

                  // Parent's Name
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: parentNameController,
                    decoration: const InputDecoration(
                      labelText: "Parent's Name",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0), // Reduce padding further
                      isDense: true,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter parent\'s name'
                        : null,
                  ),

                  // Parent's Email
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: parentEmailController,
                    decoration: const InputDecoration(
                      labelText: "Parent's Email",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0), // Reduce padding further
                      isDense: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value == null || !EmailValidator.validate(value)
                            ? 'Please enter a valid email address'
                            : null,
                  ),

                  // Child's Name
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: childNameController,
                    decoration: const InputDecoration(
                      labelText: "Child's Name",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0), // Reduce padding further
                      isDense: true,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter child\'s name'
                        : null,
                  ),

                  // Create Parental Key
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: parentalKeyController,
                    decoration: const InputDecoration(
                      labelText: "Create Parental Key",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0), // Reduce padding further
                      isDense: true,
                    ),
                    obscureText: true,
                    validator: _validateParentalKey,
                  ),

                  // Confirm Parental Key
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmParentalKeyController,
                    decoration: const InputDecoration(
                      labelText: "Confirm Parental Key",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 0.0), // Reduce padding further
                      isDense: true,
                    ),
                    obscureText: true,
                    validator: (value) => value != parentalKeyController.text
                        ? 'Parental Key does not match'
                        : null,
                  ),

                  // Security Question
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: securityQuestionController,
                    decoration: InputDecoration(
                      label: Text(
                        "Security Question: $securityQuestion",
                        style:
                            const TextStyle(color: tPrimaryColor, fontSize: 14),
                      ),
                      labelStyle:
                          const TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0, // Reduce padding further
                      ),
                      isDense: true, // Makes the field more compact
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a security question'
                        : null,
                  ),

                  // Age Consent
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text(
                      'I confirm that my child is 12 years or older and has my permission to use this app.',
                      style: TextStyle(
                        fontSize: 14,
                        color: tPrimaryColor,
                      ),
                    ),
                    value: isChildAbove12,
                    onChanged: (value) => setState(() {
                      isChildAbove12 = value ?? false;
                    }),
                    activeColor: tPrimaryColor, // Set the checkbox color
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 1.0), // Reduce horizontal margin
                  ),

                  // parent verification consent
                  CheckboxListTile(
                    title: const Text(
                        'I allow my child to use the app and will manage access using the key provided.',
                        style: TextStyle(
                          fontSize: 14,
                          color: tPrimaryColor,
                        )),
                    value: isParentConsentGiven,
                    onChanged: (value) => setState(() {
                      isParentConsentGiven = value ?? false;
                    }),
                    activeColor: tPrimaryColor, // Set the checkbox color
                    contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  ),

                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit Consent',
                        style: TextStyle(
                          color: tPrimaryColor,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
