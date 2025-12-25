import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_bloc.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_event.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_state.dart';

class ConsentFormPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const ConsentFormPage({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}

class _ConsentFormPageState extends State<ConsentFormPage> {
  final TextEditingController _keyController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isKeyValid = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  void _validateKey(String key) {
    // Dispatch validation event to bloc
    context.read<ConsentBloc>().add(ValidateParentalKey(key: key));
  }

  void _submitConsent() {
    // Dispatch submit event to bloc
    context.read<ConsentBloc>().add(
      SubmitParentalKey(
        key: _keyController.text,
        uid: '', // UID is not needed for local storage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConsentBloc, ConsentState>(
      listener: (context, state) {
        if (state is ParentalKeyValidated) {
          setState(() {
            _isKeyValid = state.isValid;
          });
          if (!state.isValid && state.errorMessage != null) {
            // Only show error if user has typed something
            if (_keyController.text.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        } else if (state is ParentalKeySubmitted) {
          // Key saved successfully, call the onSubmit callback
          widget.onSubmit();
        } else if (state is ConsentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Center(
        child: Card(
          margin: AppDimensions.paddingAllL,
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusL,
          ),
          child: Padding(
            padding: AppDimensions.paddingAllL,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Parental Consent',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  Text(
                    'This app is designed for children. Please set up a parental key to protect your child.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  TextField(
                    controller: _keyController,
                    decoration: InputDecoration(
                      labelText: 'Set Parental Key (min 4 characters)',
                      labelStyle: AppTextStyles.bodyMedium,
                      hintText: 'Letters, numbers, or both',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: AppDimensions.borderRadiusM,
                        borderSide: BorderSide(
                          color: AppColors.inputBorder,
                          width: AppDimensions.borderThin,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppDimensions.borderRadiusM,
                        borderSide: BorderSide(
                          color: AppColors.inputBorderFocused,
                          width: AppDimensions.borderThick,
                        ),
                      ),
                      contentPadding: AppDimensions.inputPadding,
                    ),
                    style: AppTextStyles.bodyMedium,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onChanged: _validateKey,
                  ),
                  SizedBox(height: AppDimensions.spaceM),
                  CheckboxListTile(
                    title: Text(
                      'I agree to the terms and conditions',
                      style: AppTextStyles.bodyMedium,
                    ),
                    value: _agreedToTerms,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  BlocBuilder<ConsentBloc, ConsentState>(
                    builder: (context, state) {
                      final isSubmitting = state is ParentalKeySubmitting;
                      return SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _agreedToTerms && _isKeyValid && !isSubmitting
                              ? _submitConsent
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor: AppColors.buttonDisabled,
                            padding: AppDimensions.buttonPadding,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusM,
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: AppTextStyles.button,
                                ),
                        ),
                      );
                    },
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
