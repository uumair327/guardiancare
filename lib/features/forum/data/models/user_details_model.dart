import 'package:guardiancare/features/forum/domain/entities/user_details_entity.dart';

/// Data model for UserDetails that extends the domain entity
class UserDetailsModel extends UserDetailsEntity {
  const UserDetailsModel({
    required super.userName,
    required super.userImage,
    required super.userEmail,
    required super.role,
  });

  /// Create UserDetailsModel from Firestore document
  factory UserDetailsModel.fromMap(Map<String, dynamic> map) {
    return UserDetailsModel(
      userName: map['displayName'] as String? ?? 'Anonymous',
      userImage: map['photoURL'] as String? ?? '',
      userEmail: map['email'] as String? ?? 'anonymous@mail.com',
      role: map['role'] as String? ?? 'child',
    );
  }

  /// Convert UserDetailsModel to Map
  Map<String, dynamic> toMap() {
    return {
      'displayName': userName,
      'photoURL': userImage,
      'email': userEmail,
      'role': role,
    };
  }
}
