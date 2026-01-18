import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/consent/consent.dart';
import 'package:guardiancare/features/forum/forum.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Forum page with inline parental lock protection
/// Follows SRP - handles page structure and parental verification
class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage>
    with SingleTickerProviderStateMixin {
  bool _isUnlocked = false;
  bool _hasSeenGuidelines = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    _checkGuidelines();
  }

  Future<void> _checkGuidelines() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenGuidelines = prefs.getBool('has_seen_forum_guidelines') ?? false;

    if (!_hasSeenGuidelines && mounted) {
      await Future.delayed(AppDurations.animationMedium);
      if (mounted) {
        _showGuidelinesDialog();
        await prefs.setBool('has_seen_forum_guidelines', true);
        setState(() => _hasSeenGuidelines = true);
      }
    }
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

  void _showGuidelinesDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusL,
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.videoPrimarySubtle10,
                  borderRadius: AppDimensions.borderRadiusS,
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  color: AppColors.videoPrimary,
                  size: AppDimensions.iconM,
                ),
              ),
              SizedBox(width: AppDimensions.spaceS),
              Text(l10n.guidelinesTitle, style: AppTextStyles.dialogTitle),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.guidelinesWelcome,
                  style: AppTextStyles.body2,
                ),
                SizedBox(height: AppDimensions.spaceM),
                _buildGuidelineItem(
                  Icons.favorite_rounded,
                  l10n.guidelineRespect,
                  AppColors.error,
                ),
                _buildGuidelineItem(
                  Icons.block_rounded,
                  l10n.guidelineNoAbuse,
                  AppColors.warning,
                ),
                _buildGuidelineItem(
                  Icons.shield_rounded,
                  l10n.guidelineNoHarmful,
                  AppColors.videoPrimary,
                ),
                _buildGuidelineItem(
                  Icons.chat_rounded,
                  l10n.guidelineConstructive,
                  AppColors.success,
                ),
              ],
            ),
          ),
          actions: [
            ScaleTapWidget(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceS,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.videoGradient,
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: Text(UIStrings.iAgree, style: AppTextStyles.button),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuidelineItem(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: ParentalLockOverlay(
        onUnlocked: _onUnlocked,
        onForgotKey: _handleForgotKey,
        child: _isUnlocked
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: const _ForumContent(),
              )
            : const _ForumPlaceholder(),
      ),
    );
  }
}

/// Placeholder content shown behind the blur when locked
class _ForumPlaceholder extends StatelessWidget {
  const _ForumPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header placeholder
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.videoPrimarySubtle30,
                AppColors.videoPrimarySubtle20,
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppDimensions.radiusXL),
              bottomRight: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
        ),
        // Content placeholder
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(AppDimensions.screenPaddingH),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
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

/// Forum content with modern header and tabs
class _ForumContent extends StatefulWidget {
  const _ForumContent();

  @override
  State<_ForumContent> createState() => _ForumContentState();
}

class _ForumContentState extends State<_ForumContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();
      final category = _tabController.index == 0
          ? ForumCategory.parent
          : ForumCategory.children;
      context.read<ForumBloc>().add(LoadForums(category));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load initial forums
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ForumBloc>().state is ForumInitial) {
        context.read<ForumBloc>().add(LoadForums(ForumCategory.parent));
      }
    });

    return Column(
      children: [
        _ForumHeader(tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _ForumListView(category: ForumCategory.parent),
              _ForumListView(category: ForumCategory.children),
            ],
          ),
        ),
      ],
    );
  }
}

/// Modern forum header with gradient and tabs
class _ForumHeader extends StatefulWidget {
  final TabController tabController;

  const _ForumHeader({required this.tabController});

  @override
  State<_ForumHeader> createState() => _ForumHeaderState();
}

class _ForumHeaderState extends State<_ForumHeader>
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
              AppColors.videoPrimary,
              AppColors.videoPrimarySubtle50.withValues(alpha: 0.85),
              AppColors.videoPrimaryDark,
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
                              l10n.forum,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppDimensions.spaceXS),
                            Text(
                              l10n.connectAndShare,
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
                          Icons.forum_rounded,
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
                    labelColor: AppColors.videoPrimary,
                    unselectedLabelColor:
                        AppColors.white.withValues(alpha: 0.8),
                    labelStyle: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: AppTextStyles.caption,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.family_restroom_rounded, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  l10n.parentForums,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.child_care_rounded, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  l10n.forChildren,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
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

/// Forum list view for each category
class _ForumListView extends StatelessWidget {
  final ForumCategory category;

  const _ForumListView({required this.category});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ForumBloc, ForumState>(
      listener: (context, state) {
        if (state is ForumError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: AppDurations.snackbarMedium,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusS,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ForumLoading) {
          return _buildLoadingState();
        }

        if (state is ForumsLoaded) {
          if (state.category != category) {
            return _buildLoadingState();
          }

          if (state.forums.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              context.read<ForumBloc>().add(RefreshForums(category));
              await Future.delayed(AppDurations.animationMedium);
            },
            color: AppColors.videoPrimary,
            child: ListView.builder(
              itemCount: state.forums.length,
              padding: EdgeInsets.all(AppDimensions.screenPaddingH),
              itemBuilder: (context, index) {
                return FadeSlideWidget(
                  duration: AppDurations.animationMedium,
                  delay: Duration(milliseconds: 50 * index),
                  direction: SlideDirection.up,
                  slideOffset: 20,
                  child: ForumListItem(
                    forum: state.forums[index],
                    index: index,
                  ),
                );
              },
            ),
          );
        }

        if (state is ForumError) {
          return _buildErrorState(context, l10n, state.message);
        }

        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(AppDimensions.screenPaddingH),
      itemBuilder: (context, index) {
        return FadeSlideWidget(
          duration: AppDurations.animationShort,
          delay: Duration(milliseconds: 50 * index),
          child: Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spaceM),
            child: ShimmerLoading(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return FadeSlideWidget(
      duration: AppDurations.animationMedium,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                color: AppColors.videoPrimarySubtle10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: AppDimensions.iconXXL,
                color: AppColors.videoPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noForumsAvailable,
              style:
                  AppTextStyles.h4.copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              l10n.beFirstToDiscuss,
              style: AppTextStyles.body2
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return FadeSlideWidget(
      duration: AppDurations.animationMedium,
      child: Center(
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
              l10n.somethingWentWrong,
              style:
                  AppTextStyles.h4.copyWith(color: context.colors.textPrimary),
            ),
            SizedBox(height: AppDimensions.spaceS),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceXL),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body2
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            ScaleTapWidget(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<ForumBloc>().add(LoadForums(category));
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceL,
                  vertical: AppDimensions.spaceM,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.videoGradient,
                  borderRadius: AppDimensions.borderRadiusM,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.videoPrimarySubtle30,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: AppColors.white,
                      size: AppDimensions.iconS,
                    ),
                    SizedBox(width: AppDimensions.spaceS),
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
}
