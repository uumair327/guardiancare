import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/learn/domain/entities/category_entity.dart';
import 'package:guardiancare/features/learn/domain/entities/video_entity.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_bloc.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_event.dart';
import 'package:guardiancare/features/learn/presentation/bloc/learn_state.dart';

/// VideoPage - Displays learning categories and videos
/// 
/// This page follows SRP by:
/// - Only rendering UI and dispatching events to LearnBloc
/// - No direct Firestore queries (delegated to LearnBloc/Repository)
/// 
/// Requirements: 3.1, 3.2, 3.3, 3.4
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
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LearnBloc, LearnState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(state, l10n)),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            leading: _buildLeadingButton(context, state),
          ),
          body: SafeArea(
            child: _buildBody(context, state, l10n),
          ),
        );
      },
    );
  }

  String _getAppBarTitle(LearnState state, AppLocalizations l10n) {
    if (state is VideosLoaded) {
      return state.categoryName;
    }
    if (state is VideosLoading) {
      return state.categoryName;
    }
    return l10n.learn;
  }

  Widget? _buildLeadingButton(BuildContext context, LearnState state) {
    if (state is VideosLoaded || state is VideosLoading) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.read<LearnBloc>().add(BackToCategories());
        },
      );
    }
    return null;
  }

  Widget _buildBody(BuildContext context, LearnState state, AppLocalizations l10n) {
    if (state is LearnInitial || state is LearnLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LearnError) {
      return _buildErrorView(context, state, l10n);
    }

    if (state is CategoriesLoaded) {
      return _CategoryListView(categories: state.categories);
    }

    if (state is VideosLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is VideosLoaded) {
      return _VideoListView(
        categoryName: state.categoryName,
        videos: state.videos,
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView(BuildContext context, LearnError state, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.errorPrefix(state.message),
            textAlign: TextAlign.center,
          ),
          if (state.canRetry) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<LearnBloc>().add(RetryRequested());
              },
              child: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget for displaying the category list
/// Requirements: 3.1 - Categories fetched through LearnBloc
class _CategoryListView extends StatelessWidget {
  final List<CategoryEntity> categories;

  const _CategoryListView({required this.categories});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (categories.isEmpty) {
      return Center(
        child: Text(l10n.noCategoriesAvailable),
      );
    }

    return Padding(
      padding: AppDimensions.paddingAllS,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceS,
          mainAxisSpacing: AppDimensions.spaceM,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryCard(category: category);
        },
      ),
    );
  }
}

/// Widget for displaying a single category card
class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dispatch event to LearnBloc instead of direct state management
        context.read<LearnBloc>().add(CategorySelected(category.name));
      },
      child: Card(
        elevation: AppDimensions.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                category.thumbnail,
                fit: BoxFit.cover,
                width: 300,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.gray300,
                    child: Icon(Icons.video_library, size: AppDimensions.iconXL),
                  );
                },
              ),
            ),
            Padding(
              padding: AppDimensions.paddingAllS,
              child: Text(
                category.name,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying the video list
/// Requirements: 3.2 - Videos fetched through LearnBloc
class _VideoListView extends StatelessWidget {
  final String categoryName;
  final List<VideoEntity> videos;

  const _VideoListView({
    required this.categoryName,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (videos.isEmpty) {
      return Center(child: Text(l10n.noVideosAvailable));
    }

    return Padding(
      padding: AppDimensions.paddingAllS,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceM,
          mainAxisSpacing: AppDimensions.spaceM,
        ),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _VideoCard(video: video);
        },
      ),
    );
  }
}

/// Widget for displaying a single video card
class _VideoCard extends StatelessWidget {
  final VideoEntity video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/video-player', extra: video.videoUrl);
      },
      child: Card(
        elevation: AppDimensions.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.gray300,
                    child: Icon(
                      Icons.play_circle_outline,
                      size: AppDimensions.iconXL,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: AppDimensions.paddingAllS,
              child: Text(
                video.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
