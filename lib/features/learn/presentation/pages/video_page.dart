import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  List<List<String>>? categories;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot thumbnails =
          await FirebaseFirestore.instance.collection('learn').get();
      List<List<String>> categoryList = [];
      for (var doc in thumbnails.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['name'] as String?;
        final thumbnail = data['thumbnail'] as String?;
        if (category != null && thumbnail != null) {
          categoryList.add([category, thumbnail]);
        }
      }
      if (mounted) {
        setState(() {
          categories = categoryList;
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        setState(() {
          categories = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory ?? l10n.learn),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        leading: selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: categories == null
          ? const Center(child: CircularProgressIndicator())
          : selectedCategory != null
              ? buildVideoList(selectedCategory!)
              : buildCategoryList(),
      ),
    );
  }

  Widget buildCategoryList() {
    final l10n = AppLocalizations.of(context)!;
    
    if (categories!.isEmpty) {
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
        itemCount: categories!.length,
        itemBuilder: (context, index) {
          final category = categories![index][0];
          final thumbnail = categories![index][1];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
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
                      thumbnail,
                      fit: BoxFit.cover,
                      width: 300,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.video_library, size: 48),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: AppDimensions.paddingAllS,
                    child: Text(
                      category,
                      style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildVideoList(String category) {
    final l10n = AppLocalizations.of(context)!;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(l10n.errorPrefix(snapshot.error.toString())));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(l10n.noVideosAvailable));
        }

        List<QueryDocumentSnapshot> videos = snapshot.data!.docs;
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
              var video = videos[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  final videoUrl = video['videoUrl'] as String? ?? '';
                  context.push('/video-player', extra: videoUrl);
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
                          video["thumbnailUrl"] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.play_circle_outline,
                                  size: 48),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: AppDimensions.paddingAllS,
                        child: Text(
                          video['title'] ?? 'Untitled',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
