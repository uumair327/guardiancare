import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/src/common_widgets/WebViewPage.dart';
import 'package:shimmer/shimmer.dart';

class HomeCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> carouselData;
  final double carouselHeight;

  const HomeCarousel({
    Key? key,
    required this.carouselData,
    required this.carouselHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: carouselHeight,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.scale,
        scrollDirection: Axis.horizontal,
      ),
      items: carouselData.isEmpty
          ? _buildShimmerItems()
          : carouselData.map((item) {
              final type = item['type'] ?? 'image';
              final imageUrl = item['imageUrl'];
              final link = item['link'];
              final thumbnailUrl = item['thumbnailUrl'] ?? '';

              if (imageUrl == null || link == null) {
                return _buildShimmerItem();
              }

              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewPage(url: link),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: type == 'video' ? thumbnailUrl : imageUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          if (type == 'video')
                            const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 50.0,
                              ),
                            ),
                        Positioned(
                            bottom: 5.0,
                            right: 10.0,
                            child: Text(
                              "Source: childrenofindia.in",
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.white.withOpacity(0.9),
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SizedBox(
          width: double.infinity,
          height: carouselHeight,
        ),
      ),
    );
  }

  List<Widget> _buildShimmerItems() {
    return List.generate(5, (index) => _buildShimmerItem());
  }
}
