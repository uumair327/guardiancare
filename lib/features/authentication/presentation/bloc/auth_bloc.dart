import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/usecases/get_current_user.dart';
import 'package:guardiancare/features/authentication/domain/usecases/reload_user.dart';
import 'package:guardiancare/features/authentication/domain/usecases/send_email_verification.dart';
import 'package:guardiancare/features/authentication/domain/usecases/send_password_reset_email.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_out.dart';
import 'package:guardiancare/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_event.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    required this.sendPasswordResetEmail,
    required this.sendEmailVerification,
    required this.reloadUser,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<ReloadUserRequested>(_onReloadUserRequested);
  }
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final SendEmailVerification sendEmailVerification;
  final ReloadUser reloadUser;

  Future<void> _onReloadUserRequested(
    ReloadUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await reloadUser(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (_) => add(const CheckAuthStatus()),
    );
  }

  Future<void> _onSendEmailVerificationRequested(
    SendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Show loading? Maybe not necessary for resend, just disable button.
    // But let's keep consistent.
    emit(const AuthLoading());

    final result = await sendEmailVerification(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (_) => emit(const EmailVerificationSent()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUser(NoParams());

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithEmail(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signUpWithEmail(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signInWithGoogle(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (user) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await sendPasswordResetEmail(
      PasswordResetParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message, code: failure.code)),
      (_) => emit(const PasswordResetEmailSent()),
    );
  }
}
