import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/profile/profile.dart';
import 'package:guardiancare/main.dart' show Guardiancare;

/// Account page that displays user profile and settings
/// Dispatches events to ProfileBloc for business logic
/// Requirements: 6.1, 6.2, 6.3, 6.4
class AccountPage extends StatelessWidget {
  final User? user;

  const AccountPage({super.key, this.user});

  Future<void> _confirmAndDeleteAccount(
      BuildContext context, ProfileBloc profileBloc) async {
    final l10n = AppLocalizations.of(context);
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
          ),
          title: Text(l10n.deleteAccount, style: AppTextStyles.dialogTitle),
          content: Text(l10n.deleteAccountConfirm, style: AppTextStyles.body2),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.no),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(l10n.yes),
            ),
          ],
        );
      },
    );

    if (shouldDelete && user != null) {
      profileBloc.add(DeleteAccountRequested(user!.uid));
    }
  }

  /// Show logout confirmation dialog and dispatch LogoutRequested event
  /// Requirements: 6.3
  Future<void> _confirmAndLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
          ),
          title: Text(l10n.logout, style: AppTextStyles.dialogTitle),
          content: Text(l10n.logoutConfirm, style: AppTextStyles.body2),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(dialogL10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(dialogL10n.logout),
            ),
          ],
        );
      },
    ) ?? false;

    if (shouldLogout && context.mounted) {
      // Dispatch logout event to ProfileBloc - delegates to AuthRepository
      context.read<ProfileBloc>().add(const LogoutRequested());
    }
  }

  /// Handle language selection by dispatching ChangeLanguageRequested event
  /// Requirements: 6.1
  void _onLanguageSelected(BuildContext context, Locale newLocale) {
    // Dispatch language change event to ProfileBloc - delegates to LocaleService
    context.read<ProfileBloc>().add(ChangeLanguageRequested(newLocale));
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.account)),
        body: SafeArea(
          child: Center(child: Text(l10n.noUserSignedIn)),
        ),
      );
    }

    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfile(user!.uid)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).account),
        ),
        body: SafeArea(
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              _handleStateChanges(context, state);
            },
            builder: (context, state) {
              return _buildContent(context, state);
            },
          ),
        ),
      ),
    );
  }

  /// Handle state changes from ProfileBloc
  void _handleStateChanges(BuildContext context, ProfileState state) {
    if (state is AccountDeleted) {
      context.go('/login');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).accountDeletedSuccess),
          duration: AppDurations.snackbarMedium,
        ),
      );
    } else if (state is LoggedOut) {
      // Navigate to login after successful logout
      context.go('/login');
    } else if (state is LanguageChanged) {
      // Update app locale and show confirmation
      _applyLanguageChange(context, state);
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          duration: AppDurations.snackbarMedium,
        ),
      );
    }
  }

  /// Apply language change to the app
  void _applyLanguageChange(BuildContext context, LanguageChanged state) {
    // Update the root app state with new locale
    final rootState = Guardiancare.of(context);
    rootState?.changeLocale(state.newLocale);

    // Show confirmation snackbar
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.languageChangedRestarting(state.localeName),
          style: AppTextStyles.body2.copyWith(color: AppColors.onPrimary),
        ),
        backgroundColor: AppColors.primary,
        duration: AppDurations.snackbarMedium,
      ),
    );

    // Restart app after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        AppRestartWidget.restartApp(context);
      }
    });
  }

  /// Build page content based on current state
  Widget _buildContent(BuildContext context, ProfileState state) {
    if (state is ProfileLoading || state is AccountDeleting || 
        state is LoggingOut || state is LanguageChanging) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ProfileError && state is! AccountDeleting) {
      return Center(
        child: Text(
          "Error: ${state.message}",
          style: AppTextStyles.error,
        ),
      );
    }

    if (state is ProfileLoaded) {
      return _buildProfileContent(context, state.profile);
    }

    return Center(
      child: Text(
        AppLocalizations.of(context).loadingProfile,
        style: AppTextStyles.body1,
      ),
    );
  }

  /// Build profile content UI
  Widget _buildProfileContent(BuildContext context, ProfileEntity profile) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spaceS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(profile),
            SizedBox(height: AppDimensions.spaceL),
            _buildProfileSection(context, profile, l10n),
            const Divider(),
            SizedBox(height: AppDimensions.spaceS),
            _buildChildSafetySection(context, l10n),
            const Divider(),
            SizedBox(height: AppDimensions.spaceS),
            _buildSettingsSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ProfileEntity profile) {
    return CircleAvatar(
      radius: AppDimensions.avatarXL / 2,
      backgroundImage: profile.photoURL != null
          ? NetworkImage(profile.photoURL!)
          : null,
      child: profile.displayName.isNotEmpty
          ? Text(
              profile.displayName[0].toUpperCase(),
              style: AppTextStyles.h2,
            )
          : null,
    );
  }

  Widget _buildProfileSection(BuildContext context, ProfileEntity profile, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.profile, style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
        ListTile(
          leading: Icon(Icons.person, color: AppColors.primary),
          title: Text('${l10n.nameLabel}: ${profile.displayName}'),
        ),
        ListTile(
          minTileHeight: 5,
          leading: Icon(Icons.email, color: AppColors.primary),
          title: Text('${l10n.emailLabel}: ${profile.email}'),
        ),
      ],
    );
  }

  Widget _buildChildSafetySection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.childSafetySettings,
          style: AppTextStyles.h4.copyWith(color: AppColors.primary),
        ),
        ListTile(
          leading: Icon(Icons.phone, color: AppColors.primary),
          title: Text(l10n.emergencyContact),
          onTap: () => context.push('/emergency'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.settings, style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
        _buildLanguageTile(context, l10n),
        _buildLogoutTile(context, l10n),
        _buildDeleteAccountTile(context, l10n),
      ],
    );
  }

  /// Build language selection tile - dispatches ChangeLanguageRequested
  /// Requirements: 6.1
  Widget _buildLanguageTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: Icon(Icons.language, color: AppColors.primary),
      title: Text(l10n.language),
      subtitle: Text(
        _getCurrentLanguageName(context),
        style: AppTextStyles.body2,
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: AppDimensions.iconS),
      onTap: () {
        final currentLocale = Localizations.localeOf(context);
        LanguageSelectorDialog.show(
          context,
          currentLocale: currentLocale,
          onLocaleSelected: (newLocale) => _onLanguageSelected(context, newLocale),
        );
      },
    );
  }

  /// Build logout tile - dispatches LogoutRequested
  /// Requirements: 6.3
  Widget _buildLogoutTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: Icon(Icons.logout, color: AppColors.primary),
      title: Text(l10n.logout),
      onTap: () => _confirmAndLogout(context),
    );
  }

  Widget _buildDeleteAccountTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      minTileHeight: 5,
      leading: Icon(Icons.delete, color: AppColors.primary),
      title: Text(
        l10n.deleteMyAccount,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () async {
        await _confirmAndDeleteAccount(
          context,
          context.read<ProfileBloc>(),
        );
      },
    );
  }

  String _getCurrentLanguageName(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final locales = LocaleService.getSupportedLocales();
    final localeInfo = locales.firstWhere(
      (info) => info.locale.languageCode == currentLocale.languageCode,
      orElse: () => locales.first,
    );
    return localeInfo.displayName;
  }
}
