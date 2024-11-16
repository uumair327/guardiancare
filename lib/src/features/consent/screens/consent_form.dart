import 'package:flutter/material.dart';
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
  // ignore: library_private_types_in_public_api
  _ConsentFormState createState() => _ConsentFormState();
}

class _ConsentFormState extends State<ConsentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentEmailController = TextEditingController();
  final TextEditingController childNameController = TextEditingController();
  bool isChildAbove12 = false;
  bool isParentConsentGiven = false;
  String? errorMessage;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!isChildAbove12 || !isParentConsentGiven) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide all consents.')),
        );
        return;
      }
      widget.consentController.generateOtpAndKeyPhrase();

      // Call the ConsentController to save data to Firestore
      try {
        bool result = await widget.consentController.submitConsentForm(
          parentName: parentNameController.text,
          parentEmail: parentEmailController.text,
          childName: childNameController.text,
          isChildAbove12: isChildAbove12,
          isParentConsentGiven: isParentConsentGiven,
        );
        // ignore: use_build_context_synchronously

        if (result) {
          // Proceed to next step (e.g., OTP screen)
          widget.onSubmit();
        } else {
          // Show error message if email sending fails
          setState(() {
            errorMessage = 'There was an issue sending the email. Please try again later.';
          });
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving consent: $e')),
        );
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
                  const Text(
                    'Parental Consent Form',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: tPrimaryColor
                    ),
                  ),

                  const SizedBox(height: 13),
                  TextFormField(
                    controller: parentNameController,
                    decoration: const InputDecoration(
                      labelText: "Parent's Name",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.0), // Reduce padding further
                      isDense: true, // Makes the field more compact
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter parent\'s name' : null,
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: parentEmailController,
                    decoration: const InputDecoration(
                      labelText: "Parent's Email",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.0), // Reduce padding further
                      isDense: true, // Makes the field more compact
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Please enter a valid email address'
                        : null,
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: childNameController,
                    decoration: const InputDecoration(
                      labelText: "Child's Name",
                      labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(vertical: 1.0), // Reduce padding further
                      isDense: true,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter child\'s name' : null,
                  ),

                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text(
                      'I confirm that my child is 12 years or older and has my permission to use this app.',
                      style: TextStyle(
                        fontSize: 13,
                        color: tPrimaryColor,
                      ),
                    ),
                    value: isChildAbove12,
                    onChanged: (value) => setState(() {
                      isChildAbove12 = value ?? false;
                    }),
                    activeColor: tPrimaryColor, // Set the checkbox color
                    contentPadding: const EdgeInsets.symmetric(horizontal: 1.0), // Reduce horizontal margin
                  ),

                  CheckboxListTile(
                    title: const Text(
                      'I allow my child to use the app, and I will regularly manage my child\'s access using key provided.',
                      style: TextStyle(
                        fontSize: 13,
                        color: tPrimaryColor
                      ),
                    ),
                    value: isParentConsentGiven,
                    onChanged: (value) => setState(() {
                      isParentConsentGiven = value ?? false;
                    }),
                    activeColor: tPrimaryColor, // Set the checkbox color
                    contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text(
                     'Submit Consent',
                      style: TextStyle(
                        fontSize: 14,
                        color: tPrimaryColor
                      )  
                    ),
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

class OtpForm extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final ConsentController consentController;

  const OtpForm({
    super.key,
    required this.controller,
    required this.consentController,
    required this.onSubmit,
  });

  @override
  // ignore: library_private_types_in_public_api
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  String? errorMessage;

  void _verifyOtp() {
    String otp = widget.controller.text.trim();

    
    if (widget.consentController.verifyOtp(otp)) {
      // OTP is verified successfully, proceed to next step
      widget.onSubmit();  // Trigger the onSubmit callback
    } else {
      setState(() {
        errorMessage = '$errorMessage : Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.all(40.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'OTP Verification', 
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: tPrimaryColor
                )
              ),

              const SizedBox(height: 13),
              const Text(
                'Enter the OTP here and keep your key phrase secure to manage app features for your child.',
                style: TextStyle(
                  fontSize: 11,
                  color: tPrimaryColor,
                ),
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  labelText: 'Enter Your 6-Digit OTP',
                  labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(vertical: 1.0),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _verifyOtp,  // Verify OTP when submitted
                child: const Text(
                  'Submit OTP',
                  style: TextStyle(
                    fontSize: 14,
                    color: tPrimaryColor
                  ),
                ),
              ),

              // Display error message if OTP is invalid
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// make the verify key phrase here only
