import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/consent/domain/usecases/save_parental_key.dart';
import 'package:guardiancare/features/consent/domain/usecases/submit_consent.dart';
import 'package:guardiancare/features/consent/domain/usecases/verify_parental_key.dart';
import 'package:guardiancare/features/consent/domain/validators/parental_key_validator.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_event.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_state.dart';

/// BLoC for managing consent state.
///
/// Delegates business logic to domain-layer use cases and validators.
/// The Bloc only orchestrates state transitions.
class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  ConsentBloc({
    required this.submitConsent,
    required this.verifyParentalKey,
    required this.saveParentalKey,
    this.keyValidator = const ParentalKeyValidator(),
  }) : super(ConsentInitial()) {
    on<SubmitConsentRequested>(_onSubmitConsent);
    on<VerifyParentalKeyRequested>(_onVerifyParentalKey);
    on<ValidateParentalKey>(_onValidateParentalKey);
    on<SubmitParentalKey>(_onSubmitParentalKey);
  }
  final SubmitConsent submitConsent;
  final VerifyParentalKey verifyParentalKey;
  final SaveParentalKey saveParentalKey;

  /// Domain-layer validator (injected for testability)
  final ParentalKeyValidator keyValidator;

  Future<void> _onSubmitConsent(
    SubmitConsentRequested event,
    Emitter<ConsentState> emit,
  ) async {
    emit(ConsentSubmitting());

    final result = await submitConsent(
      SubmitConsentParams(consent: event.consent, uid: event.uid),
    );

    result.fold(
      (failure) => emit(ConsentError(failure.message)),
      (_) => emit(ConsentSubmitted()),
    );
  }

  Future<void> _onVerifyParentalKey(
    VerifyParentalKeyRequested event,
    Emitter<ConsentState> emit,
  ) async {
    emit(ConsentVerifying());

    final result = await verifyParentalKey(
      VerifyParentalKeyParams(uid: event.uid, key: event.key),
    );

    result.fold(
      (failure) => emit(ConsentError(failure.message)),
      (isValid) => emit(isValid ? ParentalKeyVerified() : ParentalKeyInvalid()),
    );
  }

  /// Handle parental key format validation (local validation)
  /// Delegates to domain-layer ParentalKeyValidator.
  /// Requirements: 5.1
  void _onValidateParentalKey(
    ValidateParentalKey event,
    Emitter<ConsentState> emit,
  ) {
    final validationResult = keyValidator.validate(event.key);

    emit(ParentalKeyValidated(
      isValid: validationResult.isValid,
      errorMessage: validationResult.errorMessage,
    ));
  }

  /// Handle parental key submission and persistence
  /// Requirements: 5.2
  Future<void> _onSubmitParentalKey(
    SubmitParentalKey event,
    Emitter<ConsentState> emit,
  ) async {
    // Validate before submitting (domain logic delegated)
    final validationResult = keyValidator.validate(event.key);
    if (!validationResult.isValid) {
      emit(ParentalKeyValidated(
        isValid: false,
        errorMessage: validationResult.errorMessage,
      ));
      return;
    }

    emit(const ParentalKeySubmitting());

    final result = await saveParentalKey(
      SaveParentalKeyParams(key: event.key),
    );

    result.fold(
      (failure) => emit(ConsentError(failure.message)),
      (_) => emit(const ParentalKeySubmitted()),
    );
  }
}
