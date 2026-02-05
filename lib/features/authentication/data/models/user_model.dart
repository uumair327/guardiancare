import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guardiancare/core/backend/models/backend_user.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';

/// Data model for User that extends the domain entity
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoURL,
    super.role,
    super.createdAt,
  });

  /// Create UserModel from BackendUser (Backend Agnostic)
  factory UserModel.fromBackendUser(BackendUser user, {String? role}) {
    return UserModel(
      uid: user.id,
      email: user.email ?? '', // Handle nullable email gracefully if needed
      displayName: user.displayName,
      photoURL: user.photoUrl,
      role: role,
      createdAt: user.createdAt,
    );
  }

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(firebase_auth.User user, {String? role}) {
    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      role: role,
      createdAt: user.metadata.creationTime,
    );
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
