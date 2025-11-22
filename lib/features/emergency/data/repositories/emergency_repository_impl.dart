import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/emergency/data/datasources/emergency_local_datasource.dart';
import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';
import 'package:guardiancare/features/emergency/domain/repositories/emergency_repository.dart';

/// Implementation of EmergencyRepository
class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyLocalDataSource localDataSource;

  EmergencyRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<EmergencyContactEntity>>>
      getEmergencyContacts() async {
    try {
      final contacts = await localDataSource.getEmergencyContacts();
      return Right(contacts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get emergency contacts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<EmergencyContactEntity>>> getContactsByCategory(
      String category) async {
    try {
      final contacts = await localDataSource.getContactsByCategory(category);
      return Right(contacts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
          CacheFailure('Failed to get contacts by category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> makeEmergencyCall(String phoneNumber) async {
    try {
      await localDataSource.makePhoneCall(phoneNumber);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to make emergency call: ${e.toString()}'));
    }
  }
}
