import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class VerifyParentalKeyParams extends Equatable {
  final String uid;
  final String key;

  const VerifyParentalKeyParams({required this.uid, required this.key});

  @override
  List<Object> get props => [uid, key];
}

class VerifyParentalKey implements UseCase<bool, VerifyParentalKeyParams> {
  final ConsentRepository repository;

  VerifyParentalKey(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyParentalKeyParams params) async {
    return await repository.verifyParentalKey(params.uid, params.key);
  }
}
