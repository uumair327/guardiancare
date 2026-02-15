import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/explore/explore.dart';

/// Modern, education-friendly Explore Page
class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
    this.onNavigateToHome,
    this.onNavigateToForum,
  });

  final VoidCallback? onNavigateToHome;
  final VoidCallback? onNavigateToForum;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          _ExploreHeader(tabController: _tabController),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Only handle horizontal swipes from the TabBarView itself (depth 0)
                // This prevents nested horizontal lists from triggering page navigation
                if (notification.depth != 0 ||
                    notification.metrics.axis != Axis.horizontal) {
                  return false;
                }

                // Reset navigation flag when scroll ends
                if (notification is ScrollEndNotification) {
                  _isNavigating = false;
                  return false;
                }

                // Prevent multiple triggers
                if (_isNavigating) return false;

                // Handle Bouncing Scroll Physics (iOS style)
                if (notification is ScrollUpdateNotification &&
                    notification.dragDetails != null) {
                  // Swipe Right at Start (to Home)
                  if (notification.metrics.pixels <
                          notification.metrics.minScrollExtent &&
                      _tabController.index == 0) {
                    _isNavigating = true;
                    widget.onNavigateToHome?.call();
                    return true;
                  }

                  // Swipe Left at End (to Forum)
                  if (notification.metrics.pixels >
                          notification.metrics.maxScrollExtent &&
                      _tabController.index == 1) {
                    _isNavigating = true;
                    widget.onNavigateToForum?.call();
                    return true;
                  }
                }

                // Handle Clamping Scroll Physics (Android style)
                if (notification is OverscrollNotification &&
                    notification.dragDetails != null) {
                  // Swipe Right at Start (to Home)
                  if (notification.overscroll < 0 &&
                      _tabController.index == 0) {
                    _isNavigating = true;
                    widget.onNavigateToHome?.call();
                    return true;
                  }

                  // Swipe Left at End (to Forum)
                  if (notification.overscroll > 0 &&
                      _tabController.index == 1) {
                    _isNavigating = true;
                    widget.onNavigateToForum?.call();
                    return true;
                  }
                }

                return false;
              },
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: const [
                  _RecommendedTab(),
                  _ResourcesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern header with gradient and animated tabs
class _ExploreHeader extends StatefulWidget {
  const _ExploreHeader({required this.tabController});
  final TabController tabController;

  @override
  State<_ExploreHeader> createState() => _ExploreHeaderState();
}

class _ExploreHeaderState extends State<_ExploreHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationLong,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardEmerald,
              AppColors.cardEmerald.withValues(alpha: 0.85),
              AppColors.successDark,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppDimensions.radiusXL),
            bottomRight: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: _slideAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    AppDimensions.spaceM,
                    AppDimensions.screenPaddingH,
                    AppDimensions.spaceM,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.explore,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceXS),
                            Text(
                              UIStrings.discoverLearningResources,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spaceM),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: AppColors.white,
                          size: AppDimensions.iconL,
                        ),
                      ),
                    ],
                  ),
                ),
                // Modern Tab Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    0,
                    AppDimensions.screenPaddingH,
                    AppDimensions.spaceM,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: AppDimensions.borderRadiusL,
                  ),
                  child: TabBar(
                    controller: widget.tabController,
                    indicator: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppDimensions.borderRadiusM,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.cardEmerald,
                    unselectedLabelColor:
                        AppColors.white.withValues(alpha: 0.8),
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: AppTextStyles.bodySmall,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.recommend_rounded, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.recommendedForYou,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.library_books_rounded, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                l10n.resources,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Recommended videos tab with modern design
class _RecommendedTab extends StatefulWidget {
  const _RecommendedTab();

  @override
  State<_RecommendedTab> createState() => _RecommendedTabState();
}

class _RecommendedTabState extends State<_RecommendedTab> {
  Future<void> _refreshRecommendations() async {
    HapticFeedback.lightImpact();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<IAuthService>().currentUser;
    final l10n = AppLocalizations.of(context);

    if (user == null) {
      return _buildLoginPrompt(context, l10n);
    }

    return RefreshIndicator(
      onRefresh: _refreshRecommendations,
      color: AppColors.cardEmerald,
      child: StreamBuilder<dartz.Either<Failure, List<Recommendation>>>(
        stream: sl<GetRecommendations>()(user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(context, l10n, snapshot.error.toString());
          }

          if (snapshot.hasData) {
            return snapshot.data!.fold(
              (failure) => _buildErrorState(context, l10n, failure.message),
              (recommendations) {
                if (recommendations.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                // Remove duplicate videos
                final videoSet = <String>{};
                final videos = <Recommendation>[];

                for (final rec in recommendations) {
                  final videoUrl = rec.videoUrl;
                  if (videoUrl != null &&
                      videoUrl.isNotEmpty &&
                      !videoSet.contains(videoUrl)) {
                    videoSet.add(videoUrl);
                    videos.add(rec);
                  }
                }

                if (videos.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    AppDimensions.screenPaddingH,
                    AppDimensions.screenPaddingH,
                    100,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final delay = Duration(milliseconds: index * 100);

                    return FadeSlideWidget(
                      delay: delay,
                      child: _RecommendedVideoCard(
                        title: video.title,
                        thumbnail: video.thumbnail ?? '',
                        videoUrl: video.videoUrl ?? '',
                        index: index,
                      ),
                    );
                  },
                );
              },
            );
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, AppLocalizations l10n) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: AppColors.cardEmerald.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: AppDimensions.iconXXL,
                  color: AppColors.cardEmerald,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),
              Text(
                l10n.loginToViewRecommendations,
                style: AppTextStyles.h4.copyWith(
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
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
                        AppColors.cardEmerald,
                        AppColors.cardEmerald.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: AppDimensions.borderRadiusM,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardEmerald.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
          child: ShimmerLoading(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppDimensions.borderRadiusL,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
      BuildContext context, AppLocalizations l10n, String error) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceL),
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
                ErrorStrings.generic,
                style: AppTextStyles.h4
                    .copyWith(color: context.colors.textPrimary),
              ),
              const SizedBox(height: AppDimensions.spaceS),
              Text(
                error,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return FadeSlideWidget(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        children: [
          const SizedBox(height: AppDimensions.spaceXXL),
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: AppColors.cardEmerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_library_outlined,
                size: AppDimensions.iconXXL * 1.2,
                color: AppColors.cardEmerald,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          Text(
            l10n.noRecommendationsYet,
            style: AppTextStyles.h3.copyWith(color: context.colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            l10n.takeQuizForRecommendations,
            style: AppTextStyles.body2
                .copyWith(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceXL),
          Center(
            child: ScaleTapWidget(
              onTap: () => context.push('/quiz'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.cardEmerald,
                      AppColors.cardEmerald.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardEmerald.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.quiz_rounded,
                        color: AppColors.white, size: 20),
                    const SizedBox(width: AppDimensions.spaceS),
                    Text(l10n.takeAQuiz, style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          Text(
            l10n.pullDownToRefresh,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Modern recommended video card
class _RecommendedVideoCard extends StatefulWidget {
  const _RecommendedVideoCard({
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    required this.index,
  });
  final String title;
  final String thumbnail;
  final String videoUrl;
  final int index;

  @override
  State<_RecommendedVideoCard> createState() => _RecommendedVideoCardState();
}

class _RecommendedVideoCardState extends State<_RecommendedVideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Color get _accentColor =>
      AppColors.cardPalette[widget.index % AppColors.cardPalette.length];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/video-player', extra: widget.videoUrl);
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppDimensions.borderRadiusL,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusL),
                    bottomLeft: Radius.circular(AppDimensions.radiusL),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.thumbnail.isNotEmpty
                            ? Image.network(
                                widget.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildThumbnailPlaceholder(),
                              )
                            : _buildThumbnailPlaceholder(),
                        // Play overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _accentColor.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppDimensions.spaceS),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: _accentColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.1),
                            borderRadius: AppDimensions.borderRadiusXS,
                          ),
                          child: Text(
                            UIStrings.recommended,
                            style: AppTextStyles.caption.copyWith(
                              color: _accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceS),
                        Text(
                          widget.title,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Arrow
                Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spaceM),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: _accentColor.withValues(alpha: 0.2),
      child: Center(
        child: Icon(
          Icons.video_library_rounded,
          color: _accentColor,
          size: 32,
        ),
      ),
    );
  }
}

/// Resources tab with modern design
class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<dartz.Either<Failure, List<Resource>>>(
      stream: sl<GetResources>()(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, l10n, snapshot.error.toString());
        }

        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (failure) => _buildErrorState(context, l10n, failure.message),
            (resources) {
              if (resources.isEmpty) return _buildEmptyState(context, l10n);

              return RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  await Future.delayed(AppDurations.animationMedium);
                },
                color: AppColors.cardEmerald,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    AppDimensions.screenPaddingH,
                    AppDimensions.screenPaddingH,
                    100,
                  ),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    final delay = Duration(milliseconds: index * 80);

                    return FadeSlideWidget(
                      delay: delay,
                      child: _ResourceCard(
                        title: resource.title,
                        description: resource.description ?? '',
                        category: resource.category ?? '',
                        type: resource.type ?? '',
                        url: resource.url ?? '',
                        index: index,
                        content: resource.content,
                      ),
                    );
                  },
                ),
              );
            },
          );
        }

        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
          child: ShimmerLoading(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: AppDimensions.borderRadiusL,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
      BuildContext context, AppLocalizations l10n, String error) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceL),
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
                ErrorStrings.failedTo('load resources'),
                style: AppTextStyles.h4
                    .copyWith(color: context.colors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: AppColors.cardEmerald.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.library_books_outlined,
                  size: AppDimensions.iconXXL * 1.2,
                  color: AppColors.cardEmerald,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),
              Text(
                l10n.noResourcesAvailable,
                style: AppTextStyles.h4
                    .copyWith(color: context.colors.textPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modern resource card
class _ResourceCard extends StatefulWidget {
  const _ResourceCard({
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.url,
    required this.index,
    this.content,
  });
  final String title;
  final String description;
  final String category;
  final String type;
  final String url;
  final int index;
  final Map<String, dynamic>? content;

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const List<Color> _typeColors = [
    AppColors.cardIndigo,
    AppColors.cardPink,
    AppColors.cardRed,
    AppColors.cardBlue,
    AppColors.cardEmerald,
  ];

  Color get _typeColor {
    const colors = {
      'article': AppColors.cardIndigo,
      'video': AppColors.cardPink,
      'pdf': AppColors.cardRed,
      'link': AppColors.cardBlue,
      'guide': AppColors.cardEmerald,
    };
    return colors[widget.type.toLowerCase()] ??
        _typeColors[widget.index % _typeColors.length];
  }

  IconData get _typeIcon {
    switch (widget.type.toLowerCase()) {
      case 'article':
        return Icons.article_rounded;
      case 'video':
        return Icons.play_circle_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'link':
      case 'website':
        return Icons.link_rounded;
      case 'guide':
        return Icons.menu_book_rounded;
      default:
        return Icons.library_books_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    HapticFeedback.lightImpact();

    if (widget.type.toLowerCase() == 'custom' && widget.content != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomContentPage(content: widget.content!),
        ),
      );
      return;
    }

    if (widget.url.isEmpty) return;

    if (widget.type.toLowerCase() == 'pdf') {
      context.push('/pdf-viewer', extra: {
        'url': widget.url,
        'title': widget.title,
      });
    } else {
      context.push('/webview', extra: widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppDimensions.borderRadiusL,
              border: Border.all(
                color: _typeColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: _typeColor.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceM),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.1),
                    borderRadius: AppDimensions.borderRadiusM,
                  ),
                  child: Icon(
                    _typeIcon,
                    color: _typeColor,
                    size: AppDimensions.iconL,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.category.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _typeColor.withValues(alpha: 0.1),
                            borderRadius: AppDimensions.borderRadiusXS,
                          ),
                          child: Text(
                            widget.category,
                            style: AppTextStyles.caption.copyWith(
                              color: _typeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spaceS),
                      ],
                      Text(
                        widget.title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.description.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          widget.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: _typeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
