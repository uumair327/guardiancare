import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/consent/domain/entities/consent_entity.dart';

class ConsentModel extends ConsentEntity {
  const ConsentModel({
    required super.parentName,
    required super.parentEmail,
    required super.childName,
    required super.isChildAbove12,
    required super.parentalKeyHash,
    required super.securityQuestion,
    required super.securityAnswerHash,
    required super.timestamp,
    required super.consentCheckboxes,
  });

  factory ConsentModel.fromEntity(ConsentEntity entity) {
    return ConsentModel(
      parentName: entity.parentName,
      parentEmail: entity.parentEmail,
      childName: entity.childName,
      isChildAbove12: entity.isChildAbove12,
      parentalKeyHash: entity.parentalKeyHash,
      securityQuestion: entity.securityQuestion,
      securityAnswerHash: entity.securityAnswerHash,
      timestamp: entity.timestamp,
      consentCheckboxes: entity.consentCheckboxes,
    );
  }

  factory ConsentModel.fromFirestore(Map<String, dynamic> doc) {
    return ConsentModel.fromMap(doc);
  }

  factory ConsentModel.fromMap(Map<String, dynamic> doc) {
    DateTime? getTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is DateTime) return val;
      return null;
    }

    return ConsentModel(
      parentName: doc['parentName'] as String? ?? '',
      parentEmail: doc['parentEmail'] as String? ?? '',
      childName: doc['childName'] as String? ?? '',
      isChildAbove12: doc['isChildAbove12'] as bool? ?? false,
      parentalKeyHash: doc['parentalKey'] as String? ?? '',
      securityQuestion: doc['securityQuestion'] as String? ?? '',
      securityAnswerHash: doc['securityAnswer'] as String? ?? '',
      timestamp: getTimestamp(doc['timestamp']) ?? DateTime.now(),
      consentCheckboxes: Map<String, bool>.from(doc['consentCheckboxes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parentName': parentName,
      'parentEmail': parentEmail,
      'childName': childName,
      'isChildAbove12': isChildAbove12,
      'parentalKey': parentalKeyHash,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswerHash,
      'timestamp': timestamp
          .toIso8601String(), // Changed to String for abstraction compatibility
      'consentCheckboxes': consentCheckboxes,
    };
  }
}
