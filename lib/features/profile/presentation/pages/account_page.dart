import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/di/injection_container.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_event.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_event.dart';
import 'package:guardiancare/features/profile/presentation/bloc/profile_state.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/widgets/language_selector_dialog.dart';
import 'package:guardiancare/core/services/locale_service.dart';
import 'package:guardiancare/core/widgets/app_restart_widget.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';
import 'package:guardiancare/main.dart' show guardiancare;

class AccountPage extends StatelessWidget {
  final User? user;

  const AccountPage({super.key, this.user});

  Future<void> _confirmAndDeleteAccount(
      BuildContext context, ProfileBloc profileBloc) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deleteAccount,
              style:
                  const TextStyle(color: tPrimaryColor, fontWeight: FontWeight.bold)),
          content: Text(l10n.deleteAccountConfirm),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(l10n.no),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: tPrimaryColor,
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
    print('I am the user: ${user?.uid}');
    
    if (user == null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.account),
        ),
        body: Center(
          child: Text(l10n.noUserSignedIn),
        ),
      );
    }

    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfile(user!.uid)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.account),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is AccountDeleted) {
              // Navigate to login page after successful deletion
              context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.accountDeletedSuccess)),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is AccountDeleting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError && state is! AccountDeleting) {
              return Center(child: Text("Error: ${state.message}"));
            }

            if (state is ProfileLoaded) {
              final profile = state.profile;
              final l10n = AppLocalizations.of(context)!;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.photoURL != null
                            ? NetworkImage(profile.photoURL!)
                            : null,
                        child: profile.displayName.isNotEmpty
                            ? Text(profile.displayName[0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.profile,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: tPrimaryColor,
                        ),
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.person, color: tPrimaryColor),
                        title: Text('${l10n.nameLabel}: ${profile.displayName}'),
                      ),
                      ListTile(
                        minTileHeight: 5,
                        leading: const Icon(Icons.email, color: tPrimaryColor),
                        title: Text('${l10n.emailLabel}: ${profile.email}'),
                      ),
                      const Divider(),
                      const SizedBox(height: 5),
                      Text(
                        l10n.childSafetySettings,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: tPrimaryColor,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone, color: tPrimaryColor),
                        title: Text(l10n.emergencyContact),
                        onTap: () => context.push('/emergency'),
                      ),
                      const Divider(),
                      const SizedBox(height: 5),
                      Text(
                        l10n.settings,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: tPrimaryColor,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.language, color: tPrimaryColor),
                        title: Text(l10n.language),
                        subtitle: Text(
                          _getCurrentLanguageName(context),
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                        leading: const Icon(Icons.logout, color: tPrimaryColor),
                        title: Text(l10n.logout),
                        onTap: () async {
                          // Show confirmation dialog
                          bool shouldLogout = await showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              final dialogL10n = AppLocalizations.of(dialogContext)!;
                              return AlertDialog(
                                title: Text(l10n.logout,
                                    style: const TextStyle(
                                        color: tPrimaryColor,
                                        fontWeight: FontWeight.bold)),
                                content: Text(l10n.logoutConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(false);
                                    },
                                    child: Text(dialogL10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: tPrimaryColor,
                                    ),
                                    child: Text(dialogL10n.logout),
                                  ),
                                ],
                              );
                            },
                          ) ?? false;

                          if (shouldLogout && context.mounted) {
                            // Clear preferences
                            context
                                .read<ProfileBloc>()
                                .add(const ClearPreferencesRequested());

                            // Sign out using AuthBloc - router will automatically redirect to login
                            context.read<AuthBloc>().add(SignOutRequested());
                          }
                        },
                      ),
                      ListTile(
                        minTileHeight: 5,
                        leading: const Icon(Icons.delete, color: tPrimaryColor),
                        title: Text(
                          l10n.deleteMyAccount,
                          style: const TextStyle(
                              color: tPrimaryColor,
                              fontWeight: FontWeight.bold),
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

            return Center(child: Text(AppLocalizations.of(context)!.loadingProfile));
          },
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
    print('🌍 _changeAppLocale called with: ${newLocale.languageCode}');
    
    // Save locale using LocaleService (Clean Architecture - use service)
    final localeService = sl<LocaleService>();
    final saved = await localeService.saveLocale(newLocale);
    print('💾 Locale saved to storage: $saved');
    
    // Update root state
    final rootState = guardiancare.of(context);
    if (rootState != null) {
      rootState.changeLocale(newLocale);
      print('✅ Root state updated');
    } else {
      print('❌ Root state is null!');
    }
    
    // Check if widget is still mounted
    if (!context.mounted) return;
    
    // Get the language name for the snackbar message
    final locales = LocaleService.getSupportedLocales();
    final localeInfo = locales.firstWhere(
      (info) => info.locale.languageCode == newLocale.languageCode,
      orElse: () => locales.first,
    );
    
    print('📢 Showing snackbar for: ${localeInfo.nativeName}');
    
    // Show snackbar with restart button
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.languageChangedRestarting(localeInfo.nativeName),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: tPrimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Wait a moment then restart automatically
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (context.mounted) {
      print('🔄 Restarting app...');
      AppRestartWidget.restartApp(context);
    }
  }
}
