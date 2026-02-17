// Web-specific implementation of VideoPlayerPage using YouTube iframe embed
// This file is used on web platform where youtube_player_flutter is not supported

// ignore_for_file: avoid_web_libraries_in_flutter, unawaited_futures, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late String _viewId;
  String? _videoId;
  bool _isVideoUrlValid = false;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.videoUrl);
    _isVideoUrlValid = _videoId != null;

    if (_isVideoUrlValid) {
      _viewId = 'youtube-player-${DateTime.now().millisecondsSinceEpoch}';
      _registerViewFactory();
    }
  }

  String? _extractVideoId(String url) {
    // Handle various YouTube URL formats
    final regexPatterns = [
      RegExp(
          r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtube\.com\/shorts\/([a-zA-Z0-9_-]{11})'),
    ];

    for (final regex in regexPatterns) {
      final match = regex.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    // Check if the URL is already just a video ID
    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(url)) {
      return url;
    }

    return null;
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src =
              'https://www.youtube.com/embed/$_videoId?autoplay=1&rel=0&modestbranding=1&enablejsapi=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow =
              'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Video Player',
          style: AppTextStyles.appBarTitle,
        ),
      ),
      body: _isVideoUrlValid
          ? Column(
              children: [
                // Video Player (iframe)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: HtmlElementView(viewType: _viewId),
                ),
                // Video Info Section
                Expanded(
                  child: Container(
                    color: AppColors.black,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: AppDimensions.paddingAllM,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YouTube Video',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceM),
                            Text(
                              'Use the YouTube player controls to play, pause, and seek through the video.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white70,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceL),
                            // Fullscreen hint
                            Container(
                              padding:
                                  const EdgeInsets.all(AppDimensions.spaceM),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppDimensions.borderRadiusM,
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fullscreen,
                                    color: AppColors.primary,
                                    size: AppDimensions.iconM,
                                  ),
                                  const SizedBox(width: AppDimensions.spaceM),
                                  Expanded(
                                    child: Text(
                                      'Click the fullscreen button in the video player for a better viewing experience.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.white70,
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
                ),
              ],
            )
          : _buildInvalidUrlScreen(),
    );
  }

  Widget _buildInvalidUrlScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.primary,
            size: AppDimensions.iconXXL,
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Text(
            'Invalid YouTube URL',
            style: AppTextStyles.h3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Please check the video link and try again',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
          ),
          const SizedBox(height: AppDimensions.spaceL),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceXL,
                vertical: AppDimensions.spaceM,
              ),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
