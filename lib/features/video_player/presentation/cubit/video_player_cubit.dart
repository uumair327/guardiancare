import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardiancare/features/video_player/domain/entities/video_entity.dart';
import 'package:guardiancare/features/video_player/presentation/cubit/video_player_state.dart';

/// Cubit for managing video player state
class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit() : super(const VideoPlayerState());

  /// Updates the playback state
  void setPlaybackState(PlaybackState playbackState) {
    emit(state.copyWith(playbackState: playbackState));
  }

  /// Updates the video progress
  void updateProgress(VideoProgress progress) {
    emit(state.copyWith(progress: progress));
  }

  /// Sets the video title
  void setVideoTitle(String title) {
    emit(state.copyWith(videoTitle: title));
  }

  /// Sets an error message
  void setError(String message) {
    emit(state.copyWith(
      playbackState: PlaybackState.error,
      errorMessage: message,
    ));
  }

  /// Toggles fullscreen mode
  void toggleFullScreen() {
    emit(state.copyWith(isFullScreen: !state.isFullScreen));
  }

  /// Sets fullscreen mode
  void setFullScreen(bool isFullScreen) {
    emit(state.copyWith(isFullScreen: isFullScreen));
  }

  /// Toggles controls visibility
  void toggleControls() {
    emit(state.copyWith(showControls: !state.showControls));
  }

  /// Shows controls
  void showControls() {
    emit(state.copyWith(showControls: true));
  }

  /// Hides controls
  void hideControls() {
    emit(state.copyWith(showControls: false));
  }

  /// Sets playback speed
  void setPlaybackSpeed(double speed) {
    emit(state.copyWith(playbackSpeed: speed));
  }

  /// Toggles mute
  void toggleMute() {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  /// Resets the player state
  void reset() {
    emit(const VideoPlayerState());
  }
}
