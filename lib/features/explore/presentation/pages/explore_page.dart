import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/explore/explore.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.explore),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            bottom: TabBar(
              indicatorColor: AppColors.onPrimary,
              labelColor: AppColors.onPrimary,
              unselectedLabelColor: AppColors.white70,
              tabs: [
                Tab(
                  icon: const Icon(Icons.recommend),
                  text: l10n.recommendedForYou,
                ),
                Tab(
                  icon: const Icon(Icons.library_books),
                  text: l10n.resources,
                ),
              ],
            ),
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                RecommendedVideos(),
                ResourcesTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendedVideos extends StatefulWidget {
  const RecommendedVideos({super.key});

  @override
  State<RecommendedVideos> createState() => _RecommendedVideosState();
}

class _RecommendedVideosState extends State<RecommendedVideos> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshRecommendations() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);

    if (user == null) {
      return Center(
        child: Padding(
          padding: AppDimensions.paddingAllL,
          child: Text(
            l10n.loginToViewRecommendations,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: AppDimensions.paddingAllM,
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.explore, color: AppColors.primary, size: AppDimensions.iconL),
              SizedBox(width: AppDimensions.spaceM),
              Text(
                l10n.recommendedForYou,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: AppColors.primary),
                onPressed: _refreshRecommendations,
                tooltip: l10n.retry,
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshRecommendations,
            color: AppColors.primary,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recommendations')
                  .where('UID', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: AppDimensions.paddingAllL,
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppDimensions.paddingAllL,
                    children: [
                      SizedBox(height: AppDimensions.spaceXXL),
                      Icon(Icons.error_outline,
                          size: AppDimensions.iconXXL, color: AppColors.error),
                      SizedBox(height: AppDimensions.spaceM),
                      Text(
                        l10n.errorPrefix(snapshot.error.toString()),
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppDimensions.spaceM),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _refreshRecommendations,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppDimensions.paddingAllL,
                    children: [
                      SizedBox(height: AppDimensions.spaceXXL),
                      Icon(
                        Icons.video_library_outlined,
                        size: AppDimensions.iconXXL * 1.3,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppDimensions.spaceL),
                      Text(
                        l10n.noRecommendationsYet,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppDimensions.spaceM),
                      Text(
                        l10n.takeQuizForRecommendations,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppDimensions.spaceXL),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/quiz'),
                          icon: const Icon(Icons.quiz),
                          label: Text(l10n.takeAQuiz),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceXL,
                              vertical: AppDimensions.spaceM,
                            ),
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusM,
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
                  );
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
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppDimensions.paddingAllL,
                    children: [
                      SizedBox(height: AppDimensions.spaceXXL),
                      Center(
                        child: Text(
                          l10n.noVideosAvailable,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: AppDimensions.spaceS, bottom: AppDimensions.spaceM),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final data = video.data() as Map<String, dynamic>;
                    return ContentCard(
                      imageUrl: data['thumbnail'] ?? '',
                      title: data['title'] ?? 'Untitled',
                      description: data['video'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}


// Resources Tab Widget - Using StreamBuilder for simplicity
class ResourcesTab extends StatelessWidget {
  const ResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resources')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: AppDimensions.paddingAllL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: AppDimensions.iconXXL, color: AppColors.error),
                  SizedBox(height: AppDimensions.spaceM),
                  Text(
                    l10n.errorPrefix(snapshot.error.toString()),
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: AppDimensions.paddingAllL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: AppDimensions.iconXXL * 1.3,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                  Text(
                    l10n.noResourcesAvailable,
                    style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final resources = snapshot.data!.docs;

        return RefreshIndicator(
          onRefresh: () async {
            // Trigger rebuild
            await Future.delayed(AppDurations.animationMedium);
          },
          color: AppColors.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppDimensions.paddingAllM,
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              final data = resource.data() as Map<String, dynamic>;
              
              return Card(
                margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                elevation: AppDimensions.elevationS,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusM,
                ),
                child: InkWell(
                  onTap: () {
                    final url = data['url'] as String?;
                    final type = data['type'] as String?;
                    final title = data['title'] as String? ?? 'Resource';
                    
                    if (url != null && url.isNotEmpty) {
                      if (type?.toLowerCase() == 'pdf') {
                        context.push(
                          '/pdf-viewer',
                          extra: {
                            'url': url,
                            'title': title,
                          },
                        );
                      } else {
                        context.push('/webview', extra: url);
                      }
                    }
                  },
                  borderRadius: AppDimensions.borderRadiusM,
                  child: Padding(
                    padding: AppDimensions.paddingAllM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resource Icon and Title
                        Row(
                          children: [
                            Container(
                              padding: AppDimensions.paddingAllM,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: AppDimensions.borderRadiusS,
                              ),
                              child: Icon(
                                _getResourceIcon(data['type'] as String?),
                                color: AppColors.primary,
                                size: AppDimensions.iconL,
                              ),
                            ),
                            SizedBox(width: AppDimensions.spaceM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? 'Untitled',
                                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                                  ),
                                  if (data['category'] != null)
                                    Text(
                                      data['category'],
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: AppDimensions.iconS,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        
                        // Description
                        if (data['description'] != null && 
                            (data['description'] as String).isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: AppDimensions.spaceM),
                            child: Text(
                              data['description'],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getResourceIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'article':
        return Icons.article;
      case 'video':
        return Icons.play_circle_outline;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'link':
      case 'website':
        return Icons.link;
      case 'guide':
        return Icons.menu_book;
      default:
        return Icons.library_books;
    }
  }
}
