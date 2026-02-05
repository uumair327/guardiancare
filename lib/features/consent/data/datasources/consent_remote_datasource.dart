import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/core/constants/constants.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/consent/data/models/consent_model.dart';

abstract class ConsentRemoteDataSource {
  Future<void> submitConsent(ConsentModel consent, String uid);
  Future<bool> verifyParentalKey(String uid, String key);
  Future<void> resetParentalKey(
      String uid, String securityAnswer, String newKey);
  Future<ConsentModel> getConsent(String uid);
  Future<bool> hasConsent(String uid);
}

class ConsentRemoteDataSourceImpl implements ConsentRemoteDataSource {
  final IDataStore _dataStore;

  ConsentRemoteDataSourceImpl({required IDataStore dataStore})
      : _dataStore = dataStore;

  String _hashKey(String key) {
    final bytes = utf8.encode(key);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<void> submitConsent(ConsentModel consent, String uid) async {
    try {
      final result = await _dataStore.set('consents', uid, consent.toJson());
      if (result.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.submitConsentError, result.errorOrNull!.message));
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.submitConsentError, e.toString()));
    }
  }

  @override
  Future<bool> verifyParentalKey(String uid, String key) async {
    try {
      final result = await _dataStore.get('consents', uid);

      return result.when(
        success: (data) {
          if (data == null) return false;
          final storedHash = data['parentalKey'] as String?;
          final enteredHash = _hashKey(key);
          return storedHash == enteredHash;
        },
        failure: (error) {
          throw ServerException(ErrorStrings.withDetails(
              ErrorStrings.verifyKeyError, error.message));
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          ErrorStrings.withDetails(ErrorStrings.verifyKeyError, e.toString()));
    }
  }

  @override
  Future<void> resetParentalKey(
      String uid, String securityAnswer, String newKey) async {
    try {
      final result = await _dataStore.get('consents', uid);

      final currentData = result.when(
        success: (data) => data,
        failure: (error) => null, // Will handle below
      );

      if (currentData == null) {
        throw ServerException(ErrorStrings.consentNotFound);
      }

      final storedAnswerHash = currentData['securityAnswer'] as String?;
      final providedAnswerHash = _hashKey(securityAnswer.toLowerCase());

      if (storedAnswerHash != providedAnswerHash) {
        throw ServerException(ErrorStrings.incorrectSecurityAnswer);
      }

      final updateResult = await _dataStore.update('consents', uid, {
        'parentalKey': _hashKey(newKey),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      if (updateResult.isFailure) {
        throw ServerException(ErrorStrings.withDetails(
            ErrorStrings.resetKeyError, updateResult.errorOrNull!.message));
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          ErrorStrings.withDetails(ErrorStrings.resetKeyError, e.toString()));
    }
  }

  @override
  Future<ConsentModel> getConsent(String uid) async {
    try {
      final result = await _dataStore.get('consents', uid);

      return result.when(
        success: (data) {
          if (data == null) {
            throw ServerException(ErrorStrings.consentNotFound);
          }
          return ConsentModel.fromMap(data);
        },
        failure: (error) {
          throw ServerException(ErrorStrings.withDetails(
              ErrorStrings.getConsentError, error.message));
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          ErrorStrings.withDetails(ErrorStrings.getConsentError, e.toString()));
    }
  }

  @override
  Future<bool> hasConsent(String uid) async {
    try {
      final result = await _dataStore.get('consents', uid);
      return result.isSuccess && result.dataOrNull != null;
    } catch (e) {
      throw ServerException(ErrorStrings.withDetails(
          ErrorStrings.checkConsentError, e.toString()));
    }
  }
}
