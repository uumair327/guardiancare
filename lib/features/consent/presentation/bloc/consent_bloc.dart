import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/consent/domain/usecases/submit_consent.dart';
import 'package:guardiancare/features/consent/domain/usecases/verify_parental_key.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_event.dart';
import 'package:guardiancare/features/consent/presentation/bloc/consent_state.dart';

class ConsentBloc extends Bloc<ConsentEvent, ConsentState> {
  final SubmitConsent submitConsent;
  final VerifyParentalKey verifyParentalKey;

  ConsentBloc({
    required this.submitConsent,
    required this.verifyParentalKey,
  }) : super(ConsentInitial()) {
    on<SubmitConsentRequested>(_onSubmitConsent);
    on<VerifyParentalKeyRequested>(_onVerifyParentalKey);
  }

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
}
