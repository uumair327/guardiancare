import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class VerifyParentalKeyParams extends Equatable {

  const VerifyParentalKeyParams({required this.uid, required this.key});
  final String uid;
  final String key;

  @override
  List<Object> get props => [uid, key];
}

class VerifyParentalKey implements UseCase<bool, VerifyParentalKeyParams> {

  VerifyParentalKey(this.repository);
  final ConsentRepository repository;

  @override
  Future<Either<Failure, bool>> call(VerifyParentalKeyParams params) async {
    return repository.verifyParentalKey(params.uid, params.key);
  }
}
