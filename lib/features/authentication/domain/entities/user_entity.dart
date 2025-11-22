import 'package:equatable/equatable.dart';

/// Domain entity representing a user
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? role;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.role,
    this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoURL, role, createdAt];
}
