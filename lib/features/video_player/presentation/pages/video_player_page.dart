import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/video_player/domain/entities/video_entity.dart';
import 'package:guardiancare/features/video_player/presentation/constants/strings.dart';
import 'package:guardiancare/features/video_player/presentation/cubit/video_player_cubit.dart';
import 'package:guardiancare/features/video_player/presentation/cubit/video_player_state.dart';
import 'package:guardiancare/features/video_player/presentation/widgets/widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide PlaybackSpeedButton, PlayPauseButton;

/// Education-friendly video player page with clean architecture
/// Supports fullscreen, landscape mode, and smooth transitions
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late YoutubePlayerController _ytController;
  late VideoPlayerCubit _cubit;
  late AnimationController _controlsAnimController;
  late Animation<double> _controlsFadeAnimation;
  late AnimationController _overlayAnimController;

  Timer? _hideControlsTimer;
  bool _isVideoUrlValid = false;
  bool _isDisposed = false;

  // Orientation tracking
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = VideoPlayerCubit();
    _initAnimations();
    _initVideoPlayer();
    _setInitialOrientation();
  }

  void _initAnimations() {
    // Controls fade animation
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.animationMedium,
    );
    _controlsFadeAnimation = CurvedAnimation(
      parent: _controlsAnimController,
      curve: AppCurves.standard,
    );
    _controlsAnimController.forward();

    // Overlay background animation
    _overlayAnimController = AnimationController(
      vsync: this,
      duration: AppDurations.animationShort,
    );
    _overlayAnimController.forward();
  }

  void _initVideoPlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    if (videoId != null) {
      _isVideoUrlValid = true;
      _ytController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          hideControls: true,
        ),
      )..addListener(_onPlayerStateChanged);
    }
  }

  void _setInitialOrientation() {
    // Start in portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _setSystemUIForPortrait();
  }

  void _setSystemUIForPortrait() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.videoBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _setSystemUIForFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Handle orientation changes smoothly
    final newOrientation = MediaQuery.of(context).orientation;
    if (_currentOrientation != newOrientation) {
      _currentOrientation = newOrientation;
      _handleOrientationChange(newOrientation);
    }
  }

  void _handleOrientationChange(Orientation orientation) {
    if (_isDisposed) return;

    if (orientation == Orientation.landscape && !_cubit.state.isFullScreen) {
      // Auto-enter fullscreen when rotating to landscape
      _enterFullScreen();
    } else if (orientation == Orientation.portrait &&
        _cubit.state.isFullScreen) {
      // Auto-exit fullscreen when rotating to portrait
      _exitFullScreen();
    }
  }

  void _onPlayerStateChanged() {
    if (!mounted || _isDisposed) return;

    final value = _ytController.value;

    // Update playback state
    if (value.isPlaying) {
      _cubit.setPlaybackState(PlaybackState.playing);
      _startHideControlsTimer();
    } else if (value.hasError) {
      _cubit.setError(VideoPlayerStrings.videoPlaybackError);
    } else {
      _cubit.setPlaybackState(PlaybackState.paused);
    }

    // Update progress
    _cubit.updateProgress(VideoProgress(
      position: value.position,
      buffered: Duration.zero,
      total: _ytController.metadata.duration,
    ));

    // Update title
    if (_ytController.metadata.title.isNotEmpty) {
      _cubit.setVideoTitle(_ytController.metadata.title);
    }
  }

  // ==================== Fullscreen Management ====================

  void _enterFullScreen() {
    if (_isDisposed) return;

    HapticFeedback.mediumImpact();
    _cubit.setFullScreen(isFullScreen: true);

    // Allow both landscape orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _setSystemUIForFullscreen();

    // Trigger YouTube player fullscreen
    if (!_ytController.value.isFullScreen) {
      _ytController.toggleFullScreenMode();
    }
  }

  void _exitFullScreen() {
    if (_isDisposed) return;

    HapticFeedback.lightImpact();
    _cubit.setFullScreen(isFullScreen: false);

    // Return to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _setSystemUIForPortrait();

    // Exit YouTube player fullscreen
    if (_ytController.value.isFullScreen) {
      _ytController.toggleFullScreenMode();
    }
  }

  void _toggleFullScreen() {
    if (_cubit.state.isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  // ==================== Controls Management ====================

  void _toggleControls() {
    if (_cubit.state.showControls) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  void _showControls() {
    _controlsAnimController.forward();
    _cubit.showControls();
    _startHideControlsTimer();
  }

  void _hideControls() {
    _controlsAnimController.reverse();
    _cubit.hideControls();
    _hideControlsTimer?.cancel();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted &&
          !_isDisposed &&
          _cubit.state.playbackState == PlaybackState.playing &&
          _cubit.state.showControls) {
        _hideControls();
      }
    });
  }

  // ==================== Playback Controls ====================

  void _onSeek(Duration position) {
    HapticFeedback.selectionClick();
    _ytController.seekTo(position);
    _showControls();
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    if (_ytController.value.isPlaying) {
      _ytController.pause();
    } else {
      _ytController.play();
    }
    _showControls();
  }

  void _seekForward() {
    HapticFeedback.lightImpact();
    final newPosition =
        _ytController.value.position + const Duration(seconds: 10);
    final maxDuration = _ytController.metadata.duration;
    _ytController.seekTo(
      newPosition > maxDuration ? maxDuration : newPosition,
    );
    _showControls();
  }

  void _seekBackward() {
    HapticFeedback.lightImpact();
    final newPosition =
        _ytController.value.position - const Duration(seconds: 10);
    _ytController.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    _showControls();
  }

  void _showSpeedSelector() {
    HapticFeedback.lightImpact();
    _hideControlsTimer?.cancel();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
        bloc: _cubit,
        builder: (context, state) {
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.spaceM),
              child: PlaybackSpeedSelector(
                currentSpeed: state.playbackSpeed,
                onSpeedChanged: (speed) {
                  _cubit.setPlaybackSpeed(speed);
                  _ytController.setPlaybackRate(speed);
                  Navigator.pop(context);
                  _startHideControlsTimer();
                },
              ),
            ),
          );
        },
      ),
    ).then((_) => _startHideControlsTimer());
  }

  void _showVideoEndedDialog() {
    if (!mounted || _isDisposed) return;

    // Exit fullscreen first
    if (_cubit.state.isFullScreen) {
      _exitFullScreen();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VideoEndedDialog(
        onReplay: () {
          Navigator.pop(context);
          _ytController.seekTo(Duration.zero);
          _ytController.play();
        },
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    if (!_isVideoUrlValid) {
      return _buildInvalidUrlScreen();
    }

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
        bloc: _cubit,
        builder: (context, state) {
          return PopScope(
            canPop: !state.isFullScreen,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && state.isFullScreen) {
                _exitFullScreen();
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.black,
              body: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _ytController,
                  onReady: () {
                    _cubit.setPlaybackState(PlaybackState.playing);
                    _startHideControlsTimer();
                  },
                  onEnded: (_) => _showVideoEndedDialog(),
                ),
                onEnterFullScreen: () {
                  if (!_cubit.state.isFullScreen) {
                    _cubit.setFullScreen(isFullScreen: true);
                    _setSystemUIForFullscreen();
                  }
                },
                onExitFullScreen: () {
                  if (_cubit.state.isFullScreen) {
                    _cubit.setFullScreen(isFullScreen: false);
                    _setSystemUIForPortrait();
                  }
                },
                builder: (context, player) {
                  return AnimatedSwitcher(
                    duration: AppDurations.animationMedium,
                    child: state.isFullScreen
                        ? _buildFullScreenLayout(player, state)
                        : _buildPortraitLayout(player, state),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout(Widget player, VideoPlayerState state) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // App bar
          _buildAppBar(state),
          // Video player with controls overlay
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildVideoContainer(player, state, isFullScreen: false),
          ),
          // Video info section
          Expanded(
            child: _buildVideoInfoSection(state),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenLayout(Widget player, VideoPlayerState state) {
    return _buildVideoContainer(player, state, isFullScreen: true);
  }

  Widget _buildVideoContainer(Widget player, VideoPlayerState state,
      {required bool isFullScreen}) {
    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTapDown: (details) {
        // Double tap to seek
        final screenWidth = MediaQuery.of(context).size.width;
        final tapX = details.globalPosition.dx;

        if (tapX < screenWidth / 3) {
          _seekBackward();
        } else if (tapX > screenWidth * 2 / 3) {
          _seekForward();
        } else {
          _togglePlayPause();
        }
      },
      child: Container(
        color: AppColors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video player
            Center(
              child: RepaintBoundary(child: player),
            ),
            // Controls overlay
            _buildControlsOverlay(state, isFullScreen: isFullScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(VideoPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceS,
        vertical: AppDimensions.spaceXS,
      ),
      color: AppColors.videoSurface,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Text(
              state.videoTitle ?? VideoPlayerStrings.pageTitle,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PlaybackSpeedButton(
            currentSpeed: state.playbackSpeed,
            onTap: _showSpeedSelector,
          ),
        ],
      ),
    );
  }

  // ==================== Controls Overlay ====================

  Widget _buildControlsOverlay(VideoPlayerState state,
      {required bool isFullScreen}) {
    return AnimatedBuilder(
      animation: _controlsFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _controlsFadeAnimation.value,
          child: IgnorePointer(
            ignoring: !state.showControls,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.black.withValues(alpha: 0.7),
              Colors.transparent,
              Colors.transparent,
              AppColors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.0, 0.25, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          top: isFullScreen,
          bottom: isFullScreen,
          left: isFullScreen,
          right: isFullScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top bar (fullscreen only)
              if (isFullScreen) _buildFullScreenTopBar(state),
              // Center controls
              Expanded(
                child: Center(
                  child: _buildCenterControls(state),
                ),
              ),
              // Bottom controls
              _buildBottomControls(state, isFullScreen: isFullScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenTopBar(VideoPlayerState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      child: Row(
        children: [
          _buildControlButton(
            icon: Icons.arrow_back_rounded,
            onTap: _exitFullScreen,
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Expanded(
            child: Text(
              state.videoTitle ?? '',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PlaybackSpeedButton(
            currentSpeed: state.playbackSpeed,
            onTap: _showSpeedSelector,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(VideoPlayerState state) {
    final isPlaying = state.playbackState == PlaybackState.playing;
    final isLoading = state.playbackState == PlaybackState.loading ||
        state.playbackState == PlaybackState.buffering;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSeekButton(
          icon: Icons.replay_10_rounded,
          onTap: _seekBackward,
        ),
        const SizedBox(width: AppDimensions.spaceXL),
        if (isLoading)
          _buildLoadingIndicator()
        else
          _buildPlayPauseButton(isPlaying),
        const SizedBox(width: AppDimensions.spaceXL),
        _buildSeekButton(
          icon: Icons.forward_10_rounded,
          onTap: _seekForward,
        ),
      ],
    );
  }

  Widget _buildSeekButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(bool isPlaying) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          gradient: AppColors.videoGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.videoPrimarySubtle50,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: AppDurations.animationShort,
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: AppColors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 64,
      height: 64,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.videoPrimary),
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceS),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }

  // ==================== Bottom Controls ====================

  Widget _buildBottomControls(VideoPlayerState state,
      {required bool isFullScreen}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isFullScreen ? AppDimensions.spaceL : AppDimensions.spaceM,
        vertical: AppDimensions.spaceS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          _buildProgressBar(state),
          const SizedBox(height: AppDimensions.spaceS),
          // Bottom row
          Row(
            children: [
              // Time display
              _buildTimeDisplay(state),
              const Spacer(),
              // Control buttons
              _buildMuteButton(state),
              const SizedBox(width: AppDimensions.spaceS),
              _buildFullScreenButton(isFullScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(VideoPlayerState state) {
    final progress = state.progress;
    final progressPercent = progress.total.inMilliseconds > 0
        ? progress.position.inMilliseconds / progress.total.inMilliseconds
        : 0.0;

    return GestureDetector(
      onHorizontalDragStart: (_) => HapticFeedback.selectionClick(),
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final percent = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
        final seekPosition = Duration(
          milliseconds: (percent * progress.total.inMilliseconds).round(),
        );
        _ytController.seekTo(seekPosition);
      },
      onTapUp: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final percent = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
        final seekPosition = Duration(
          milliseconds: (percent * progress.total.inMilliseconds).round(),
        );
        _onSeek(seekPosition);
      },
      child: Container(
        height: 24,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Progress track
            FractionallySizedBox(
              widthFactor: progressPercent.clamp(0.0, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppColors.videoGradient,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.videoPrimarySubtle50,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
            // Thumb
            Positioned(
              left: (progressPercent *
                      (MediaQuery.of(context).size.width -
                          (AppDimensions.spaceM * 2) -
                          12))
                  .clamp(0.0, double.infinity),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.videoPrimarySubtle50,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(VideoPlayerState state) {
    return Text(
      '${_formatDuration(state.progress.position)} / ${_formatDuration(state.progress.total)}',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.white,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildMuteButton(VideoPlayerState state) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _cubit.toggleMute();
        if (_cubit.state.isMuted) {
          _ytController.mute();
        } else {
          _ytController.unMute();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceS),
        child: Icon(
          state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildFullScreenButton(bool isFullScreen) {
    return GestureDetector(
      onTap: _toggleFullScreen,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceS),
        child: Icon(
          isFullScreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }

  // ==================== Video Info Section ====================

  Widget _buildVideoInfoSection(VideoPlayerState state) {
    return Container(
      color: AppColors.videoBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video title
            Text(
              state.videoTitle ?? UIStrings.loading,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            // Progress card
            _buildProgressCard(state),
            const SizedBox(height: AppDimensions.spaceL),
            // Quick actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(VideoPlayerState state) {
    final progressPercent = state.progress.total.inMilliseconds > 0
        ? (state.progress.position.inMilliseconds /
                state.progress.total.inMilliseconds *
                100)
            .round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.videoPrimarySubtle15,
            AppColors.videoPrimarySubtle10,
          ],
        ),
        borderRadius: AppDimensions.borderRadiusL,
        border: Border.all(
          color: AppColors.videoPrimarySubtle30,
        ),
      ),
      child: Row(
        children: [
          // Progress circle
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progressPercent / 100,
                  strokeWidth: 5,
                  backgroundColor: AppColors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.videoPrimary,
                  ),
                ),
                Text(
                  '$progressPercent%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          // Time info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VideoPlayerStrings.watchProgress,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  VideoPlayerStrings.watched(
                      _formatDuration(state.progress.position)),
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Remaining time
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: AppColors.videoPrimarySubtle20,
              borderRadius: AppDimensions.borderRadiusS,
            ),
            child: Text(
              '-${_formatDuration(state.progress.total - state.progress.position)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.videoPrimary,
                fontWeight: FontWeight.w600,
              ),
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
            icon: Icons.replay_rounded,
            label: VideoPlayerStrings.restart,
            onTap: () {
              HapticFeedback.lightImpact();
              _ytController.seekTo(Duration.zero);
            },
          ),
        ),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.speed_rounded,
            label: VideoPlayerStrings.speed,
            onTap: _showSpeedSelector,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceM),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.fullscreen_rounded,
            label: VideoPlayerStrings.fullscreen,
            onTap: _enterFullScreen,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  // ==================== Invalid URL Screen ====================

  Widget _buildInvalidUrlScreen() {
    return Scaffold(
      backgroundColor: AppColors.videoBackground,
      appBar: AppBar(
        backgroundColor: AppColors.videoSurface,
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
          padding: const EdgeInsets.all(AppDimensions.spaceXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceXL),
                decoration: const BoxDecoration(
                  color: AppColors.videoPrimarySubtle10,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.videoPrimary,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              Text(
                VideoPlayerStrings.invalidVideoUrl,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceM),
              Text(
                VideoPlayerStrings.invalidVideoUrlDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              _QuickActionButton(
                icon: Icons.arrow_back_rounded,
                label: UIStrings.goBack,
                onTap: () => Navigator.pop(context),
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== Utilities ====================

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

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _hideControlsTimer?.cancel();
    _controlsAnimController.dispose();
    _overlayAnimController.dispose();

    if (_isVideoUrlValid) {
      _ytController.removeListener(_onPlayerStateChanged);
      _ytController.dispose();
    }
    _cubit.close();

    // Reset orientations and system UI
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

// ==================== Supporting Widgets ====================

/// Quick action button widget using centralized AnimatedButton.
///
/// Uses [AnimatedButton] for scale-tap animation,
/// eliminating duplicate animation code.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      config: AnimationPresets.scaleButton, // 0.95 scale, same as original
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.videoGradient : null,
        color: isPrimary ? null : AppColors.white.withValues(alpha: 0.08),
        borderRadius: AppDimensions.borderRadiusM,
        border: isPrimary
            ? null
            : Border.all(
                color: AppColors.white.withValues(alpha: 0.15),
              ),
      ),
      padding: const EdgeInsets.symmetric(
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
          const SizedBox(width: AppDimensions.spaceS),
          Text(
            label,
            style: AppTextStyles.button.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Video ended dialog
class _VideoEndedDialog extends StatelessWidget {
  const _VideoEndedDialog({
    required this.onReplay,
    required this.onClose,
  });
  final VoidCallback onReplay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.videoSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusL,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceL),
              decoration: const BoxDecoration(
                color: AppColors.videoPrimarySubtle15,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.videoPrimary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              VideoPlayerStrings.videoComplete,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              VideoPlayerStrings.watchAgainPrompt,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onClose,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceM,
                      ),
                    ),
                    child: Text(
                      UIStrings.close,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceM),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReplay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.videoPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                    ),
                    child: Text(
                      VideoPlayerStrings.replay,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
