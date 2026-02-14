import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:guardiancare/core/error/failures.dart';
import 'package:guardiancare/core/services/crypto_service.dart';

/// Abstract interface for parental key verification
/// Handles verification logic exclusively using CryptoService for hashing
/// Requirements: 9.2
abstract class ParentalKeyVerifier {
  /// Verify a parental key against the stored hash for a user
  Future<Either<Failure, bool>> verify(String uid, String key);
}

/// Implementation of ParentalKeyVerifier
/// Uses CryptoService for hashing and Firestore for stored hash retrieval
class ParentalKeyVerifierImpl implements ParentalKeyVerifier {

  ParentalKeyVerifierImpl({
    required CryptoService cryptoService,
    required FirebaseFirestore firestore,
  })  : _cryptoService = cryptoService,
        _firestore = firestore;
  final CryptoService _cryptoService;
  final FirebaseFirestore _firestore;

  @override
  Future<Either<Failure, bool>> verify(String uid, String key) async {
    try {
      final doc = await _firestore.collection('consents').doc(uid).get();

      if (!doc.exists) {
        return const Right(false);
      }

      final storedHash = doc.data()?['parentalKey'] as String?;
      if (storedHash == null) {
        return const Right(false);
      }

      final isValid = _cryptoService.compareHash(key, storedHash);
      return Right(isValid);
    } on Object catch (e) {
      return Left(AuthenticationFailure('Error verifying parental key: $e'));
    }
  }
}
