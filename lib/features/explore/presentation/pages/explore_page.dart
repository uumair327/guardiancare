import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:guardiancare/core/widgets/content_card.dart';
import 'package:guardiancare/core/l10n/generated/app_localizations.dart';
import 'package:guardiancare/features/explore/data/datasources/explore_remote_datasource.dart';
import 'package:guardiancare/features/explore/data/repositories/explore_repository_impl.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_recommendations.dart';
import 'package:guardiancare/features/explore/domain/usecases/get_resources.dart';
import 'package:guardiancare/features/explore/presentation/bloc/explore_cubit.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
            backgroundColor: tPrimaryColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
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
  const RecommendedVideos({Key? key}) : super(key: key);

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
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            l10n.loginToViewRecommendations,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.explore, color: tPrimaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n.recommendedForYou,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: tPrimaryColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: tPrimaryColor),
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
            color: tPrimaryColor,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recommendations')
                  .where('UID', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: tPrimaryColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const SizedBox(height: 60),
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorPrefix(snapshot.error.toString()),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _refreshRecommendations,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tPrimaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const SizedBox(height: 60),
                      const Icon(
                        Icons.video_library_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.noRecommendationsYet,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.takeQuizForRecommendations,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/quiz'),
                          icon: const Icon(Icons.quiz),
                          label: Text(l10n.takeAQuiz),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: tPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.pullDownToRefresh,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
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
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: Text(
                          l10n.noVideosAvailable,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
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
  const ResourcesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('resources')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: tPrimaryColor),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorPrefix(snapshot.error.toString()),
                    style: const TextStyle(fontSize: 16),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noResourcesAvailable,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
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
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: tPrimaryColor,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              final data = resource.data() as Map<String, dynamic>;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resource Icon and Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: tPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getResourceIcon(data['type'] as String?),
                                color: tPrimaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: tPrimaryColor,
                                    ),
                                  ),
                                  if (data['category'] != null)
                                    Text(
                                      data['category'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        
                        // Description
                        if (data['description'] != null && 
                            (data['description'] as String).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              data['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
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
