import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';

/// Base class for profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {}

/// Loading state
class ProfileLoading extends ProfileState {}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {

  const ProfileLoaded(this.profile);
  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {}

/// Account deleted successfully
class AccountDeleted extends ProfileState {}

/// Preferences cleared successfully
class PreferencesCleared extends ProfileState {}

/// Error state
class ProfileError extends ProfileState {

  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Account deletion in progress
class AccountDeleting extends ProfileState {}

/// Language changed successfully
/// Requirements: 6.1
class LanguageChanged extends ProfileState {

  const LanguageChanged({
    required this.newLocale,
    required this.localeName,
  });
  final Locale newLocale;
  final String localeName;

  @override
  List<Object?> get props => [newLocale, localeName];
}

/// Language change in progress
class LanguageChanging extends ProfileState {}

/// Logged out successfully
/// Requirements: 6.3
class LoggedOut extends ProfileState {}

/// Logout in progress
class LoggingOut extends ProfileState {}
