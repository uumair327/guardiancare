import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/controllers/consent_controller.dart';

class EnhancedResetDialog extends StatefulWidget {
  final Function(String, String) onSubmit; // Security answer, new password
  final VoidCallback onCancel;

  const EnhancedResetDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<EnhancedResetDialog> createState() => _EnhancedResetDialogState();
}

class _EnhancedResetDialogState extends State<EnhancedResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _securityAnswerController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final String securityQuestion = "What is your favorite color?";

  @override
  void dispose() {
    _securityAnswerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSecurityQuestionField(),
              const SizedBox(height: 16),
              _buildNewPasswordField(),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(
          Icons.lock_reset,
          color: tPrimaryColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        const Text(
          "Reset Parental Key",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: tPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Answer your security question to reset your parental key",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityQuestionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Security Question:",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          securityQuestion,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _securityAnswerController,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: "Your Answer",
            labelStyle: TextStyle(color: tPrimaryColor, fontSize: 14),
            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tPrimaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your security answer';
            }
            if (value.trim().length < 2) {
              return 'Answer must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      enabled: !_isSubmitting,
      obscureText: _obscureNewPassword,
      decoration: InputDecoration(
        labelText: "New Parental Key",
        labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: tPrimaryColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
      ),
      validator: (value) {
        final validation = validateParentalKey(value);
        if (validation != null) return validation;
        
        if (value != null && value.length < 4) {
          return 'Parental key must be at least 4 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      enabled: !_isSubmitting,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: "Confirm New Parental Key",
        labelStyle: const TextStyle(color: tPrimaryColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: tPrimaryColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your new parental key';
        }
        if (value != _newPasswordController.text) {
          return 'Parental keys do not match';
        }
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isSubmitting ? null : widget.onCancel,
            child: const Text(
              "Cancel",
              style: TextStyle(color: tTextPrimary),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: tPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("Reset Key"),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      // Haptic feedback for validation errors
      HapticFeedback.lightImpact();
      return;
    }

    // Haptic feedback for successful validation
    HapticFeedback.selectionClick();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Add a small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 300));
      
      widget.onSubmit(
        _securityAnswerController.text.trim(),
        _newPasswordController.text,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to reset parental key. Please try again.';
          _isSubmitting = false;
        });
      }
    }
  }
}