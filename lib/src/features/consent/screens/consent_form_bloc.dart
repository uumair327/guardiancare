import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/bloc/consent_bloc.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';
import 'package:guardiancare/src/core/logging/app_logger.dart';

class ConsentFormBloc extends StatefulWidget {
  final VoidCallback onSubmit;
  final TextEditingController controller;
  final ConsentController consentController;

  const ConsentFormBloc({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.consentController,
  });

  @override
  _ConsentFormBlocState createState() => _ConsentFormBlocState();
}

class _ConsentFormBlocState extends State<ConsentFormBloc> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController parentEmailController = TextEditingController();
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController parentalKeyController = TextEditingController();
  final TextEditingController confirmParentalKeyController = TextEditingController();
  final TextEditingController securityQuestionController = TextEditingController();

  bool isChildAbove12 = false;
  bool isParentConsentGiven = false;
  String? errorMessage;
  bool isSubmitting = false;

  final String securityQuestion = "What is your favorite color ?";

  @override
  void dispose() {
    parentNameController.dispose();
    parentEmailController.dispose();
    childNameController.dispose();
    parentalKeyController.dispose();
    confirmParentalKeyController.dispose();
    securityQuestionController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) async {
    // Validate all fields using BLoC
    context.read<ConsentBloc>().add(ValidateAllFields({
      'parentName': parentNameController.text,
      'parentEmail': parentEmailController.text,
      'childName': childNameController.text,
      'parentalKey': parentalKeyController.text,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityQuestionController.text,
    }));

    // Wait a bit for validation to complete
    await Future.delayed(const Duration(milliseconds: 100));

    final consentState = context.read<ConsentBloc>().state;

    if (!consentState.isValid) {
      setState(() {
        errorMessage = 'Please fix all validation errors before submitting.';
      });
      return;
    }

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

      setState(() {
        isSubmitting = true;
        errorMessage = null;
      });

      try {
        AppLogger.feature('Consent', 'Submitting consent form');
        
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

        if (mounted) {
          if (result) {
            setState(() {
              errorMessage = null;
            });
            
            AppLogger.feature('Consent', 'Consent form submitted successfully');
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Consent submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            widget.onSubmit();
          } else {
            setState(() {
              errorMessage = 'There was an error saving the consent. Please try again.';
            });
            
            AppLogger.error('Consent', 'Failed to submit consent form');
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            errorMessage = 'Error saving consent: $e';
          });
          
          AppLogger.error('Consent', 'Error submitting consent form', error: e);
        }
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsentBloc(),
      child: BlocBuilder<ConsentBloc, ConsentState>(
        builder: (context, state) {
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: tPrimaryColor,
                          ),
                        ),

                        const SizedBox(height: 12),
                        TextFormField(
                          controller: parentNameController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: "Parent's Name",
                            labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                            isDense: true,
                            errorText: state.parentNameError,
                          ),
                          onChanged: (value) {
                            context.read<ConsentBloc>().add(ValidateParentName(value));
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter parent\'s name'
                              : null,
                        ),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: parentEmailController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: "Parent's Email",
                            labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                            isDense: true,
                            errorText: state.parentEmailError,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            context.read<ConsentBloc>().add(ValidateParentEmail(value));
                          },
                          validator: (value) =>
                              value == null || !EmailValidator.validate(value)
                                  ? 'Please enter a valid email address'
                                  : null,
                        ),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: childNameController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: "Child's Name",
                            labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                            isDense: true,
                            errorText: state.childNameError,
                          ),
                          onChanged: (value) {
                            context.read<ConsentBloc>().add(ValidateChildName(value));
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter child\'s name'
                              : null,
                        ),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: parentalKeyController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: "Create Parental Key",
                            labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                            isDense: true,
                            errorText: state.parentalKeyError,
                          ),
                          obscureText: true,
                          onChanged: (value) {
                            context.read<ConsentBloc>().add(ValidateParentalKey(value));
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a parental key';
                            }
                            if (value.length < 6) {
                              return 'Parental key must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmParentalKeyController,
                          enabled: !isSubmitting,
                          decoration: const InputDecoration(
                            labelText: "Confirm Parental Key",
                            labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0),
                            isDense: true,
                          ),
                          obscureText: true,
                          validator: (value) => value != parentalKeyController.text
                              ? 'Parental Key does not match'
                              : null,
                        ),

                        const SizedBox(height: 10),
                        TextFormField(
                          controller: securityQuestionController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            label: Text(
                              "Security Question: $securityQuestion",
                              style: const TextStyle(color: tPrimaryColor, fontSize: 14),
                            ),
                            labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                            isDense: true,
                            errorText: state.securityAnswerError,
                          ),
                          onChanged: (value) {
                            context.read<ConsentBloc>().add(ValidateSecurityAnswer(value));
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your security answer'
                              : null,
                        ),

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
                          onChanged: isSubmitting ? null : (value) => setState(() {
                            isChildAbove12 = value ?? false;
                          }),
                          activeColor: tPrimaryColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        ),

                        CheckboxListTile(
                          title: const Text(
                            'I allow my child to use the app and will manage access using the key provided.',
                            style: TextStyle(
                              fontSize: 14,
                              color: tPrimaryColor,
                            ),
                          ),
                          value: isParentConsentGiven,
                          onChanged: isSubmitting ? null : (value) => setState(() {
                            isParentConsentGiven = value ?? false;
                          }),
                          activeColor: tPrimaryColor,
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
                          onPressed: isSubmitting ? null : () => _submitForm(context),
                          child: isSubmitting
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Submitting...', style: TextStyle(color: tPrimaryColor)),
                                  ],
                                )
                              : const Text(
                                  'Submit Consent',
                                  style: TextStyle(color: tPrimaryColor),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
