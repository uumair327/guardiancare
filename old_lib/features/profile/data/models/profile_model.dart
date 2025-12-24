import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';

/// Profile model extending ProfileEntity with JSON serialization
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.photoURL,
    super.createdAt,
    super.lastLoginAt,
    super.authProvider,
    super.profileValidated,
  });

  /// Create ProfileModel from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoURL: json['photoURL'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] as Timestamp).toDate()
          : null,
      authProvider: json['authProvider'] as String?,
      profileValidated: json['profileValidated'] as bool? ?? false,
    );
  }

  /// Convert ProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'authProvider': authProvider,
      'profileValidated': profileValidated,
    };
  }

  /// Create ProfileModel from ProfileEntity
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      photoURL: entity.photoURL,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      authProvider: entity.authProvider,
      profileValidated: entity.profileValidated,
    );
  }
}
