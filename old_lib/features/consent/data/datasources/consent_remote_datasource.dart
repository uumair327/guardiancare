import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:guardiancare/core/error/exceptions.dart';
import 'package:guardiancare/features/consent/data/models/consent_model.dart';

abstract class ConsentRemoteDataSource {
  Future<void> submitConsent(ConsentModel consent, String uid);
  Future<bool> verifyParentalKey(String uid, String key);
  Future<void> resetParentalKey(String uid, String securityAnswer, String newKey);
  Future<ConsentModel> getConsent(String uid);
  Future<bool> hasConsent(String uid);
}

class ConsentRemoteDataSourceImpl implements ConsentRemoteDataSource {
  final FirebaseFirestore firestore;

  ConsentRemoteDataSourceImpl({required this.firestore});

  String _hashKey(String key) {
    final bytes = utf8.encode(key);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<void> submitConsent(ConsentModel consent, String uid) async {
    try {
      await firestore.collection('consents').doc(uid).set(consent.toJson());
    } catch (e) {
      throw ServerException('Failed to submit consent: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyParentalKey(String uid, String key) async {
    try {
      final doc = await firestore.collection('consents').doc(uid).get();
      if (!doc.exists) return false;

      final storedHash = doc.data()?['parentalKey'] as String?;
      final enteredHash = _hashKey(key);
      return storedHash == enteredHash;
    } catch (e) {
      throw ServerException('Failed to verify key: ${e.toString()}');
    }
  }

  @override
  Future<void> resetParentalKey(String uid, String securityAnswer, String newKey) async {
    try {
      final doc = await firestore.collection('consents').doc(uid).get();
      if (!doc.exists) {
        throw ServerException('Consent not found');
      }

      final storedAnswerHash = doc.data()?['securityAnswer'] as String?;
      final providedAnswerHash = _hashKey(securityAnswer.toLowerCase());

      if (storedAnswerHash != providedAnswerHash) {
        throw ServerException('Incorrect security answer');
      }

      await firestore.collection('consents').doc(uid).update({
        'parentalKey': _hashKey(newKey),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to reset key: ${e.toString()}');
    }
  }

  @override
  Future<ConsentModel> getConsent(String uid) async {
    try {
      final doc = await firestore.collection('consents').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        throw ServerException('Consent not found');
      }
      return ConsentModel.fromFirestore(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get consent: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasConsent(String uid) async {
    try {
      final doc = await firestore.collection('consents').doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw ServerException('Failed to check consent: ${e.toString()}');
    }
  }
}
