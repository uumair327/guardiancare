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

class ConsentError extends ConsentState {
  final String message;

  const ConsentError(this.message);

  @override
  List<Object?> get props => [message];
}
