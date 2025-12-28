import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/explore/explore.dart';

/// Modern, education-friendly Explore Page
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return BlocProvider(
      create: (context) {
        final dataSource = ExploreRemoteDataSourceImpl(
          firestore: FirebaseFirestore.instance,
        );
        final repository = ExploreRepositoryImpl(
          remoteDataSource: dataSource,
        );
        return ExploreCubit(
          getRecommendations: GetRecommendations(repository),
          getResources: GetResources(repository),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _ExploreHeader(tabController: _tabController),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _RecommendedTab(),
                  _ResourcesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Modern header with gradient and animated tabs
class _ExploreHeader extends StatefulWidget {
  final TabController tabController;

  const _ExploreHeader({required this.tabController});

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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
              const Color(0xFF10B981), // Emerald
              const Color(0xFF10B981).withValues(alpha: 0.85),
              const Color(0xFF059669), // Darker emerald
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.only(
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
                  padding: EdgeInsets.fromLTRB(
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
                            SizedBox(height: AppDimensions.spaceXS),
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
                        padding: EdgeInsets.all(AppDimensions.spaceM),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
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
                  margin: EdgeInsets.fromLTRB(
                    AppDimensions.screenPaddingH,
                    0,
                    AppDimensions.screenPaddingH,
                    AppDimensions.spaceM,
                  ),
                  padding: EdgeInsets.all(4),
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
                    labelColor: const Color(0xFF10B981),
                    unselectedLabelColor: AppColors.white.withValues(alpha: 0.8),
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
                            Icon(Icons.recommend_rounded, size: 16),
                            SizedBox(width: 4),
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
                            Icon(Icons.library_books_rounded, size: 16),
                            SizedBox(width: 4),
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
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);

    if (user == null) {
      return _buildLoginPrompt(context, l10n);
    }

    return RefreshIndicator(
      onRefresh: _refreshRecommendations,
      color: const Color(0xFF10B981),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recommendations')
            .where('UID', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(l10n, snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          // Remove duplicate videos
          final videoSet = <String>{};
          final videos = <QueryDocumentSnapshot>[];

          for (var video in snapshot.data!.docs) {
            final data = video.data() as Map<String, dynamic>;
            final videoUrl = data['video'] as String?;
            if (videoUrl != null &&
                videoUrl.isNotEmpty &&
                !videoSet.contains(videoUrl)) {
              videoSet.add(videoUrl);
              videos.add(video);
            }
          }

          if (videos.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final data = video.data() as Map<String, dynamic>;
              final delay = Duration(milliseconds: index * 100);

              return FadeSlideWidget(
                delay: delay,
                child: _RecommendedVideoCard(
                  title: data['title'] ?? 'Untitled',
                  thumbnail: data['thumbnail'] ?? '',
                  videoUrl: data['video'] ?? '',
                  index: index,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, AppLocalizations l10n) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: AppDimensions.iconXXL,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),
              Text(
                l10n.loginToViewRecommendations,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceM),
              ScaleTapWidget(
                onTap: () => context.go('/login'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXL,
                    vertical: AppDimensions.spaceM,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981),
                        const Color(0xFF10B981).withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: AppDimensions.borderRadiusM,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
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

  Widget _buildErrorState(AppLocalizations l10n, String error) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconXXL,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),
              Text(
                ErrorStrings.generic,
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                error,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
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
        padding: EdgeInsets.all(AppDimensions.spaceXL),
        children: [
          SizedBox(height: AppDimensions.spaceXXL),
          Center(
            child: Container(
              padding: EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: AppDimensions.iconXXL * 1.2,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceL),
          Text(
            l10n.noRecommendationsYet,
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceS),
          Text(
            l10n.takeQuizForRecommendations,
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceXL),
          Center(
            child: ScaleTapWidget(
              onTap: () => context.push('/quiz'),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981),
                      const Color(0xFF10B981).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: AppDimensions.borderRadiusM,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.quiz_rounded, color: AppColors.white, size: 20),
                    SizedBox(width: AppDimensions.spaceS),
                    Text(l10n.takeAQuiz, style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceL),
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
  final String title;
  final String thumbnail;
  final String videoUrl;
  final int index;

  const _RecommendedVideoCard({
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
    required this.index,
  });

  @override
  State<_RecommendedVideoCard> createState() => _RecommendedVideoCardState();
}

class _RecommendedVideoCardState extends State<_RecommendedVideoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const List<Color> _cardColors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
  ];

  Color get _accentColor => _cardColors[widget.index % _cardColors.length];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
      padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
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
              color: AppColors.surface,
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
                  borderRadius: BorderRadius.only(
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
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                _accentColor.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(AppDimensions.spaceS),
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
                    padding: EdgeInsets.all(AppDimensions.spaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
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
                        SizedBox(height: AppDimensions.spaceS),
                        Text(
                          widget.title,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
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
                  padding: EdgeInsets.only(right: AppDimensions.spaceM),
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

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('resources').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(l10n, snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(l10n);
        }

        final resources = snapshot.data!.docs;

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await Future.delayed(AppDurations.animationMedium);
          },
          color: const Color(0xFF10B981),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              final data = resource.data() as Map<String, dynamic>;
              final delay = Duration(milliseconds: index * 80);

              return FadeSlideWidget(
                delay: delay,
                child: _ResourceCard(
                  title: data['title'] ?? 'Untitled',
                  description: data['description'] ?? '',
                  category: data['category'] ?? '',
                  type: data['type'] ?? '',
                  url: data['url'] ?? '',
                  index: index,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
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

  Widget _buildErrorState(AppLocalizations l10n, String error) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: AppDimensions.iconXXL,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),
              Text(
                ErrorStrings.failedTo('load resources'),
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return FadeSlideWidget(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_books_outlined,
                  size: AppDimensions.iconXXL * 1.2,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(height: AppDimensions.spaceL),
              Text(
                l10n.noResourcesAvailable,
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
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
  final String title;
  final String description;
  final String category;
  final String type;
  final String url;
  final int index;

  const _ResourceCard({
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.url,
    required this.index,
  });

  @override
  State<_ResourceCard> createState() => _ResourceCardState();
}

class _ResourceCardState extends State<_ResourceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static final List<Color> _typeColors = [
    const Color(0xFF6366F1),
    const Color(0xFFEC4899),
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFF10B981),
  ];

  Color get _typeColor {
    final colors = {
      'article': const Color(0xFF6366F1),
      'video': const Color(0xFFEC4899),
      'pdf': const Color(0xFFEF4444),
      'link': const Color(0xFF3B82F6),
      'guide': const Color(0xFF10B981),
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.tap),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
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
      padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
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
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.borderRadiusL,
              border: Border.all(
                color: _typeColor.withValues(alpha: 0.2),
                width: 1,
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
                  padding: EdgeInsets.all(AppDimensions.spaceM),
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
                SizedBox(width: AppDimensions.spaceM),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.category.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
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
                        SizedBox(height: AppDimensions.spaceS),
                      ],
                      Text(
                        widget.title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.description.isNotEmpty) ...[
                        SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          widget.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
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
