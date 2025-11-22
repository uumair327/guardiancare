import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/profile/domain/usecases/clear_user_preferences.dart';
import 'package:guardiancare/features/profile/domain/usecases/delete_account.dart';
import 'package:guardiancare/features/profile/domain/usecases/get_profile.dart';
import 'package:guardiancare/features/profile/domain/usecases/update_profile.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_event.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_state.dart';

/// BLoC for managing profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final DeleteAccount deleteAccount;
  final ClearUserPreferences clearUserPreferences;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.deleteAccount,
    required this.clearUserPreferences,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<DeleteAccountRequested>(_onDeleteAccount);
    on<ClearPreferencesRequested>(_onClearPreferences);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getProfile(event.uid);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await updateProfile(event.profile);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfileUpdated()),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(AccountDeleting());

    // Clear preferences first
    await clearUserPreferences(NoParams());

    // Then delete account
    final result = await deleteAccount(event.uid);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(AccountDeleted()),
    );
  }

  Future<void> _onClearPreferences(
    ClearPreferencesRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await clearUserPreferences(NoParams());

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(PreferencesCleared()),
    );
  }
}
