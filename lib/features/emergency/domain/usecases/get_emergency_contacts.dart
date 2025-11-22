import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:guardiancare/features/emergency/domain/repositories/emergency_repository.dart';

/// Use case for getting all emergency contacts
class GetEmergencyContacts
    implements UseCase<List<EmergencyContactEntity>, NoParams> {
  final EmergencyRepository repository;

  GetEmergencyContacts(this.repository);

  @override
  Future<Either<Failure, List<EmergencyContactEntity>>> call(
      NoParams params) async {
    return await repository.getEmergencyContacts();
  }
}
