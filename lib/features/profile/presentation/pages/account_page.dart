import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/authentication/authentication.dart';
import 'package:guardiancare/features/profile/profile.dart';
import 'package:guardiancare/main.dart' show Guardiancare;

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
            if (state is AccountDeleted) {
              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).accountDeletedSuccess),
                  duration: AppDurations.snackbarMedium,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  duration: AppDurations.snackbarMedium,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is AccountDeleting) {
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
              final profile = state.profile;
              final l10n = AppLocalizations.of(context);

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spaceS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
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
                      ),
                      SizedBox(height: AppDimensions.spaceL),
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
                      const Divider(),
                      SizedBox(height: AppDimensions.spaceS),
                      Text(
                        l10n.childSafetySettings,
                        style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, color: AppColors.primary),
                        title: Text(l10n.emergencyContact),
                        onTap: () => context.push('/emergency'),
                      ),
                      const Divider(),
                      SizedBox(height: AppDimensions.spaceS),
                      Text(l10n.settings, style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
                      ListTile(
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
                            onLocaleSelected: (newLocale) {
                              _changeAppLocale(context, newLocale);
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: AppColors.primary),
                        title: Text(l10n.logout),
                        onTap: () async {
                          bool shouldLogout = await showDialog(
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
                            context.read<ProfileBloc>().add(const ClearPreferencesRequested());
                            context.read<AuthBloc>().add(SignOutRequested());
                          }
                        },
                      ),
                      ListTile(
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
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Text(
                AppLocalizations.of(context).loadingProfile,
                style: AppTextStyles.body1,
              ),
            );
          },
          ),
        ),
      ),
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

  void _changeAppLocale(BuildContext context, Locale newLocale) async {
    final localeService = sl<LocaleService>();
    await localeService.saveLocale(newLocale);
    
    final rootState = Guardiancare.of(context);
    rootState?.changeLocale(newLocale);
    
    if (!context.mounted) return;
    
    final locales = LocaleService.getSupportedLocales();
    final localeInfo = locales.firstWhere(
      (info) => info.locale.languageCode == newLocale.languageCode,
      orElse: () => locales.first,
    );
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.languageChangedRestarting(localeInfo.nativeName),
          style: AppTextStyles.body2.copyWith(color: AppColors.onPrimary),
        ),
        backgroundColor: AppColors.primary,
        duration: AppDurations.snackbarMedium,
      ),
    );
    
    await Future.delayed(Duration(milliseconds: 1500));
    
    if (context.mounted) {
      AppRestartWidget.restartApp(context);
    }
  }
}
