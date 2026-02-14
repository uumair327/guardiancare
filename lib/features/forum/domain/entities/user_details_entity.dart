import 'package:equatable/equatable.dart';

/// Domain entity representing user details for forum display
class UserDetailsEntity extends Equatable {

  const UserDetailsEntity({
    required this.userName,
    required this.userImage,
    required this.userEmail,
    required this.role,
  });
  final String userName;
  final String userImage;
  final String userEmail;
  final String role;

  @override
  List<Object?> get props => [userName, userImage, userEmail, role];
}
