import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/authentication/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {

  const AuthAuthenticated(this.user);
  final UserEntity user;

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {

  const AuthError(this.message, {this.code});
  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}

class EmailVerificationSent extends AuthState {
  const EmailVerificationSent();
}
