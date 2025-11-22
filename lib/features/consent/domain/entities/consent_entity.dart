import 'package:equatable/equatable.dart';

/// Consent entity representing parental consent information
class ConsentEntity extends Equatable {
  final String parentName;
  final String parentEmail;
  final String childName;
  final bool isChildAbove12;
  final String parentalKeyHash;
  final String securityQuestion;
  final String securityAnswerHash;
  final DateTime timestamp;
  final Map<String, bool> consentCheckboxes;

  const ConsentEntity({
    required this.parentName,
    required this.parentEmail,
    required this.childName,
    required this.isChildAbove12,
    required this.parentalKeyHash,
    required this.securityQuestion,
    required this.securityAnswerHash,
    required this.timestamp,
    required this.consentCheckboxes,
  });

  @override
  List<Object> get props => [
        parentName,
        parentEmail,
        childName,
        isChildAbove12,
        parentalKeyHash,
        securityQuestion,
        securityAnswerHash,
        timestamp,
        consentCheckboxes,
      ];

  bool get isValid =>
      parentName.isNotEmpty &&
      parentEmail.isNotEmpty &&
      childName.isNotEmpty &&
      parentalKeyHash.isNotEmpty &&
      securityQuestion.isNotEmpty &&
      securityAnswerHash.isNotEmpty;

  bool get hasRequiredConsents {
    final required = ['parentConsentGiven', 'termsAccepted', 'privacyPolicyAccepted'];
    return required.every((key) => consentCheckboxes[key] == true);
  }
}
