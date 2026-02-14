import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class SubmitConsentParams extends Equatable {

  const SubmitConsentParams({required this.consent, required this.uid});
  final ConsentEntity consent;
  final String uid;

  @override
  List<Object> get props => [consent, uid];
}

class SubmitConsent implements UseCase<void, SubmitConsentParams> {

  SubmitConsent(this.repository);
  final ConsentRepository repository;

  @override
  Future<Either<Failure, void>> call(SubmitConsentParams params) async {
    return repository.submitConsent(params.consent, params.uid);
  }
}
