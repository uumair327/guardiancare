import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/features/profile/domain/entities/profile_entity.dart';

/// Base class for profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user profile
class LoadProfile extends ProfileEvent {
  final String uid;

  const LoadProfile(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Event to update user profile
class UpdateProfileRequested extends ProfileEvent {
  final ProfileEntity profile;

  const UpdateProfileRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Event to delete user account
class DeleteAccountRequested extends ProfileEvent {
  final String uid;

  const DeleteAccountRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Event to clear user preferences
class ClearPreferencesRequested extends ProfileEvent {
  const ClearPreferencesRequested();
}

/// Event to request language change
/// Requirements: 6.1
class ChangeLanguageRequested extends ProfileEvent {
  final Locale newLocale;

  const ChangeLanguageRequested(this.newLocale);

  @override
  List<Object?> get props => [newLocale];
}

/// Event to request logout
/// Requirements: 6.3
class LogoutRequested extends ProfileEvent {
  const LogoutRequested();
}
