import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';

/// Consent repository interface
abstract class ConsentRepository {
  /// Submit consent form
  Future<Either<Failure, void>> submitConsent(ConsentEntity consent, String uid);

  /// Verify parental key
  Future<Either<Failure, bool>> verifyParentalKey(String uid, String key);

  /// Reset parental key with security answer
  Future<Either<Failure, void>> resetParentalKey(
      String uid, String securityAnswer, String newKey);

  /// Get consent data
  Future<Either<Failure, ConsentEntity>> getConsent(String uid);

  /// Check if consent exists
  Future<Either<Failure, bool>> hasConsent(String uid);
}
