import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/consent/consent.dart';
import 'package:guardiancare/features/home/home.dart';
import 'package:url_launcher/url_launcher.dart';

/// Home Page with animations and 3D effects
///
/// Features:
/// - Animated welcome header
/// - Staggered action grid animations
/// - 3D card effects
/// - Smooth page transitions
/// - Performance optimized
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
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusS,
                  ),
                  action: SnackBarAction(
                    label: l10n.retry,
                    textColor: AppColors.white,
                    onPressed: () {
                      context
                          .read<HomeBloc>()
                          .add(const RefreshCarouselItems());
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
              backgroundColor: context.colors.surface,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Welcome Header with animations
                  const SliverToBoxAdapter(
                    child: WelcomeHeader(),
                  ),

                  // Carousel Section with fade-in
                  const SliverToBoxAdapter(
                    child: FadeSlideWidget(
                      delay: Duration(milliseconds: 200),
                      child: Padding(
                        padding: EdgeInsets.only(top: AppDimensions.spaceM),
                        child: HomeCarousel(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceL),
                  ),

                  // Quick Actions Section Header
                  SliverToBoxAdapter(
                    child: FadeSlideWidget(
                      delay: const Duration(milliseconds: 300),
                      direction: SlideDirection.left,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.screenPaddingH,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spaceS),
                            Expanded(
                              child: Text(
                                l10n.quickActions,
                                style: AppTextStyles.h3.copyWith(
                                  color: context.colors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceM),
                  ),

                  // Action Grid with staggered animations
                  SliverToBoxAdapter(
                    child: ActionGrid(
                      onQuizTap: () => context.push('/quiz'),
                      onLearnTap: () => context.push('/video'),
                      onEmergencyTap: () => context.push('/emergency'),
                      onProfileTap: () => context.push('/account'),
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
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spaceXXL * 2),
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
            content: const Text(ErrorStrings.emailClientError),
            duration: AppDurations.snackbarMedium,
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusS,
            ),
          ),
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FeedbackStrings.launchError('email: $e')),
            duration: AppDurations.snackbarMedium,
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusS,
            ),
          ),
        );
      }
    }
  }
}
