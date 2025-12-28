// Web-specific implementation of VideoPlayerPage using YouTube iframe embed
// This file is used on web platform where youtube_player_flutter is not supported

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/video_player/presentation/constants/strings.dart';

/// Education-friendly video player page for web platform
/// Uses YouTube iframe embed since youtube_player_flutter doesn't support web
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

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
      _viewId = 'youtube-player-feature-${DateTime.now().millisecondsSinceEpoch}';
      _registerViewFactory();
    }
  }

  String? _extractVideoId(String url) {
    // Handle various YouTube URL formats
    final regexPatterns = [
      RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})'),
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
          ..src = 'https://www.youtube.com/embed/$_videoId?autoplay=1&rel=0&modestbranding=1&enablejsapi=1'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; fullscreen'
          ..allowFullscreen = true;
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoUrlValid) {
      return _buildInvalidUrlScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(),
            // Video player (iframe)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: AppColors.black,
                child: HtmlElementView(viewType: _viewId),
              ),
            ),
            // Video info section
            Expanded(
              child: _buildVideoInfoSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceS,
        vertical: AppDimensions.spaceXS,
      ),
      color: const Color(0xFF1A1A2E),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              VideoPlayerStrings.pageTitle,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfoSection() {
    return Container(
      color: const Color(0xFF0F0F1A),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video title
            Text(
              VideoPlayerStrings.youtubeVideo,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimensions.spaceM),
            Text(
              VideoPlayerStrings.webPlayerInstructions,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: AppDimensions.spaceL),
            // Info card
            _buildInfoCard(),
            SizedBox(height: AppDimensions.spaceL),
            // Quick actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            const Color(0xFF7C3AED).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_outline_rounded,
              color: Color(0xFF8B5CF6),
              size: 32,
            ),
          ),
          SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VideoPlayerStrings.webPlayer,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXS),
                Text(
                  VideoPlayerStrings.usingYoutubeEmbedded,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.fullscreen_rounded,
            label: VideoPlayerStrings.fullscreen,
            hint: VideoPlayerStrings.usePlayerControls,
            onTap: () {
              // Show hint that fullscreen is available in the player
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(FeedbackStrings.fullscreenHint),
                  backgroundColor: const Color(0xFF8B5CF6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusM,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.arrow_back_rounded,
            label: UIStrings.goBack,
            hint: VideoPlayerStrings.returnToPreviousPage,
            onTap: () => Navigator.pop(context),
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildInvalidUrlScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          VideoPlayerStrings.pageTitle,
          style: AppTextStyles.appBarTitle.copyWith(color: AppColors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 64,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXL),
              Text(
                VideoPlayerStrings.invalidVideoUrl,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.spaceM),
              Text(
                VideoPlayerStrings.invalidVideoUrlDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXL),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(UIStrings.goBack),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXL,
                    vertical: AppDimensions.spaceM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusM,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action button widget for web using centralized AnimatedButton.
///
/// Uses [AnimatedButton] for scale-tap animation,
/// eliminating duplicate animation code.
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: AnimatedButton(
        onTap: onTap,
        config: AnimationPresets.scaleButton, // 0.95 scale
        enableHaptic: true,
        hapticType: HapticFeedbackType.light,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                )
              : null,
          color: isPrimary ? null : AppColors.white.withValues(alpha: 0.08),
          borderRadius: AppDimensions.borderRadiusM,
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.white.withValues(alpha: 0.15),
                ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.spaceM,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: AppDimensions.iconS,
            ),
            SizedBox(width: AppDimensions.spaceS),
            Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
