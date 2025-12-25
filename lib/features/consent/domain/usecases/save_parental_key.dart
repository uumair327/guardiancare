import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/consent/domain/repositories/consent_repository.dart';

class SaveParentalKeyParams extends Equatable {
  final String key;

  const SaveParentalKeyParams({required this.key});

  @override
  List<Object> get props => [key];
}

/// Use case for saving parental key locally
/// Requirements: 5.2
class SaveParentalKey implements UseCase<void, SaveParentalKeyParams> {
  final ConsentRepository repository;

  SaveParentalKey(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveParentalKeyParams params) async {
    return await repository.saveParentalKeyLocally(params.key);
  }
}
