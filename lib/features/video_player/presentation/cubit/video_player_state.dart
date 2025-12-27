import 'package:equatable/equatable.dart';
import 'package:guardiancare/features/video_player/domain/entities/video_entity.dart';

/// State for the video player cubit
class VideoPlayerState extends Equatable {
  final PlaybackState playbackState;
  final VideoProgress progress;
  final String? videoTitle;
  final String? errorMessage;
  final bool isFullScreen;
  final bool showControls;
  final double playbackSpeed;
  final bool isMuted;

  const VideoPlayerState({
    this.playbackState = PlaybackState.idle,
    this.progress = const VideoProgress(
      position: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
    this.videoTitle,
    this.errorMessage,
    this.isFullScreen = false,
    this.showControls = true,
    this.playbackSpeed = 1.0,
    this.isMuted = false,
  });

  VideoPlayerState copyWith({
    PlaybackState? playbackState,
    VideoProgress? progress,
    String? videoTitle,
    String? errorMessage,
    bool? isFullScreen,
    bool? showControls,
    double? playbackSpeed,
    bool? isMuted,
  }) {
    return VideoPlayerState(
      playbackState: playbackState ?? this.playbackState,
      progress: progress ?? this.progress,
      videoTitle: videoTitle ?? this.videoTitle,
      errorMessage: errorMessage,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      showControls: showControls ?? this.showControls,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [
        playbackState,
        progress,
        videoTitle,
        errorMessage,
        isFullScreen,
        showControls,
        playbackSpeed,
        isMuted,
      ];
}
