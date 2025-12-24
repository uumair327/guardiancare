import 'package:equatable/equatable.dart';
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
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

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
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Account deletion in progress
class AccountDeleting extends ProfileState {}
