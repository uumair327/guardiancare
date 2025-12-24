import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:guardiancare/core/core.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isVideoUrlValid = false;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _setPortraitMode();

    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _isVideoUrlValid = true;
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          controlsVisibleAtStart: true,
          hideControls: false,
        ),
      )..addListener(_listener);
    }
  }

  void _listener() {
    if (_isPlayerReady && mounted) {
      setState(() {});
    }
  }

  void _setPortraitMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        progressColors: ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.textSecondary,
          backgroundColor: AppColors.white.withValues(alpha: 0.24),
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
        onEnded: (data) {
          _showVideoEndedDialog();
        },
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (_isFullScreen)
            IconButton(
              icon: Icon(Icons.fullscreen_exit, color: AppColors.white),
              onPressed: () {
                _controller.toggleFullScreenMode();
              },
            ),
        ],
        bottomActions: [
          CurrentPosition(),
          const SizedBox(width: 10),
          ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
              bufferedColor: AppColors.textSecondary,
              backgroundColor: AppColors.white.withValues(alpha: 0.24),
            ),
          ),
          const SizedBox(width: 10),
          RemainingDuration(),
          if (!_isFullScreen)
            IconButton(
              icon: Icon(Icons.fullscreen, color: AppColors.white),
              onPressed: () {
                _controller.toggleFullScreenMode();
              },
            ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: _isFullScreen
              ? null
              : AppBar(
                  backgroundColor: AppColors.secondary,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'Video Player',
                    style: AppTextStyles.appBarTitle,
                  ),
                  actions: [
                    if (_isPlayerReady)
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: AppColors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.fullscreen, color: AppColors.white),
                      onPressed: () {
                        _controller.toggleFullScreenMode();
                      },
                    ),
                  ],
                ),
          body: _isVideoUrlValid
              ? _isFullScreen
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: player,
                      ),
                    )
                  : Column(
                      children: [
                        // Video Player
                        player,
                        
                        // Video Info Section (only in portrait mode)
                        Expanded(
                          child: Container(
                            color: AppColors.black,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Video Title and Stats
                                  Padding(
                                    padding: AppDimensions.paddingAllM,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _controller.metadata.title,
                                          style: AppTextStyles.h3.copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        SizedBox(height: AppDimensions.spaceM),
                                        
                                        // Video Controls Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildControlButton(
                                              icon: Icons.replay_10,
                                              label: 'Replay 10s',
                                              onTap: () {
                                                final currentPos = _controller.value.position;
                                                _controller.seekTo(
                                                  Duration(seconds: currentPos.inSeconds - 10),
                                                );
                                              },
                                            ),
                                            _buildControlButton(
                                              icon: _controller.value.isPlaying
                                                  ? Icons.pause_circle_filled
                                                  : Icons.play_circle_filled,
                                              label: _controller.value.isPlaying ? 'Pause' : 'Play',
                                              onTap: () {
                                                setState(() {
                                                  _controller.value.isPlaying
                                                      ? _controller.pause()
                                                      : _controller.play();
                                                });
                                              },
                                            ),
                                            _buildControlButton(
                                              icon: Icons.forward_10,
                                              label: 'Forward 10s',
                                              onTap: () {
                                                final currentPos = _controller.value.position;
                                                _controller.seekTo(
                                                  Duration(seconds: currentPos.inSeconds + 10),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        
                                        SizedBox(height: AppDimensions.spaceM),
                                        Divider(color: AppColors.textSecondary),
                                        
                                        // Video Duration Info
                                        if (_isPlayerReady)
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceS),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Duration: ${_formatDuration(_controller.metadata.duration)}',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.white70,
                                                  ),
                                                ),
                                                Text(
                                                  'Position: ${_formatDuration(_controller.value.position)}',
                                                  style: AppTextStyles.bodySmall.copyWith(
                                                    color: AppColors.white70,
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
                      ],
                    )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.primary,
                        size: AppDimensions.iconXXL,
                      ),
                      SizedBox(height: AppDimensions.spaceM),
                      Text(
                        'Invalid YouTube URL',
                        style: AppTextStyles.h3.copyWith(color: AppColors.white),
                      ),
                      SizedBox(height: AppDimensions.spaceS),
                      Text(
                        'Please check the video link and try again',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
                      ),
                      SizedBox(height: AppDimensions.spaceL),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceXL,
                            vertical: AppDimensions.spaceM,
                          ),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
        );
      },
      onEnterFullScreen: () {
        setState(() {
          _isFullScreen = true;
        });
        _setLandscapeMode();
      },
      onExitFullScreen: () {
        setState(() {
          _isFullScreen = false;
        });
        _setPortraitMode();
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusS,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceM,
          vertical: AppDimensions.spaceM,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: AppDimensions.iconL),
            SizedBox(height: AppDimensions.spaceXS),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _showVideoEndedDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text(
          'Video Ended',
          style: AppTextStyles.dialogTitle.copyWith(color: AppColors.white),
        ),
        content: Text(
          'Would you like to replay the video?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Close', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.seekTo(Duration.zero);
              _controller.play();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Replay'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isVideoUrlValid) {
      _controller.removeListener(_listener);
      _controller.dispose();
    }
    // Reset to default orientations and system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }
}
