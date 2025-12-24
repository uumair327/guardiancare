import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';

/// Emergency repository interface defining emergency operations
abstract class EmergencyRepository {
  /// Get all emergency contacts
  Future<Either<Failure, List<EmergencyContactEntity>>> getEmergencyContacts();

  /// Get emergency contacts by category
  Future<Either<Failure, List<EmergencyContactEntity>>>
      getContactsByCategory(String category);

  /// Make a phone call to an emergency contact
  Future<Either<Failure, void>> makeEmergencyCall(String phoneNumber);
}
