import 'package:guardiancare/features/emergency/domain/entities/emergency_contact_entity.dart';

/// Emergency contact model extending EmergencyContactEntity with JSON serialization
class EmergencyContactModel extends EmergencyContactEntity {
  const EmergencyContactModel({
    required super.name,
    required super.number,
    required super.category,
    super.description,
  });

  /// Create EmergencyContactModel from JSON
  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] as String? ?? '',
      number: json['number'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  /// Convert EmergencyContactModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'category': category,
      'description': description,
    };
  }

  /// Create EmergencyContactModel from EmergencyContactEntity
  factory EmergencyContactModel.fromEntity(EmergencyContactEntity entity) {
    return EmergencyContactModel(
      name: entity.name,
      number: entity.number,
      category: entity.category,
      description: entity.description,
    );
  }
}
