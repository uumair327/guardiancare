import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';

abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

class SubmitConsentRequested extends ConsentEvent {

  const SubmitConsentRequested({required this.consent, required this.uid});
  final ConsentEntity consent;
  final String uid;

  @override
  List<Object?> get props => [consent, uid];
}

class VerifyParentalKeyRequested extends ConsentEvent {

  const VerifyParentalKeyRequested({required this.uid, required this.key});
  final String uid;
  final String key;

  @override
  List<Object?> get props => [uid, key];
}

/// Event to validate parental key format locally (before submission)
/// Requirements: 5.1
class ValidateParentalKey extends ConsentEvent {

  const ValidateParentalKey({required this.key});
  final String key;

  @override
  List<Object?> get props => [key];
}

/// Event to submit and persist parental key
/// Requirements: 5.2
class SubmitParentalKey extends ConsentEvent {

  const SubmitParentalKey({required this.key, required this.uid});
  final String key;
  final String uid;

  @override
  List<Object?> get props => [key, uid];
}
