import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class SignInWithEmailRequested extends AuthEvent {

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class SignUpWithEmailRequested extends AuthEvent {

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
  });
  final String email;
  final String password;
  final String displayName;
  final String role;

  @override
  List<Object> get props => [email, password, displayName, role];
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class PasswordResetRequested extends AuthEvent {

  const PasswordResetRequested({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}

class SendEmailVerificationRequested extends AuthEvent {
  const SendEmailVerificationRequested();
}

class ReloadUserRequested extends AuthEvent {
  const ReloadUserRequested();
}
