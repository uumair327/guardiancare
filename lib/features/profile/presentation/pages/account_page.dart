import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/core/di/di.dart' as di;
import 'package:guardiancare/features/consent/consent.dart';
import 'package:guardiancare/features/profile/profile.dart';
import 'package:guardiancare/main.dart' show Guardiancare;

/// Account page with inline parental lock protection
/// Uses the same modern UI pattern as ForumPage
/// Account page with inline parental lock protection
/// Uses the same modern UI pattern as ForumPage
///
/// Following: DIP (Dependency Inversion Principle) - uses BackendUser abstraction
class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.backendUser});

  /// The BackendUser to display (backend-agnostic)
  final BackendUser? backendUser;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SingleTickerProviderStateMixin {
  bool _isUnlocked = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onUnlocked() {
    setState(() => _isUnlocked = true);
    _fadeController.forward();
  }

  Future<void> _handleForgotKey() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ForgotParentalKeyDialog(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(FeedbackStrings.newParentalKeyReady),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusS,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle no user case without parental lock
    if (widget.backendUser == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        appBar: _buildAppBar(context),
        body: _buildNoUserScreen(context),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: _buildAppBar(context),
      body: ParentalLockOverlay(
        onUnlocked: _onUnlocked,
        onForgotKey: _handleForgotKey,
        child: _isUnlocked
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: _AccountContent(user: widget.backendUser!),
              )
            : const _AccountPlaceholder(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.colors.background,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
        onPressed: () {
          HapticFeedback.lightImpact();
          context.pop();
        },
      ),
      title: Text(
        l10n.profile,
        style: AppTextStyles.h4.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildNoUserScreen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FadeSlideWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_rounded,
                size: AppDimensions.iconXXL,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noUserSignedIn,
              style: AppTextStyles.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            ScaleTapWidget(
              onTap: () => context.go('/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Text(
                  UIStrings.signIn,
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder content shown behind the blur when locked
class _AccountPlaceholder extends StatelessWidget {
  const _AccountPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header placeholder
        Container(
          height: 200,
          margin: const EdgeInsets.all(AppDimensions.screenPaddingH),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: AppDimensions.borderRadiusXL,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        // Content placeholder
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBase,
                    borderRadius: AppDimensions.borderRadiusL,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Account content widget - shown after parental verification
/// Uses BackendUser for backend-agnostic user representation
class _AccountContent extends StatelessWidget {
  const _AccountContent({required this.user});
  final BackendUser user;

  Future<void> _confirmAndDeleteAccount(
      BuildContext context, ProfileBloc profileBloc) async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const _DeleteAccountDialog(),
    );

    if (result != null) {
      final String? password = result.isEmpty ? null : result;
      profileBloc.add(DeleteAccountRequested(user.id, password: password));
    }
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            final dialogL10n = AppLocalizations.of(dialogContext);
            return AlertDialog(
              backgroundColor: context.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
              ),
              title: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spaceS),
                  Text(
                    l10n.logout,
                    style: AppTextStyles.dialogTitle.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Text(
                l10n.logoutConfirm,
                style: AppTextStyles.body2.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    dialogL10n.cancel,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    dialogL10n.logout,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldLogout && context.mounted) {
      context.read<ProfileBloc>().add(const LogoutRequested());
    }
  }

  void _onLanguageSelected(BuildContext context, Locale newLocale) {
    context.read<ProfileBloc>().add(ChangeLanguageRequested(newLocale));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ProfileBloc>()..add(LoadProfile(user.id)),
        ),
        BlocProvider(
          create: (context) => sl<UserStatsCubit>()..loadStats(user.id),
        ),
      ],
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: _handleStateChanges,
        builder: _buildContent,
      ),
    );
  }

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
      context.go('/login');
    } else if (state is LanguageChanged) {
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

  void _applyLanguageChange(BuildContext context, LanguageChanged state) {
    final rootState = Guardiancare.of(context);
    rootState?.changeLocale(state.newLocale);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.white, size: 20),
            const SizedBox(width: AppDimensions.spaceS),
            Text(
              state.localeName,
              style: AppTextStyles.body2.copyWith(color: AppColors.onPrimary),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
      ),
    );

    if (context.mounted) {
      context.go('/');
    }
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    if (state is ProfileLoading ||
        state is AccountDeleting ||
        state is LoggingOut ||
        state is LanguageChanging) {
      return _buildLoadingState();
    }

    if (state is ProfileError && state is! AccountDeleting) {
      return _buildErrorState(context, state.message);
    }

    if (state is ProfileLoaded) {
      return _buildProfileContent(context, state.profile);
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        ShimmerLoading(
          child: Container(
            height: 200,
            margin: const EdgeInsets.all(AppDimensions.screenPaddingH),
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: AppDimensions.borderRadiusXL,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceL),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPaddingH),
          child: Column(
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                child: ShimmerLoading(
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.shimmerBase,
                      borderRadius: AppDimensions.borderRadiusM,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    return FadeSlideWidget(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: AppDimensions.iconXXL,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              UIStrings.oopsSomethingWentWrong,
              style: AppTextStyles.h4.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXL),
              child: Text(
                message,
                style: AppTextStyles.body2.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            ScaleTapWidget(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<ProfileBloc>().add(LoadProfile(user.id));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8)
                    ],
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: AppColors.white, size: AppDimensions.iconS),
                    const SizedBox(width: AppDimensions.spaceS),
                    Text(l10n.retry, style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileEntity profile) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with proper horizontal margin
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPaddingH),
            child: ProfileHeader(profile: profile),
          ),
          const SizedBox(height: AppDimensions.spaceL),

          // TODO: Stats cards temporarily disabled - uncomment when stats tracking is fully implemented
          // _buildStatsRow(context),
          // SizedBox(height: AppDimensions.spaceL),

          FadeSlideWidget(
            delay: const Duration(milliseconds: 100),
            child: ProfileSection(
              title: l10n.childSafetySettings,
              icon: Icons.shield_rounded,
              children: [
                ProfileMenuItem(
                  icon: Icons.phone_rounded,
                  title: l10n.emergencyContact,
                  subtitle: UIStrings.setUpEmergencyContacts,
                  iconColor: AppColors.error,
                  onTap: () => context.push('/emergency'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          FadeSlideWidget(
            delay: const Duration(milliseconds: 200),
            child: ProfileSection(
              title: l10n.settings,
              icon: Icons.settings_rounded,
              children: [
                ProfileMenuItem(
                  icon: Icons.language_rounded,
                  title: l10n.language,
                  subtitle: _getCurrentLanguageName(context),
                  onTap: () {
                    final currentLocale = Localizations.localeOf(context);
                    LanguageSelectorDialog.show(
                      context,
                      currentLocale: currentLocale,
                      onLocaleSelected: (newLocale) =>
                          _onLanguageSelected(context, newLocale),
                    );
                  },
                ),
                _buildThemeToggleItem(context),
                ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  title: l10n.logout,
                  subtitle: UIStrings.signOutOfYourAccount,
                  showArrow: false,
                  onTap: () => _confirmAndLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          FadeSlideWidget(
            delay: const Duration(milliseconds: 300),
            child: ProfileSection(
              title: UIStrings.dangerZone,
              icon: Icons.warning_rounded,
              children: [
                ProfileMenuItem(
                  icon: Icons.delete_forever_rounded,
                  title: l10n.deleteMyAccount,
                  subtitle: UIStrings.permanentlyDeleteAccount,
                  isDanger: true,
                  showArrow: false,
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
          const SizedBox(height: AppDimensions.spaceXL),
        ],
      ),
    );
  }

  /// Build theme toggle menu item
  Widget _buildThemeToggleItem(BuildContext context) {
    final themeManager = di.sl<ThemeManager>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return ProfileMenuItem(
      icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      title: l10n.language.contains('Theme') ? l10n.language : 'Theme Mode',
      subtitle: isDark ? 'Dark mode enabled' : 'Light mode enabled',
      showArrow: false,
      trailing: Switch.adaptive(
        value: isDark,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          themeManager.changeTheme(
            value ? ThemeMode.dark : ThemeMode.light,
          );
        },
        thumbColor:
            WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        themeManager.toggleTheme();
      },
    );
  }

  // TODO: Stats row temporarily disabled - uncomment when stats tracking is fully implemented
  // Widget _buildStatsRow(BuildContext context) {
  //   return FadeSlideWidget(
  //     delay: const Duration(milliseconds: 50),
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
  //       child: BlocBuilder<UserStatsCubit, UserStatsState>(
  //         builder: (context, state) {
  //           final stats = state is UserStatsLoaded ? state.stats : null;
  //           final isLoading = state is UserStatsLoading;
  //
  //           return Row(
  //             children: [
  //               Expanded(
  //                 child: ProfileStatCard(
  //                   icon: Icons.quiz_rounded,
  //                   label: UIStrings.quizzes,
  //                   value: isLoading ? '-' : '${stats?.quizzesCompleted ?? 0}',
  //                   index: 0,
  //                 ),
  //               ),
  //               SizedBox(width: AppDimensions.spaceM),
  //               Expanded(
  //                 child: ProfileStatCard(
  //                   icon: Icons.play_circle_rounded,
  //                   label: UIStrings.videos,
  //                   value: isLoading ? '-' : '${stats?.videosCompleted ?? 0}',
  //                   index: 1,
  //                 ),
  //               ),
  //               SizedBox(width: AppDimensions.spaceM),
  //               Expanded(
  //                 child: ProfileStatCard(
  //                   icon: Icons.emoji_events_rounded,
  //                   label: UIStrings.badges,
  //                   value: isLoading ? '-' : '${stats?.badgesEarned ?? 0}',
  //                   index: 2,
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

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

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.error),
          const SizedBox(width: AppDimensions.spaceS),
          Text(
            l10n.deleteAccount,
            style: AppTextStyles.dialogTitle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deleteAccountConfirm,
            style: AppTextStyles.body2.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          TextField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: 'Password',
              helperText: 'Required for Email login. Leave empty for Google.',
              border: OutlineInputBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_passwordController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: Text(l10n.yes),
        ),
      ],
    );
  }
}
