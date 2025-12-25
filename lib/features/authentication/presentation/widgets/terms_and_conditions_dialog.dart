import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

/// A dialog widget that displays terms and conditions for user acceptance.
/// 
/// This widget extracts the dialog rendering logic from LoginPage
/// to follow the Single Responsibility Principle.
class TermsAndConditionsDialog extends StatelessWidget {
  /// Callback function when the user accepts the terms
  final VoidCallback onAccept;
  
  /// Callback function when the user declines/cancels
  final VoidCallback onDecline;

  const TermsAndConditionsDialog({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  /// Shows the terms and conditions dialog and returns whether the user accepted.
  /// 
  /// Returns `true` if the user accepted, `false` if declined, or `null` if dismissed.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return TermsAndConditionsDialog(
          onAccept: () => Navigator.of(dialogContext).pop(true),
          onDecline: () => Navigator.of(dialogContext).pop(false),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: AppDimensions.dialogElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
      ),
      title: Text(
        'Terms and Conditions',
        style: AppTextStyles.dialogTitle,
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'Please read and accept the following terms and conditions to proceed.',
              style: AppTextStyles.body2,
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              '• Your data will be securely stored.\n'
              '• You agree to follow the platform rules and regulations.\n'
              '• You acknowledge the responsibility of safeguarding your account.',
              style: AppTextStyles.body2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onAccept,
          child: Text('I Agree', style: AppTextStyles.button),
        ),
        TextButton(
          onPressed: onDecline,
          child: Text('Cancel', style: AppTextStyles.button),
        ),
      ],
    );
  }
}
