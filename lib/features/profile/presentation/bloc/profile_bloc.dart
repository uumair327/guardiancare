import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/services/locale_service.dart';
import 'package:guardiancare/core/usecases/usecase.dart';
import 'package:guardiancare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:guardiancare/features/profile/domain/usecases/clear_user_preferences.dart';
import 'package:guardiancare/features/profile/domain/usecases/delete_account.dart';
import 'package:guardiancare/features/profile/domain/usecases/get_profile.dart';
import 'package:guardiancare/features/profile/domain/usecases/update_profile.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_event.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_state.dart';

/// BLoC for managing profile state
/// Delegates language changes to LocaleService and logout to AuthRepository
/// Requirements: 6.1, 6.2, 6.3
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.deleteAccount,
    required this.clearUserPreferences,
    required this.localeService,
    required this.authRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<DeleteAccountRequested>(_onDeleteAccount);
    on<ClearPreferencesRequested>(_onClearPreferences);
    on<ChangeLanguageRequested>(_onChangeLanguage);
    on<LogoutRequested>(_onLogout);
  }
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final DeleteAccount deleteAccount;
  final ClearUserPreferences clearUserPreferences;
  final LocaleService localeService;
  final AuthRepository authRepository;

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

  /// Handle language change request by delegating to LocaleService
  /// Requirements: 6.1
  Future<void> _onChangeLanguage(
    ChangeLanguageRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(LanguageChanging());

    try {
      // Delegate to LocaleService for persistence
      final success = await localeService.saveLocale(event.newLocale);

      if (success) {
        // Get locale display name
        final locales = LocaleService.getSupportedLocales();
        final localeInfo = locales.firstWhere(
          (info) => info.locale.languageCode == event.newLocale.languageCode,
          orElse: () => locales.first,
        );

        emit(LanguageChanged(
          newLocale: event.newLocale,
          localeName: localeInfo.nativeName,
        ));
      } else {
        emit(const ProfileError('Failed to save language preference'));
      }
    } on Object catch (e) {
      emit(ProfileError('Error changing language: ${e.toString()}'));
    }
  }

  /// Handle logout request by delegating to AuthRepository
  /// Requirements: 6.3
  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(LoggingOut());

    // Clear preferences first
    await clearUserPreferences(NoParams());

    // Delegate to AuthRepository for sign out
    final result = await authRepository.signOut();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(LoggedOut()),
    );
  }
}
