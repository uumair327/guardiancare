import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:guardiancare/features/emergency/domain/repositories/emergency_repository.dart';

/// Use case for getting emergency contacts by category
class GetContactsByCategory
    implements UseCase<List<EmergencyContactEntity>, String> {

  GetContactsByCategory(this.repository);
  final EmergencyRepository repository;

  @override
  Future<Either<Failure, List<EmergencyContactEntity>>> call(
      String category) async {
    return repository.getContactsByCategory(category);
  }
}
