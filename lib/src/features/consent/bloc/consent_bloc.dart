import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/src/features/consent/services/consent_form_validation_service.dart';

// Events
abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

class ValidateChildName extends ConsentEvent {
  final String name;

  const ValidateChildName(this.name);

  @override
  List<Object?> get props => [name];
}

class ValidateChildAge extends ConsentEvent {
  final String age;

  const ValidateChildAge(this.age);

  @override
  List<Object?> get props => [age];
}

class ValidateParentName extends ConsentEvent {
  final String name;

  const ValidateParentName(this.name);

  @override
  List<Object?> get props => [name];
}

class ValidateParentEmail extends ConsentEvent {
  final String email;

  const ValidateParentEmail(this.email);

  @override
  List<Object?> get props => [email];
}

class ValidateParentalKey extends ConsentEvent {
  final String key;

  const ValidateParentalKey(this.key);

  @override
  List<Object?> get props => [key];
}

class ValidateSecurityQuestion extends ConsentEvent {
  final String question;

  const ValidateSecurityQuestion(this.question);

  @override
  List<Object?> get props => [question];
}

class ValidateSecurityAnswer extends ConsentEvent {
  final String answer;

  const ValidateSecurityAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

class ValidateAllFields extends ConsentEvent {
  final Map<String, String> fields;

  const ValidateAllFields(this.fields);

  @override
  List<Object?> get props => [fields];
}

class ResetValidation extends ConsentEvent {
  const ResetValidation();
}

// State
class ConsentState extends Equatable {
  final String? childNameError;
  final String? childAgeError;
  final String? parentNameError;
  final String? parentEmailError;
  final String? parentalKeyError;
  final String? securityQuestionError;
  final String? securityAnswerError;
  final bool isValid;

  const ConsentState({
    this.childNameError,
    this.childAgeError,
    this.parentNameError,
    this.parentEmailError,
    this.parentalKeyError,
    this.securityQuestionError,
    this.securityAnswerError,
    this.isValid = false,
  });

  ConsentState copyWith({
    String? childNameError,
    String? childAgeError,
    String? parentNameError,
    String? parentEmailError,
    String? parentalKeyError,
    String? securityQuestionError,
    String? securityAnswerError,
    bool? isValid,
    bool clearChildNameError = false,
    bool clearChildAgeError = false,
    bool clearParentNameError = false,
    bool clearParentEmailError = false,
    bool clearParentalKeyError = false,
    bool clearSecurityQuestionError = false,
    bool clearSecurityAnswerError = false,
  }) {
    return ConsentState(
      childNameError: clearChildNameError ? null : (childNameError ?? this.childNameError),
      childAgeError: clearChildAgeError ? null : (childAgeError ?? this.childAgeError),
      parentNameError: clearParentNameError ? null : (parentNameError ?? this.parentNameError),
      parentEmailError: clearParentEmailError ? null : (parentEmailError ?? this.parentEmailError),
      parentalKeyError: clearParentalKeyError ? null : (parentalKeyError ?? this.parentalKeyError),
      securityQuestionError: clearSecurityQuestionError ? null : (securityQuestionError ?? this.securityQuestionError),
      securityAnswerError: clearSecurityAnswerError ? null : (securityAnswerError ?? this.securityAnswerError),
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
        childNameError,
        childAgeError,
        parentNameError,
        parentEmailError,
        parentalKeyError,
        securityQuestionError,
        securityAnswerError,
        isValid,
      ];
}

// BLoC
class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  final ConsentFormValidationService _validationService = ConsentFormValidationService.instance;

  ConsentBloc() : super(const ConsentState()) {
    on<ValidateChildName>(_onValidateChildName);
    on<ValidateChildAge>(_onValidateChildAge);
    on<ValidateParentName>(_onValidateParentName);
    on<ValidateParentEmail>(_onValidateParentEmail);
    on<ValidateParentalKey>(_onValidateParentalKey);
    on<ValidateSecurityQuestion>(_onValidateSecurityQuestion);
    on<ValidateSecurityAnswer>(_onValidateSecurityAnswer);
    on<ValidateAllFields>(_onValidateAllFields);
    on<ResetValidation>(_onResetValidation);
  }

  void _onValidateChildName(ValidateChildName event, Emitter<ConsentState> emit) {
    final error = _validationService.validateChildName(event.name);
    emit(state.copyWith(
      childNameError: error,
      clearChildNameError: error == null,
    ));
  }

  void _onValidateChildAge(ValidateChildAge event, Emitter<ConsentState> emit) {
    final error = _validationService.validateChildAge(event.age);
    emit(state.copyWith(
      childAgeError: error,
      clearChildAgeError: error == null,
    ));
  }

  void _onValidateParentName(ValidateParentName event, Emitter<ConsentState> emit) {
    final error = _validationService.validateParentName(event.name);
    emit(state.copyWith(
      parentNameError: error,
      clearParentNameError: error == null,
    ));
  }

  void _onValidateParentEmail(ValidateParentEmail event, Emitter<ConsentState> emit) {
    final error = _validationService.validateParentEmail(event.email);
    emit(state.copyWith(
      parentEmailError: error,
      clearParentEmailError: error == null,
    ));
  }

  void _onValidateParentalKey(ValidateParentalKey event, Emitter<ConsentState> emit) {
    final error = _validationService.validateParentalKey(event.key);
    emit(state.copyWith(
      parentalKeyError: error,
      clearParentalKeyError: error == null,
    ));
  }

  void _onValidateSecurityQuestion(ValidateSecurityQuestion event, Emitter<ConsentState> emit) {
    final error = _validationService.validateSecurityQuestion(event.question);
    emit(state.copyWith(
      securityQuestionError: error,
      clearSecurityQuestionError: error == null,
    ));
  }

  void _onValidateSecurityAnswer(ValidateSecurityAnswer event, Emitter<ConsentState> emit) {
    final error = _validationService.validateSecurityAnswer(event.answer);
    emit(state.copyWith(
      securityAnswerError: error,
      clearSecurityAnswerError: error == null,
    ));
  }

  void _onValidateAllFields(ValidateAllFields event, Emitter<ConsentState> emit) {
    final childNameError = _validationService.validateChildName(event.fields['childName'] ?? '');
    final childAgeError = _validationService.validateChildAge(event.fields['childAge'] ?? '');
    final parentNameError = _validationService.validateParentName(event.fields['parentName'] ?? '');
    final parentEmailError = _validationService.validateParentEmail(event.fields['parentEmail'] ?? '');
    final parentalKeyError = _validationService.validateParentalKey(event.fields['parentalKey'] ?? '');
    final securityQuestionError = _validationService.validateSecurityQuestion(event.fields['securityQuestion'] ?? '');
    final securityAnswerError = _validationService.validateSecurityAnswer(event.fields['securityAnswer'] ?? '');

    final isValid = childNameError == null &&
        childAgeError == null &&
        parentNameError == null &&
        parentEmailError == null &&
        parentalKeyError == null &&
        securityQuestionError == null &&
        securityAnswerError == null;

    emit(ConsentState(
      childNameError: childNameError,
      childAgeError: childAgeError,
      parentNameError: parentNameError,
      parentEmailError: parentEmailError,
      parentalKeyError: parentalKeyError,
      securityQuestionError: securityQuestionError,
      securityAnswerError: securityAnswerError,
      isValid: isValid,
    ));
  }

  void _onResetValidation(ResetValidation event, Emitter<ConsentState> emit) {
    emit(const ConsentState());
  }
}
