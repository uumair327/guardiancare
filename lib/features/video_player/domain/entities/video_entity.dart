import 'package:equatable/equatable.dart';

/// Entity representing video metadata
class VideoEntity extends Equatable {
  final String videoId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final Duration? duration;
  final String? channelName;

  const VideoEntity({
    required this.videoId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.duration,
    this.channelName,
  });

  @override
  List<Object?> get props => [
        videoId,
        title,
        description,
        thumbnailUrl,
        duration,
        channelName,
      ];
}

/// Represents the current playback state
enum PlaybackState {
  idle,
  loading,
  playing,
  paused,
  buffering,
  ended,
  error,
}

/// Entity representing video playback progress
class VideoProgress extends Equatable {
  final Duration position;
  final Duration buffered;
  final Duration total;

  const VideoProgress({
    required this.position,
    required this.buffered,
    required this.total,
  });

  double get progressPercent =>
      total.inMilliseconds > 0 ? position.inMilliseconds / total.inMilliseconds : 0;

  double get bufferedPercent =>
      total.inMilliseconds > 0 ? buffered.inMilliseconds / total.inMilliseconds : 0;

  @override
  List<Object> get props => [position, buffered, total];
}
