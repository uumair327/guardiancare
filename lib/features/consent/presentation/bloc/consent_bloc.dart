import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/consent/domain/usecases/save_parental_key.dart';
import 'package:guardiancare/features/consent/domain/usecases/submit_consent.dart';
import 'package:guardiancare/features/consent/domain/usecases/verify_parental_key.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_event.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_state.dart';

class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {

  ConsentBloc({
    required this.submitConsent,
    required this.verifyParentalKey,
    required this.saveParentalKey,
  }) : super(ConsentInitial()) {
    on<SubmitConsentRequested>(_onSubmitConsent);
    on<VerifyParentalKeyRequested>(_onVerifyParentalKey);
    on<ValidateParentalKey>(_onValidateParentalKey);
    on<SubmitParentalKey>(_onSubmitParentalKey);
  }
  final SubmitConsent submitConsent;
  final VerifyParentalKey verifyParentalKey;
  final SaveParentalKey saveParentalKey;

  /// Minimum length for parental key validation
  static const int minKeyLength = 4;

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
  /// Requirements: 5.1
  void _onValidateParentalKey(
    ValidateParentalKey event,
    Emitter<ConsentState> emit,
  ) {
    final key = event.key;

    if (key.isEmpty) {
      emit(const ParentalKeyValidated(
        isValid: false,
        errorMessage: 'Parental key cannot be empty',
      ));
      return;
    }

    if (key.length < minKeyLength) {
      emit(const ParentalKeyValidated(
        isValid: false,
        errorMessage: 'Parental key must be at least $minKeyLength characters',
      ));
      return;
    }

    emit(const ParentalKeyValidated(isValid: true));
  }

  /// Handle parental key submission and persistence
  /// Requirements: 5.2
  Future<void> _onSubmitParentalKey(
    SubmitParentalKey event,
    Emitter<ConsentState> emit,
  ) async {
    // First validate the key
    if (event.key.length < minKeyLength) {
      emit(const ParentalKeyValidated(
        isValid: false,
        errorMessage: 'Parental key must be at least $minKeyLength characters',
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
