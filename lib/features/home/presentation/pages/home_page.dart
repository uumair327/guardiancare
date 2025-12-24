import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/consent/consent.dart';
import 'package:guardiancare/features/home/home.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  duration: AppDurations.snackbarMedium,
                  action: SnackBarAction(
                    label: l10n.retry,
                    textColor: AppColors.white,
                    onPressed: () {
                      context.read<HomeBloc>().add(const RefreshCarouselItems());
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const RefreshCarouselItems());
                await Future.delayed(AppDurations.animationMedium);
              },
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // Welcome Header
                  SliverToBoxAdapter(
                    child: WelcomeHeader(),
                  ),
                  
                  // Carousel Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: AppDimensions.spaceM),
                      child: const HomeCarouselWidget(),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceL),
                  ),
                  
                  // Quick Actions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPaddingH,
                      ),
                      child: Text(
                        l10n.quickActions,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceM),
                  ),
                  
                  // Action Grid
                  SliverToBoxAdapter(
                    child: ActionGrid(
                      onQuizTap: () => context.push('/quiz'),
                      onLearnTap: () => context.push('/video'),
                      onEmergencyTap: () => context.push('/emergency'),
                      onProfileTap: () {
                        showParentalVerification(
                          context,
                          l10n.profile,
                          () => context.push('/account'),
                          onForgotKey: () => _handleForgotKey(context),
                        );
                      },
                      onWebsiteTap: () => context.push(
                        '/webview',
                        extra: AppStrings.websiteUrl,
                      ),
                      onMailTap: () {
                          showParentalVerification(
                            context,
                            l10n.mailUs,
                            () => _launchEmail(context),
                            onForgotKey: () => _handleForgotKey(context),
                          );
                      },
                    ),
                  ),
                  
                  // Bottom spacing for navigation bar
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceXXL),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleForgotKey(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ForgotParentalKeyDialog(),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can now use your new parental key'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: AppStrings.supportEmail,
      queryParameters: {
        'subject': AppStrings.emailSubject,
      },
    );

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.errorEmailClient),
            duration: AppDurations.snackbarMedium,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching email: $e'),
            duration: AppDurations.snackbarMedium,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

