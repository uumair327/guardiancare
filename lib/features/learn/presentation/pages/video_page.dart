import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_bloc.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_event.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_state.dart';
import 'package:guardiancare/features/learn/presentation/widgets/widgets.dart';

/// VideoPage - Modern, education-friendly learning page
/// 
/// Features:
/// - Animated header with gradient
/// - Category cards with 3D effects
/// - Video cards with play overlay
/// - Staggered animations
/// - Shimmer loading states
class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LearnBloc>()..add(CategoriesRequested()),
      child: const _VideoPageContent(),
    );
  }
}

class _VideoPageContent extends StatelessWidget {
  const _VideoPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearnBloc, LearnState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // Modern header
              LearnHeader(
                categoryName: _getCategoryName(state),
                onBackPressed: _getCategoryName(state) != null
                    ? () => context.read<LearnBloc>().add(BackToCategories())
                    : null,
              ),
              // Content
              Expanded(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _getCategoryName(LearnState state) {
    if (state is VideosLoaded) return state.categoryName;
    if (state is VideosLoading) return state.categoryName;
    return null;
  }

  Widget _buildBody(BuildContext context, LearnState state) {
    final l10n = AppLocalizations.of(context);

    if (state is LearnInitial || state is LearnLoading) {
      return _buildCategoryLoadingState();
    }

    if (state is LearnError) {
      return _buildErrorView(context, state, l10n);
    }

    if (state is CategoriesLoaded) {
      return _CategoryGridView(categories: state.categories);
    }

    if (state is VideosLoading) {
      return _buildVideoLoadingState();
    }

    if (state is VideosLoaded) {
      return _VideoGridView(
        categoryName: state.categoryName,
        videos: state.videos,
      );
    }

    return _buildCategoryLoadingState();
  }

  Widget _buildCategoryLoadingState() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceM,
          mainAxisSpacing: AppDimensions.spaceM,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return FadeSlideWidget(
            duration: AppDurations.animationShort,
            delay: Duration(milliseconds: 50 * index),
            child: ShimmerLoading(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoLoadingState() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceM,
          mainAxisSpacing: AppDimensions.spaceM,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return FadeSlideWidget(
            duration: AppDurations.animationShort,
            delay: Duration(milliseconds: 50 * index),
            child: ShimmerLoading(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.shimmerBase,
                  borderRadius: AppDimensions.borderRadiusL,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, LearnError state, AppLocalizations l10n) {
    return FadeSlideWidget(
      duration: AppDurations.animationMedium,
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
                UIStrings.oopsSomethingWentWrong,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                state.message,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.canRetry) ...[
                SizedBox(height: AppDimensions.spaceL),
                ScaleTapWidget(
                  onTap: () {
                    context.read<LearnBloc>().add(RetryRequested());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceXL,
                      vertical: AppDimensions.spaceM,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppDimensions.borderRadiusM,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
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
                          size: AppDimensions.iconM,
                        ),
                        SizedBox(width: AppDimensions.spaceS),
                        Text(
                          l10n.retry,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Category grid view with staggered animations
class _CategoryGridView extends StatelessWidget {
  final List<CategoryEntity> categories;

  const _CategoryGridView({required this.categories});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (categories.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Section header
        SliverToBoxAdapter(
          child: FadeSlideWidget(
            duration: AppDurations.animationMedium,
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spaceM,
                AppDimensions.spaceL,
                AppDimensions.spaceM,
                AppDimensions.spaceM,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceS),
                  Text(
                    UIStrings.learningCategories,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
                      vertical: AppDimensions.spaceXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                    child: Text(
                      '${categories.length} ${UIStrings.topics}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Category grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spaceM,
              mainAxisSpacing: AppDimensions.spaceM,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                final row = index ~/ 2;
                final col = index % 2;
                final staggerIndex = row + col;

                return FadeSlideWidget(
                  duration: AppDurations.animationMedium,
                  delay: Duration(milliseconds: 100 + (80 * staggerIndex)),
                  direction: SlideDirection.up,
                  slideOffset: 30,
                  child: CategoryCard(
                    category: category,
                    index: index,
                    onTap: () {
                      context.read<LearnBloc>().add(CategorySelected(category.name));
                    },
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.spaceXXL),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return FadeSlideWidget(
      duration: AppDurations.animationMedium,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceL),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: AppDimensions.iconXXL,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noCategoriesAvailable,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              UIStrings.checkBackLater,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Video grid view with staggered animations
class _VideoGridView extends StatelessWidget {
  final String categoryName;
  final List<VideoEntity> videos;

  const _VideoGridView({
    required this.categoryName,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (videos.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Section header
        SliverToBoxAdapter(
          child: FadeSlideWidget(
            duration: AppDurations.animationMedium,
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spaceM,
                AppDimensions.spaceL,
                AppDimensions.spaceM,
                AppDimensions.spaceM,
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
                  SizedBox(width: AppDimensions.spaceS),
                  Expanded(
                    child: Text(
                      UIStrings.videos,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceS,
                      vertical: AppDimensions.spaceXXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusS,
                    ),
                    child: Text(
                      '${videos.length} ${UIStrings.videos.toLowerCase()}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Video grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spaceM,
              mainAxisSpacing: AppDimensions.spaceM,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = videos[index];
                final row = index ~/ 2;
                final col = index % 2;
                final staggerIndex = row + col;

                return FadeSlideWidget(
                  duration: AppDurations.animationMedium,
                  delay: Duration(milliseconds: 100 + (80 * staggerIndex)),
                  direction: SlideDirection.up,
                  slideOffset: 30,
                  child: VideoCard(
                    video: video,
                    index: index,
                    onTap: () {
                      context.push('/video-player', extra: video.videoUrl);
                    },
                  ),
                );
              },
              childCount: videos.length,
            ),
          ),
        ),
        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.spaceXXL),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return FadeSlideWidget(
      duration: AppDurations.animationMedium,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spaceL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.video_library_outlined,
                size: AppDimensions.iconXXL,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            Text(
              l10n.noVideosAvailable,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              UIStrings.newVideosComingSoon,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
