import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/emergency/domain/repositories/emergency_repository.dart';

/// Use case for making an emergency call
class MakeEmergencyCall implements UseCase<void, String> {

  MakeEmergencyCall(this.repository);
  final EmergencyRepository repository;

  @override
  Future<Either<Failure, void>> call(String phoneNumber) async {
    return repository.makeEmergencyCall(phoneNumber);
  }
}
