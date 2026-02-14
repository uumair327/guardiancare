import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class SaveParentalKeyParams extends Equatable {

  const SaveParentalKeyParams({required this.key});
  final String key;

  @override
  List<Object> get props => [key];
}

/// Use case for saving parental key locally
/// Requirements: 5.2
class SaveParentalKey implements UseCase<void, SaveParentalKeyParams> {

  SaveParentalKey(this.repository);
  final ConsentRepository repository;

  @override
  Future<Either<Failure, void>> call(SaveParentalKeyParams params) async {
    return repository.saveParentalKeyLocally(params.key);
  }
}
