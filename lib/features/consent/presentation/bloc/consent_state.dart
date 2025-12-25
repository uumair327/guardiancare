import 'package:equatable/equatable.dart';

abstract class ConsentState extends Equatable {
  const ConsentState();

  @override
  List<Object?> get props => [];
}

class ConsentInitial extends ConsentState {}

class ConsentSubmitting extends ConsentState {}

class ConsentSubmitted extends ConsentState {}

class ConsentVerifying extends ConsentState {}

class ParentalKeyVerified extends ConsentState {}

class ParentalKeyInvalid extends ConsentState {}

/// State indicating parental key format validation result
/// Requirements: 5.1
class ParentalKeyValidated extends ConsentState {
  final bool isValid;
  final String? errorMessage;

  const ParentalKeyValidated({
    required this.isValid,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isValid, errorMessage];
}

/// State indicating parental key has been submitted and persisted
/// Requirements: 5.2
class ParentalKeySubmitted extends ConsentState {
  const ParentalKeySubmitted();
}

/// State indicating parental key submission is in progress
class ParentalKeySubmitting extends ConsentState {
  const ParentalKeySubmitting();
}

class ConsentError extends ConsentState {
  final String message;

  const ConsentError(this.message);

  @override
  List<Object?> get props => [message];
}
