import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class SubmitConsentParams extends Equatable {
  final ConsentEntity consent;
  final String uid;

  const SubmitConsentParams({required this.consent, required this.uid});

  @override
  List<Object> get props => [consent, uid];
}

class SubmitConsent implements UseCase<void, SubmitConsentParams> {
  final ConsentRepository repository;

  SubmitConsent(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitConsentParams params) async {
    return await repository.submitConsent(params.consent, params.uid);
  }
}
