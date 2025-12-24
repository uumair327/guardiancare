import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentFormPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const ConsentFormPage({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}

class _ConsentFormPageState extends State<ConsentFormPage> {
  final TextEditingController _keyController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _submitConsent() async {
    // Validate parental key
    if (_keyController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Parental key must be at least 4 characters'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parental_key', _keyController.text);
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms && _keyController.text.length >= 4
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
                      child: Text(
                        'Submit',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
