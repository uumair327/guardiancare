import 'package:equatable/equatable.dart';

/// Profile entity representing user profile information
class ProfileEntity extends Equatable {

  const ProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
    this.authProvider,
    this.profileValidated = false,
  });
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? authProvider;
  final bool profileValidated;

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        photoURL,
        createdAt,
        lastLoginAt,
        authProvider,
        profileValidated,
      ];
}
