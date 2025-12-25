import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';

abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

class SubmitConsentRequested extends ConsentEvent {
  final ConsentEntity consent;
  final String uid;

  const SubmitConsentRequested({required this.consent, required this.uid});

  @override
  List<Object?> get props => [consent, uid];
}

class VerifyParentalKeyRequested extends ConsentEvent {
  final String uid;
  final String key;

  const VerifyParentalKeyRequested({required this.uid, required this.key});

  @override
  List<Object?> get props => [uid, key];
}

/// Event to validate parental key format locally (before submission)
/// Requirements: 5.1
class ValidateParentalKey extends ConsentEvent {
  final String key;

  const ValidateParentalKey({required this.key});

  @override
  List<Object?> get props => [key];
}

/// Event to submit and persist parental key
/// Requirements: 5.2
class SubmitParentalKey extends ConsentEvent {
  final String key;
  final String uid;

  const SubmitParentalKey({required this.key, required this.uid});

  @override
  List<Object?> get props => [key, uid];
}
